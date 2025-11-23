//
//  PlayerTeamInfoRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository responsible for managing the relationship data between players and teams.
public protocol PlayerTeamInfoRepository {
    
    /// Creates a new player-team relationship entry in the database.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - dto: A data transfer object (`PlayerTeamInfoDTO`) containing information about the player's association with the team.
    /// - Returns: The Firestore document ID of the newly created player-team info record.
    /// - Throws: An error if the creation process fails.
    func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String
    
    
    /// Retrieves the team-specific information for a player.
    /// - Parameters:
    ///   - playerDocId: The document ID of the player.
    ///   - teamId: The ID of the team to get info for.
    /// - Returns: A `DBPlayerTeamInfo` object if found, otherwise `nil`.
    func getPlayerTeamInfo(playerDocId: String, teamId: String) async throws -> DBPlayerTeamInfo?

    
    /// Updates the player's jersey number and/or nickname for a specific team.
    /// Only non-nil parameters will be updated.
    /// - Parameters:
    ///   - teamId: The ID of the team to update info for.
    ///   - playerDocId: The document ID of the player.
    ///   - jersey: The new jersey number (optional).
    ///   - nickname: The new nickname (optional).
    func updatePlayerTeamInfoJerseyAndNickname(teamId: String, playerDocId: String, jersey: Int?, nickname: String?) async throws
}
