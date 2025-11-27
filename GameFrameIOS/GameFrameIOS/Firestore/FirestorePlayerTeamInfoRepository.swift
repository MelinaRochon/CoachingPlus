//
//  FirestorePlayerTeamInfoRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestorePlayerTeamInfoRepository: PlayerTeamInfoRepository {
    private let playerCollection = Firestore.firestore().collection("players") // user collection
    
    private func playerDocument(id: String) -> DocumentReference {
        return playerCollection.document(id)
    }
    
    private func teamInfoCollection(playerDocId: String) -> CollectionReference {
        return playerDocument(id: playerDocId).collection("playerTeamInfo")
    }
    
    private func teamInfoDocument(playerDocId: String, teamId: String) -> DocumentReference {
        return teamInfoCollection(playerDocId: playerDocId).document(teamId)
    }
    
    /// Creates/updates players/{playerDocId}/playerTeamInfo/{dto.id}
    /// - Returns: the document id (== teamId)
    public func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
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
    
    
    /// Retrieves a player's team-specific info document from Firestore.
    ///
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team.
    /// - Returns: A `DBPlayerTeamInfo` object if it exists, otherwise `nil`.
    public func getPlayerTeamInfo(playerDocId: String, teamId: String) async throws -> DBPlayerTeamInfo? {
        return try await teamInfoDocument(playerDocId: playerDocId, teamId: teamId).getDocument(as: DBPlayerTeamInfo.self)
    }
    
    public func getPlayerTeamInfoWithPlayerId(playerId: String, teamId: String) async throws -> DBPlayerTeamInfo? {
        let snapshot = try await playerCollection.whereField("player_id", isEqualTo: playerId).getDocuments()
        
        // Return the first document if available
        guard let doc = snapshot.documents.first else { return nil }
        let subCollectionRef = doc.reference.collection("playerTeamInfo").document(teamId)
        return try await subCollectionRef.getDocument(as: DBPlayerTeamInfo.self)
            
    }
    
    /// Updates only the jersey number and/or nickname fields for a player's team info.
    ///
    /// - Parameters:
    ///   - teamId: The Firestore team document ID.
    ///   - playerDocId: The player's Firestore document ID.
    ///   - jersey: An optional new jersey number. If `nil`, this field is not updated.
    ///   - nickname: An optional new nickname. If `nil`, this field is not updated.
    /// - Throws: An error if the update fails.
    public func updatePlayerTeamInfoJerseyAndNickname(teamId: String, playerDocId: String, jersey: Int?, nickname: String?) async throws {
        var data: [String: Any] = [:]
        if let jersey = jersey {
            data[DBPlayerTeamInfo.CodingKeys.jerseyNum.rawValue] = jersey
        }
        
        if let nickname = nickname {
            data[DBPlayerTeamInfo.CodingKeys.nickName.rawValue] = nickname
        }

        print("data is \(data) in updateUserSettings")
        
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update in updatePlayerInfo")
            return
        }

        try await teamInfoDocument(playerDocId: playerDocId, teamId: teamId).updateData(data as [AnyHashable: Any])
    }

}
