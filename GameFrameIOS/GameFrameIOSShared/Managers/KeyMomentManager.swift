//
//  KeyMomentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation

/**
  The `KeyMomentManager` class is responsible for managing and interacting with the key moments
  of games in the Firestore database. It provides methods for CRUD (Create, Read, Update, Delete)
  operations on key moments, allowing you to fetch, add, and remove key moments from the database.

  This class uses Firestore document and collection references to handle the interaction with
  the Firestore database efficiently. It also provides methods to retrieve key moment documents
  and collections based on team and game IDs.

  Key Features:
  - Singleton pattern ensures only one instance of `KeyMomentManager` is used throughout the app.
  - Provides methods to fetch specific key moments, all key moments for a game, and add or delete
    key moments from Firestore.
  - Uses async/await pattern for asynchronous database operations.
  - Interacts with `TeamManager` to ensure team documents exist before performing any operations.
*/
public final class KeyMomentManager {
        
    private let repo: KeyMomentRepository
    
    public init(repo: KeyMomentRepository) {
        self.repo = repo
    }
    
    
    /**
     Fetches a specific key moment document from the database using the team ID, game ID, and key moment document ID.
     - Parameters:
        - teamId: The team’s ID to locate the associated team document in Firestore.
        - gameId: The ID of the game to locate the associated game document in Firestore.
        - keyMomentDocId: The ID of the key moment document to fetch.
     - Returns: An optional `DBKeyMoment` object that represents the key moment document, or `nil` if not found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team, game, or key moment document).
     */
    public func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return try await repo.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentDocId)
    }
    
    
    /// Assigns a player to key moments for the entire team if the feedback list
    /// already has the expected number of players but does not include this player.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - playersCount: The expected number of players in the team.
    ///   - playerId: The ID of the player to be added to the key moment’s feedback list.
    /// - Throws: Rethrows any error that occurs while fetching key moments
    ///   or updating a key moment’s feedback field in Firestore.
    /// - Returns: Nothing. The function is `async` and `throws` but has no return value.
    public func assignPlayerToKeyMomentsForEntireTeam(teamDocId: String, gameId: String, playersCount: Int, playerId: String) async throws {
        try await repo.assignPlayerToKeyMomentsForEntireTeam(teamDocId: teamDocId, gameId: gameId, playersCount: playersCount, playerId: playerId)
    }
    
    
    /**
     Fetches a specific key moment document using the document IDs for the team, game, and key moment.
     - Parameters:
        - teamDocId: The document ID for the team in Firestore.
        - gameDocId: The document ID for the game in Firestore.
        - keyMomentDocId: The document ID for the key moment to fetch.
     - Returns: An optional `DBKeyMoment` object representing the key moment document, or `nil` if not found.
     - Throws: Errors may be thrown if Firestore operations fail.
     */
    public func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return try await repo.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameDocId, keyMomentDocId: keyMomentDocId)
    }

    
    /// Fetches the audio URL associated with a specific key moment in a game.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team to which the game belongs.
    ///   - gameDocId: The document ID of the game containing the key moment.
    ///   - keyMomentId: The document ID of the key moment for which to fetch the audio URL.
    /// - Returns: The `audioUrl` string of the key moment if found, or `nil` if the key moment does not exist.
    /// - Throws: Rethrows any errors encountered while fetching the key moment from the database.
    /// - Note: This function performs an asynchronous fetch for the key moment using `getKeyMoment`.
    ///         If no key moment is found, it prints a debug message and returns `nil`.
    public func getAudioUrl(teamDocId: String, gameDocId: String, keyMomentId: String) async throws -> String? {
        return try await repo.getAudioUrl(teamDocId: teamDocId, gameDocId: gameDocId, keyMomentId: keyMomentId)
    }
    
    
    /**
     Fetches all the key moments for a specific game and team.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - gameId: The ID of the game to locate the game document in Firestore.
     - Returns: An optional array of `DBKeyMoment` objects representing all key moments in the game, or `nil` if no key moments are found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team or game document).
     */
    public func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return try await repo.getAllKeyMoments(teamId: teamId, gameId: gameId)
    }
    
    
    /**
     Fetches all the key moments for a specific game and team.
     - Parameters:
        - teamDocId: The tea's document ID in Firestore.
        - gameId: The ID of the game to locate the game document in Firestore.
     - Returns: An optional array of `DBKeyMoment` objects representing all key moments in the game, or `nil` if no key moments are found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team or game document).
     */
    public func getAllKeyMomentsWithTeamDocId(teamDocId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return try await repo.getAllKeyMomentsWithTeamDocId(teamDocId: teamDocId, gameId: gameId)
    }
    
    
    /**
     Adds a new key moment to the Firestore database under a specific team and game.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - keyMomentDTO: The data transfer object (`KeyMomentDTO`) representing the key moment to add.
     - Returns: The document ID of the newly created key moment document, or `nil` if the key moment could not be added.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team document or database write failure).
     */
    public func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String? {
        return try await repo.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
    }
    
    
    /**
     Removes a specific key moment document from the Firestore database.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - gameId: The game’s ID to locate the game document in Firestore.
        - keyMomentId: The ID of the key moment document to delete.
     - Returns: This function does not return any value.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing documents or deletion failure).
     */
    public func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws {
        try await repo.removeKeyMoment(teamId: teamId, gameId: gameId, keyMomentId: keyMomentId)
    }
    
    
    /// Adds a player ID to the `feedbackFor` field of a key moment document in Firestore.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - keyMomentId: The Firestore document ID of the key moment being updated.
    ///   - newPlayerId: The ID of the player to be added to the `feedbackFor` array field.
    /// - Throws: Rethrows any error that occurs while updating the Firestore document.
    /// - Returns: Nothing. The function is `async` and `throws` but has no return value.
    public func addPlayerToFeedbackFor(teamDocId: String, gameId: String, keyMomentId: String, newPlayerId: String) async throws {
        try await repo.addPlayerToFeedbackFor(teamDocId: teamDocId, gameId: gameId, keyMomentId: keyMomentId, newPlayerId: newPlayerId)
    }
    
    /// Deletes all key moment documents for a specific game within a team.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team containing the game.
    ///   - gameId: The document ID of the game whose key moments should be deleted.
    /// - Throws: Rethrows any errors encountered while fetching or deleting the documents from Firestore.
    /// - Note: This function fetches all documents in the key moments collection for the specified game
    ///         and deletes them one by one. If the collection is large, consider using batch deletes
    ///         or pagination to avoid performance issues.
    public func deleteAllKeyMoments(teamDocId: String, gameId: String) async throws {
        try await repo.deleteAllKeyMoments(teamDocId: teamDocId, gameId: gameId)
    }
    
    
    /// Updates the list of players who received feedback for a transcript.
    ///
    /// - Parameters:
    ///   - transcriptId: The transcript identifier.
    ///   - gameId: The game identifier.
    ///   - teamId: The team identifier.
    ///   - teamDocId: Firestore document ID for the team.
    ///   - feedbackFor: List of players to save as feedback recipients.
    ///
    /// - Throws: If fetching the transcript or updating Firestore fails.
    public func updateFeedbackFor(
        transcriptId: String,
        gameId: String,
        teamId: String,
        teamDocId: String,
        feedbackFor: [PlayerNameAndPhoto]
    ) async throws {
        try await repo.updateFeedbackFor(transcriptId: transcriptId, gameId: gameId, teamId: teamId, teamDocId: teamDocId, feedbackFor: feedbackFor)
    }
}


