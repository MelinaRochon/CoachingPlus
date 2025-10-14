//
//  PlayerRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository responsible for managing player data and their relationships to teams in the database.
protocol PlayerRepository {
    
    /// Creates a new player in the database.
    /// - Parameter playerDTO: A data transfer object containing the player's details.
    /// - Returns: The Firestore document ID of the newly created player.
    /// - Throws: An error if the creation fails.
    func createNewPlayer(playerDTO: PlayerDTO) async throws -> String

    /// Retrieves a player by their unique Firestore document ID.
    /// - Parameter playerId: The Firestore document ID of the player.
    /// - Returns: A `DBPlayer` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getPlayer(playerId: String) async throws -> DBPlayer?

    /// Finds a player by a given identifier.
    /// - Parameter id: The unique player identifier to search for.
    /// - Returns: A `DBPlayer` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func findPlayerWithId(id: String) async throws -> DBPlayer?

    /// Updates the guardian’s name for a specific player.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - name: The new guardian name to assign.
    /// - Throws: An error if the update fails.
    func updateGuardianName(id: String, name: String) async throws

    /// Removes all guardian information (name, email, and phone) for a player.
    /// - Parameter id: The Firestore document ID of the player.
    /// - Throws: An error if the removal fails.
    func removeGuardianInfo(id: String) async throws

    /// Adds a team reference to a player’s list of teams.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team to add.
    /// - Throws: An error if the operation fails.
    func addTeamToPlayer(id: String, teamId: String) async throws

    /// Removes a team reference from a player’s list of teams.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team to remove.
    /// - Throws: An error if the operation fails.
    func removeTeamFromPlayer(id: String, teamId: String) async throws

    /// Removes a team from a player’s list using the team’s document ID.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - teamDocId: The Firestore document ID of the team to remove.
    /// - Throws: An error if the operation fails.
    func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws

    /// Removes only the guardian’s name from a player’s record.
    /// - Parameter id: The Firestore document ID of the player.
    /// - Throws: An error if the operation fails.
    func removeGuardianInfoName(id: String) async throws

    /// Removes only the guardian’s email from a player’s record.
    /// - Parameter id: The Firestore document ID of the player.
    /// - Throws: An error if the operation fails.
    func removeGuardianInfoEmail(id: String) async throws

    /// Removes only the guardian’s phone number from a player’s record.
    /// - Parameter id: The Firestore document ID of the player.
    /// - Throws: An error if the operation fails.
    func removeGuardianInfoPhone(id: String) async throws

    /// Updates an existing player's full record in the database.
    /// - Parameter player: A `DBPlayer` object containing the updated player information.
    /// - Throws: An error if the update fails.
    func updatePlayerInfo(player: DBPlayer) async throws

    /// Updates one or more properties of a player's settings.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - jersey: An optional new jersey number.
    ///   - nickname: An optional new nickname.
    ///   - guardianName: An optional new guardian name.
    ///   - guardianEmail: An optional new guardian email.
    ///   - guardianPhone: An optional new guardian phone number.
    ///   - gender: An optional new gender value.
    /// - Throws: An error if the update fails.
    func updatePlayerSettings(
        id: String,
        jersey: Int?,
        nickname: String?,
        guardianName: String?,
        guardianEmail: String?,
        guardianPhone: String?,
        gender: String?
    ) async throws

    /// Updates a player's jersey number and nickname.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - jersey: The new jersey number to assign.
    ///   - nickname: The new nickname to assign.
    /// - Throws: An error if the update fails.
    func updatePlayerJerseyAndNickname(playerDocId: String, jersey: Int, nickname: String) async throws

    /// Updates the player's unique identifier.
    /// - Parameters:
    ///   - id: The Firestore document ID of the player.
    ///   - playerId: The new player identifier to assign.
    /// - Throws: An error if the update fails.
    func updatePlayerId(id: String, playerId: String) async throws

    /// Retrieves all teams that a player is currently enrolled in.
    /// - Parameter playerId: The Firestore document ID of the player.
    /// - Returns: An array of `GetTeam` objects representing the player’s teams.
    /// - Throws: An error if the retrieval fails.
    func getTeamsEnrolled(playerId: String) async throws -> [GetTeam]

    /// Retrieves all teams that a player is enrolled in, including full team details.
    /// - Parameter playerId: The Firestore document ID of the player.
    /// - Returns: An optional array of `DBTeam` objects, or `nil` if none are found.
    /// - Throws: An error if the retrieval fails.
    func getAllTeamsEnrolled(playerId: String) async throws -> [DBTeam]?

    /// Checks whether a player is currently enrolled in a specific team.
    /// - Parameters:
    ///   - playerId: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team.
    /// - Returns: `true` if the player is enrolled, otherwise `false`.
    /// - Throws: An error if the check fails.
    func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool
}
