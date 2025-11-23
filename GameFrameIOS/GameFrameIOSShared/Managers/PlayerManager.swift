//
//  PlayerManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import Foundation


public final class PlayerManager {
    
    private let repo: PlayerRepository
        
    public init(repo: PlayerRepository) {
        self.repo = repo
    }
    
    /**
     Creates a new player in the Firestore database.
     - Parameter playerDTO: A `PlayerDTO` object containing player information.
     - Returns: The newly created player's document ID.
     - Throws: An error if creating the player document fails.
     */
    public func createNewPlayer(playerDTO: PlayerDTO) async throws -> String {
        return try await repo.createNewPlayer(playerDTO: playerDTO)
    }
    
    
     /**
      Fetches a player's information from the Firestore database by player ID.
      - Parameter playerId: The player's ID used to find the corresponding player document.
      - Returns: A `DBPlayer` object containing player data, or `nil` if not found.
      - Throws: An error if fetching the player document fails.
      */
    public func getPlayer(playerId: String) async throws -> DBPlayer? {
        return try await repo.getPlayer(playerId: playerId)
    }
    
    
    /**
     Fetches a player by their document ID.
     
     - Parameter id: The unique player document ID.
     - Returns: A `DBPlayer` object containing player data, or `nil` if not found.
     - Throws: An error if fetching the player document fails.
     */
    public func findPlayerWithId(id: String) async throws -> DBPlayer? {
        return try await repo.findPlayerWithId(id: id)
    }

    
    /**
     Updates the guardian's name for a specific player.
     
     - Parameter id: The unique player document ID.
     - Parameter name: The new guardian's name to update in the player document.
     - Throws: An error if updating the document fails.
     */
    public func updateGuardianName(id: String, name: String) async throws {
        try await repo.updateGuardianName(id: id, name: name)
    }
    
   
    /**
     Removes all guardian information from a player's document.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    public func removeGuardianInfo(id: String) async throws {
        try await repo.removeGuardianInfo(id: id)
    }
    
    
    /**
     Adds a team to the list of teams the player is enrolled in.
     
     - Parameter id: The unique player document ID.
     - Parameter teamId: The team ID to add to the player's list of enrolled teams.
     - Throws: An error if updating the document fails.
     */
    public func addTeamToPlayer(id: String, teamId: String) async throws {
        try await repo.addTeamToPlayer(id: id, teamId: teamId)
    }
    
    /**
    DELETE - Removes a team ID from the 'teamsEnrolled' array in Firestore.
    - Parameter id: The unique player document ID.
    - Parameter teamId: The team ID to remove from the player's list of enrolled teams.
    - Throws: An error if updating the document fails.
    */
    public func removeTeamFromPlayer(id: String, teamId: String) async throws {
        try await repo.removeTeamFromPlayer(id: id, teamId: teamId)
    }
    
    
    /**
    DELETE - Removes a team ID from the 'teamsEnrolled' array in Firestore.
    - Parameter id: The unique player document ID.
    - Parameter teamId: The team ID to remove from the player's list of enrolled teams.
    - Throws: An error if updating the document fails.
    */
    public func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws {
        try await repo.removeTeamFromPlayerWithTeamDocId(id: id, teamDocId: teamDocId)
    }
    
    
    /**
     DELETE - Removes the guardian's name from the player's document in Firestore.
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    public func removeGuardianInfoName(id: String) async throws {
        try await repo.removeGuardianInfoName(id: id)
    }
    
    
    /**
     DELETE - Removes the guardian's email address from the player's document in Firestore.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    public func removeGuardianInfoEmail(id: String) async throws {
        try await repo.removeGuardianInfoEmail(id: id)
    }
    
    
    /**
     DELETE - Removes the guardian's phone number from the player's document in Firestore.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    public func removeGuardianInfoPhone(id: String) async throws {
        try await repo.removeGuardianInfoPhone(id: id)
    }
    
    
    /**
     PUT - Updates the player's information in Firestore.
     
     - Parameter player: A `DBPlayer` object containing updated player information.
     - Throws: An error if updating the document fails.
     */
    public func updatePlayerInfo(player: DBPlayer) async throws {
        try await repo.updatePlayerInfo(player: player)
    }
    
    
    /// Updates a player's settings in the database with any provided non-nil values.
    /// - Parameters:
    ///   - id: The unique identifier of the player document to update.
    ///   - jersey: Optional updated jersey number.
    ///   - nickname: Optional updated nickname.
    ///   - guardianName: Optional updated guardian's name.
    ///   - guardianEmail: Optional updated guardian's email address.
    ///   - guardianPhone: Optional updated guardian's phone number.
    ///   - gender: Optional updated gender.
    /// - Throws: Rethrows any errors that occur during the Firestore update operation.
    public func updatePlayerSettings(id: String, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) async throws {

        try await repo.updatePlayerSettings(
            id: id,
            guardianName: guardianName,
            guardianEmail: guardianEmail,
            guardianPhone: guardianPhone,
            gender: gender
        )
    }
    
    
    /**
     PUT - Updates the player's jersey number and nickname in Firestore.
     
     - Parameter playerDocId: The unique player document ID.
     - Parameter jersey: The new jersey number for the player.
     - Parameter nickname: The new nickname for the player.
     - Throws: An error if updating the document fails.
     */
//    public func updatePlayerJerseyAndNickname(playerDocId: String, jersey: Int, nickname: String) async throws {
//        try await repo.updatePlayerJerseyAndNickname(playerDocId: playerDocId, jersey: jersey, nickname: nickname)
//    }
    
    
    /**
     PUT - Updates the player's unique ID in Firestore.
     
     - Parameter id: The unique player document ID.
     - Parameter playerId: The new player ID.
     - Throws: An error if updating the document fails.
     */
    public func updatePlayerId(id: String, playerId: String) async throws {
        try await repo.updatePlayerId(id: id, playerId: playerId)
    }
    
    
    /**
     PUT - Updates the player's unique ID in Firestore.
     
     - Parameter id: The unique player document ID.
     - Parameter playerId: The new player ID.
     - Throws: An error if updating the document fails.
     */
    public func getTeamsEnrolled(playerId: String) async throws -> [GetTeam] {
        return try await repo.getTeamsEnrolled(playerId: playerId)
    }
    
    
    /**
     GET - Fetches all teams that the player is enrolled in as full `DBTeam` objects.
     
     - Parameter playerId: The player's ID used to retrieve enrolled teams.
     - Returns: An array of `DBTeam` objects representing the full team data.
     - Throws: An error if fetching the player's document or teams fails.
     */
    public func getAllTeamsEnrolled(playerId: String) async throws -> [DBTeam]? {
        return try await repo.getAllTeamsEnrolled(playerId: playerId)
    }
    
    
    /**
     GET - Checks if the player is enrolled in a specific team.
     
     - Parameter playerId: The player's ID used to check enrollment.
     - Parameter teamId: The team ID to check for enrollment.
     - Returns: A boolean indicating whether the player is enrolled in the team.
     - Throws: An error if fetching the player's document fails.
     */
    public func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
        return try await repo.isPlayerEnrolledToTeam(playerId: playerId, teamId: teamId)
    }
}

struct PlayerName {
    let playerId: String
    let firstName: String
    let lastName: String
}
