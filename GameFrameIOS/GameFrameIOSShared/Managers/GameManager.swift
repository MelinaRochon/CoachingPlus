//
//  GameManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import Foundation

/**
 The `GameManager` class is responsible for managing game-related operations in the Firestore database. It provides
 methods to add, update, retrieve, and manage games for a specific team. This class uses Firestore's `DocumentReference`
 and `CollectionReference` to interact with the database.

 Key responsibilities of the `GameManager` class include:
 - Retrieving specific game documents and collections.
 - Fetching all games for a specific team.
 - Adding new games to the Firestore database.
 - Updating existing games (e.g., updating game duration).
 
 The class follows the Singleton design pattern, which means there is only one instance of this class in the application.
 The singleton instance can be accessed via the `shared` static property.

 This class acts as a centralized manager for game-related database operations, ensuring that the app can seamlessly
 retrieve and modify game data for specific teams.
 */
public final class GameManager {
    
    private let repo: GameRepository
        
    public init(repo: GameRepository) {
        self.repo = repo
    }
        
    
    /**
     Retrieves a specific game document from Firestore based on the game ID and team ID.
     - Parameters:
        - gameId: The unique identifier of the game document.
        - teamId: The unique identifier of the team to which the game belongs.
     - Returns:
        An optional `DBGame` object representing the game retrieved from Firestore, or `nil` if the game cannot be found.
        The function throws an error if there's an issue retrieving the document.
     */
    public func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        return try await repo.getGame(gameId: gameId, teamId: teamId)
    }
    
    
    /**
     Retrieves a specific game document from Firestore using its document ID and the team document ID.
     - Parameters:
        - gameDocId: The unique document ID of the game to retrieve.
        - teamDocId: The unique ID of the team document containing the game document.
     - Returns:
        An optional `DBGame` object representing the game retrieved from Firestore, or `nil` if the game cannot be found.
        The function throws an error if there's an issue retrieving the document.
     */
    public func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame? {
        return try await repo.getGameWithDocId(gameDocId: gameDocId, teamDocId: teamDocId)
    }
    
    
    

    /// Deletes all games documents for a specific game within a team.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team containing the game.
    /// - Throws: Rethrows any errors encountered while fetching or deleting the documents from Firestore.
    /// - Note: This function fetches all documents in the games collection for the specified game
    ///         and deletes them one by one. If the collection is large, consider using batch deletes
    ///         or pagination to avoid performance issues.
    public func deleteAllGames(teamDocId: String) async throws {
        try await repo.deleteAllGames(teamDocId: teamDocId)
    }
    
    /**
     Retrieves all games for a specific team from Firestore.
     - Parameters:
        - teamId: The unique identifier of the team whose games are to be retrieved.
     - Returns:
        An optional array of `DBGame` objects representing all the games found for the given team, or `nil` if no games are found.
        The function throws an error if the retrieval process encounters an issue.
     */
    public func getAllGames(teamId: String) async throws -> [DBGame]? {
        return try await repo.getAllGames(teamId: teamId)
    }
                
    
    /**
     Adds a new game to Firestore based on the provided `GameDTO`.
     - Parameters:
        - gameDTO: The data transfer object (`GameDTO`) containing the details of the game to be added.
     - Returns:
        This function does not return a value. It performs an asynchronous operation that adds the new game to Firestore.
        The function throws an error if there is an issue while adding the game.
     */
    public func addNewGame(gameDTO: GameDTO) async throws {
        return try await repo.addNewGame(gameDTO: gameDTO)
    }
    
    
    /**
     Adds a new "Unknown Game" (a game with default values) to Firestore for a given team.
     - Parameters:
        - teamId: The unique identifier of the team for which the unknown game is to be created.
     - Returns:
        A string representing the `gameId` of the newly created "Unknown Game" if successful, or `nil` if the creation failed.
        This function throws an error if there's an issue during the process.
     */
    public func addNewUnkownGame(teamId: String) async throws -> String? {
        return try await repo.addNewUnkownGame(teamId: teamId)
    }
    
    
    /**
     Updates the duration of a specific game in Firestore.
     - Parameters:
        - gameId: The unique identifier of the game whose duration needs to be updated.
        - teamDocId: The ID of the team document that owns the game.
        - duration: The new duration (in seconds) to set for the game.
     - Returns:
        This function does not return a value. It performs an asynchronous operation that updates the game’s duration in Firestore.
        It throws an error if the update operation fails.
     */
    public func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws {
        return try await repo.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: teamDocId, duration: duration)
    }
    
    
    public func updateGameStartTimeUsingTeamDocId(gameId: String, teamDocId: String, startTime: Date) async throws {
        try await repo.updateGameStartTimeUsingTeamDocId(gameId: gameId, teamDocId: teamDocId, startTime: startTime)
    }
    
    
    /// Updates the title of a specific game document in Firestore (or the data source).
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game document to update.
    ///   - teamDocId: The unique identifier of the parent team document containing the game.
    ///   - title: The new title string to assign to the game.
    ///
    /// - Throws: Rethrows any errors that occur during the Firestore update operation.
    public func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws {
        try await repo.updateGameTitle(gameId: gameId, teamDocId: teamDocId, title: title)
    }
    
    
    /// Updates an existing scheduled game with new settings in the database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the game to update.
    ///   - teamDocId: The document ID of the team the game belongs to.
    ///   - title: The updated game title, or `nil` to leave unchanged.
    ///   - startTime: The updated game start time, or `nil` to leave unchanged.
    ///   - duration: The updated game duration in seconds, or `nil`.
    ///   - timeBeforeFeedback: The updated feedback reminder time before the event, in seconds, or `nil`.
    ///   - timeAfterFeedback: The updated feedback reminder time after the event, in seconds, or `nil`.
    ///   - recordingReminder: Whether recording reminders are enabled, or `nil`.
    ///   - location: The updated location string, or `nil`.
    ///   - scheduledTimeReminder: The updated pre-event reminder time in minutes, or `nil`.
    ///
    /// - Throws: An error if the game cannot be found or if the update fails.
    /// - Returns: Nothing. The function completes once the update is applied.
    public func updateScheduledGameSettings(
        id: String,
        teamDocId: String,
        title: String?,
        startTime: Date?,
        duration: Int?,
        timeBeforeFeedback: Int?,
        timeAfterFeedback: Int?,
        recordingReminder: Bool?,
        location: String?,
        scheduledTimeReminder: Int?
    ) async throws {
        try await repo.updateScheduledGameSettings(
            id: id,
            teamDocId: teamDocId,
            title: title,
            startTime: startTime,
            duration: duration,
            timeBeforeFeedback: timeBeforeFeedback,
            timeAfterFeedback: timeAfterFeedback,
            recordingReminder: recordingReminder,
            location: location,
            scheduledTimeReminder: scheduledTimeReminder
        )
    }
    
    
    /// Deletes a game document from the database.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game to delete.
    ///   - teamDocId: The unique identifier of the team document containing the game.
    /// - Throws: An error if the deletion fails.
    /// - Note: This only deletes the game document itself. Any subcollections (e.g., feedback, recordings) are **not** automatically deleted.
    public func deleteGame(gameId: String, teamDocId: String) async throws {
        try await repo.deleteGame(gameId: gameId, teamDocId: teamDocId)
    }
}
