//
//  PlayerTeamInfoRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository responsible for managing the relationship data between players and teams.
protocol PlayerTeamInfoRepository {
    
    /// Creates a new player-team relationship entry in the database.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - dto: A data transfer object (`PlayerTeamInfoDTO`) containing information about the player's association with the team.
    /// - Returns: The Firestore document ID of the newly created player-team info record.
    /// - Throws: An error if the creation process fails.
    func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String
}
