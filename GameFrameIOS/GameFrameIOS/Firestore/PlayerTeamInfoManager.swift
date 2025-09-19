//
//  PlayerTeamInfoManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation
import FirebaseFirestore

struct DBPlayerTeamInfo: Codable {
    let id: String
    var jerseyNum: Int?
    var nickName: String?
    var joinedAt: Date?
    
    init(
        id: String,
        jerseyNum: Int? = nil,
        nickName: String? = nil,
        joinedAt: Date? = nil
    ) {
        self.id = id
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.joinedAt = joinedAt
    }
    
    
    init(id: String) {
        self.id = id
        self.jerseyNum = nil
        self.nickName = nil
        self.joinedAt = nil
    }
    
    init(id: String, playerTeamInfoDTO: PlayerTeamInfoDTO) {
        self.id = id
        self.jerseyNum = playerTeamInfoDTO.jerseyNum
        self.nickName = playerTeamInfoDTO.nickname
        self.joinedAt = playerTeamInfoDTO.joinedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case jerseyNum = "jersey_num"
        case nickName = "nickname"
        case joinedAt = "added_at"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.jerseyNum = try container.decode(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.jerseyNum, forKey: .jerseyNum)
        try container.encodeIfPresent(self.nickName, forKey: .nickName)
        try container.encodeIfPresent(self.joinedAt, forKey: .joinedAt)
    }
}

final class PlayerTeamInfoManager {
    static let shared = PlayerTeamInfoManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    private let playerCollection = Firestore.firestore().collection("players") // user collection
    
    private func playerDocument(id: String) -> DocumentReference {
        playerCollection.document(id)
    }
    
    private func teamInfoCollection(playerDocId: String) -> CollectionReference {
        playerDocument(id: playerDocId).collection("playerTeamInfo")
    }
    
    private func teamInfoDocument(playerDocId: String, teamId: String) -> DocumentReference {
        teamInfoCollection(playerDocId: playerDocId).document(teamId)
    }
    
    /// Creates/updates players/{playerDocId}/playerTeamInfo/{dto.id}
    /// - Returns: the document id (== teamId)
    func createNewPlayerTeamInfo(playerDocId: String,
                                 playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        print("creating new player team info document!")
        guard !dto.id.isEmpty else {
            throw NSError(domain: "PlayerTeamInfoManager",
                          code: 400,
                          userInfo: [NSLocalizedDescriptionKey: "teamId (dto.teamId) is required"])
        }
        print("ref")
        let ref = teamInfoDocument(playerDocId: playerDocId, teamId: dto.id)

        // Check if joined_at already exists (so we don't overwrite it)
        print("snap")
        let snap = try await ref.getDocument()
        let hasJoinedAt = (snap.data()?["joined_at"] != nil)

        print("setData")
        // Write base fields (without server sentinel)
        try ref.setData(from: dto, merge: true)
        
        print("joinedAt")
        // If dto.joinedAt is nil and joined_at not set yet, set server timestamp
        if !hasJoinedAt, dto.joinedAt == nil {
            try await ref.updateData(["joined_at": FieldValue.serverTimestamp()])
        }

        return ref.documentID
    }
}
