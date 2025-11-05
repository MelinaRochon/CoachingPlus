//
//  LocalGameRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// A mock implementation of `GameRepository` used for local testing.
/// Stores game data in memory instead of Firestore.
public final class LocalGameRepository: GameRepository {
    
    /// In-memory storage for all games.
    private var games: [DBGame] = []
    
    public init(games: [DBGame]? = nil) {
        // If no teams provided, fallback to default JSON
        self.games = games ?? TestDataLoader.load("TestGames", as: [DBGame].self)
    }

    /// Retrieves a specific game matching the given `gameId` and `teamId`.
    /// - Parameters:
    ///   - gameId: The ID of the game to retrieve.
    ///   - teamId: The ID of the team that owns the game.
    /// - Returns: The matching `DBGame`, or `nil` if not found.
    public func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        guard let game = games.first(where: { $0.gameId == gameId && $0.teamId == teamId }) else {
            throw GameError.gameNotFound
        }
        return game
    }
    
    /// Fetches a specific game by its Firestore document IDs.
    /// - Parameters:
    ///   - gameDocId: The document ID of the game.
    ///   - teamDocId: The document ID of the team.
    /// - Returns: A decoded `DBGame`, or `nil` if no match is found.
    public func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame? {
        guard let game = games.first(where: { $0.gameId == gameDocId }) else {
            throw GameError.gameNotFound
        }
        return game
    }
    

    /// Deletes all games for a given team from local memory.
    /// - Parameter teamDocId: The document ID of the team whose games should be deleted.
    public func deleteAllGames(teamDocId: String) async throws {
        let team = try await LocalTeamRepository().getTeamWithDocId(docId: teamDocId)
        return games.removeAll(where: { $0.teamId == team.teamId })
    }
    
    /// Fetches all locally stored games for a given team.
    /// - Parameter teamId: The team ID whose games should be returned.
    /// - Returns: An array of matching `DBGame` objects.
    public func getAllGames(teamId: String) async throws -> [DBGame]? {
        return games.filter { $0.teamId == teamId }
    }
    
    /// Creates and adds a new game using the provided `GameDTO`.
    /// - Parameter gameDTO: The data transfer object containing new game details.
    public func addNewGame(gameDTO: GameDTO) async throws {
        let id = UUID().uuidString
        let game = DBGame(gameId: id, gameDTO: gameDTO)
        games.append(game)
    }
    
    /// Creates a new placeholder (unknown) game entry for a given team.
    /// Used when scheduling or recording a game before full details are known.
    /// - Parameter teamId: The ID of the team associated with the game.
    /// - Returns: The generated game ID for the new entry.
    public func addNewUnkownGame(teamId: String) async throws -> String? {
        let id = UUID().uuidString
        let game = DBGame(gameId: id, teamId: teamId)
        games.append(game)
        return id
    }
    
    /// Updates the duration of a specific game.
    /// - Parameters:
    ///   - gameId: The ID of the game to update.
    ///   - teamDocId: The document ID of the team (unused in local mode).
    ///   - duration: The new duration in minutes.
    public func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws {
        guard let index = games.firstIndex(where: { $0.gameId == gameId}) else {
            throw GameError.gameNotFound
        }
        games[index].duration = duration
    }
    
    /// Updates the title of a specific game.
    /// - Parameters:
    ///   - gameId: The ID of the game to update.
    ///   - teamDocId: The document ID of the team (unused in local mode).
    ///   - title: The new title to assign to the game.
    public func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws {
        guard let index = games.firstIndex(where: { $0.gameId == gameId}) else {
            throw GameError.gameNotFound
        }
        games[index].title = title
    }
    
    /// Updates multiple optional fields of a scheduled game.
    /// Only non-nil values will overwrite existing properties.
    /// - Parameters:
    ///   - id: The ID of the game to update.
    ///   - teamDocId: The document ID of the team (unused in local mode).
    ///   - title: Optional new title.
    ///   - startTime: Optional new start time.
    ///   - duration: Optional new duration.
    ///   - timeBeforeFeedback: Optional time before feedback reminders.
    ///   - timeAfterFeedback: Optional time after feedback reminders.
    ///   - recordingReminder: Optional flag indicating if recording reminders are enabled.
    ///   - location: Optional location string.
    ///   - scheduledTimeReminder: Optional time interval for pre-game reminders.
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
        guard let index = games.firstIndex(where: { $0.gameId == id }) else {
            throw GameError.gameNotFound
        }
        if let title = title {
            games[index].title = title
        }
        if let startTime = startTime {
            games[index].startTime = startTime
        }
        if let duration = duration {
            games[index].duration = duration
        }
        if let timeBeforeFeedback = timeBeforeFeedback {
            games[index].timeBeforeFeedback = timeBeforeFeedback
        }
        if let timeAfterFeedback = timeAfterFeedback {
            games[index].timeAfterFeedback = timeAfterFeedback
        }
        if let recordingReminder = recordingReminder {
            games[index].recordingReminder = recordingReminder
        }
        if let location = location {
            games[index].location = location
        }
        if let scheduledTimeReminder = scheduledTimeReminder {
            games[index].scheduledTimeReminder = scheduledTimeReminder
        }
    }
    
    /// Deletes a specific game from the local in-memory repository.
    /// - Parameters:
    ///   - gameId: The ID of the game to delete.
    ///   - teamDocId: The team’s document ID (unused locally).
    public func deleteGame(gameId: String, teamDocId: String) async throws {
        // Find the index of the game that matches the given gameId
        guard let index = games.firstIndex(where: { $0.gameId == gameId}) else {
            throw GameError.gameNotFound
        }
        games.remove(at: index)
    }
}
