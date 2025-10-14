//
//  FirestorePlayerTeamInfoRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
import FirebaseFirestore

final class FirestorePlayerTeamInfoRepository: PlayerTeamInfoRepository {
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
    func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
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
