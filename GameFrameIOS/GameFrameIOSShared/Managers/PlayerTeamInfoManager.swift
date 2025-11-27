//
//  PlayerTeamInfoManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation

public final class PlayerTeamInfoManager {
    
    private let repo: PlayerTeamInfoRepository
        
    public init(repo: PlayerTeamInfoRepository) {
        self.repo = repo
    }
    
    /// Creates/updates players/{playerDocId}/playerTeamInfo/{dto.id}
    /// - Returns: the document id (== teamId)
    public func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        return try await repo.createNewPlayerTeamInfo(playerDocId: playerDocId, playerTeamInfoDTO: dto)
    }
    
    
    /// Retrieves the PlayerTeamInfo document for a specific player on a specific team.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team.
    /// - Returns: The player's team info document if it exists, otherwise `nil`.
    public func getPlayerTeamInfo(playerDocId: String, teamId: String) async throws -> DBPlayerTeamInfo? {
        return try await repo.getPlayerTeamInfo(playerDocId: playerDocId, teamId: teamId)
    }
    
    public func getPlayerTeamInfoWithPlayerId(playerId: String, teamId: String) async throws -> DBPlayerTeamInfo? {
        return try await repo.getPlayerTeamInfoWithPlayerId(playerId: playerId, teamId: teamId)
    }
    
    
    /// Updates the jersey number and/or nickname fields in a player's team info document.
    /// Only the provided (non-nil) fields will be updated.
    /// - Parameters:
    ///   - teamId: The ID of the team the player belongs to.
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - jersey: Optional updated jersey number. Pass nil to leave unchanged.
    ///   - nickname: Optional updated nickname. Pass nil to leave unchanged.
    public func updatePlayerTeamInfoJerseyAndNickname(teamId: String, playerDocId: String, jersey: Int?, nickname: String?) async throws {
        return try await repo.updatePlayerTeamInfoJerseyAndNickname(
            teamId: teamId,
            playerDocId: playerDocId,
            jersey: jersey,
            nickname: nickname
        )
    }
}
