//
//  PlayerTeamInfoManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation

final class PlayerTeamInfoManager {
    
    private let repo: PlayerTeamInfoRepository
    
    init(repo: PlayerTeamInfoRepository = FirestorePlayerTeamInfoRepository()) {
        self.repo = repo
    }
    
    /// Creates/updates players/{playerDocId}/playerTeamInfo/{dto.id}
    /// - Returns: the document id (== teamId)
    func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        return try await repo.createNewPlayerTeamInfo(playerDocId: playerDocId, playerTeamInfoDTO: dto)
    }
}
