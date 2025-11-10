//
//  GameRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

public protocol GameRepository {
    
    /// Fetches a specific game document using a team’s Firestore document ID and a game ID.
    /// - Parameters:
    ///   - gameId: The unique identifier of the game.
    ///   - teamId: The unique identifier of the team (used to find its Firestore document).
    /// - Returns: A `DBGame` object if found, or `nil` if no matching game exists.
    func getGame(gameId: String, teamId: String) async throws -> DBGame?
    
    /// Fetches a specific game document using both Firestore document IDs (team and game).
    /// - Returns: A decoded `DBGame` object, or `nil` if the document doesn’t exist.
    func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame?
    
    /// Deletes all games for a team, including their related key moments and transcripts.
    func deleteAllGames(teamDocId: String) async throws
    
    /// Fetches all games belonging to a specific team.
    /// - Returns: An array of `DBGame` objects, or `nil` if the team could not be found.
    func getAllGames(teamId: String) async throws -> [DBGame]?
    
    /// Creates and adds a new game document to the Firestore "games" collection.
    /// - Parameter gameDTO: The data transfer object containing game details.
    func addNewGame(gameDTO: GameDTO) async throws
    
    /// Creates a new placeholder (unknown) game entry for a given team.
    /// Used when a game is scheduled or recorded without full details.
    /// - Returns: The generated Firestore document ID for the new game.
    func addNewUnkownGame(teamId: String) async throws -> String?
    
    /// Updates the duration field of a specific game document.
    func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws
    
    /// Updates the title of a specific game.
    func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws
    
    /// Updates multiple fields of a scheduled game document, such as title, duration, location, etc.
    /// Only non-nil parameters are included in the update.
    func updateScheduledGameSettings(
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
    ) async throws
    
    /// Deletes a specific game document from Firestore.
    func deleteGame(gameId: String, teamDocId: String) async throws
    
    func updateGameStartTimeUsingTeamDocId(gameId: String, teamDocId: String, startTime: Date) async throws
}
