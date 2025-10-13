//
//  LocalGameRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
@testable import GameFrameIOS

/// A mock implementation of `GameRepository` used for local testing.
/// Stores game data in memory instead of Firestore.
final class LocalGameRepository: GameRepository {
    
    /// In-memory storage for all games.
    private var games: [DBGame] = []
    
    /// Retrieves a specific game matching the given `gameId` and `teamId`.
    /// - Parameters:
    ///   - gameId: The ID of the game to retrieve.
    ///   - teamId: The ID of the team that owns the game.
    /// - Returns: The matching `DBGame`, or `nil` if not found.
    func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        return games.first(where: { $0.gameId == gameId && $0.teamId == teamId })
    }
    
    /// Fetches a specific game by its Firestore document IDs.
    /// - Parameters:
    ///   - gameDocId: The document ID of the game.
    ///   - teamDocId: The document ID of the team.
    /// - Returns: A decoded `DBGame`, or `nil` if no match is found.
    func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame? {
        return games.first(where: { $0.gameId == gameDocId })
    }
    

    /// Deletes all games for a given team from local memory.
    /// - Parameter teamDocId: The document ID of the team whose games should be deleted.
    func deleteAllGames(teamDocId: String) async throws {
        return games.removeAll()
    }
    
    /// Fetches all locally stored games for a given team.
    /// - Parameter teamId: The team ID whose games should be returned.
    /// - Returns: An array of matching `DBGame` objects.
    func getAllGames(teamId: String) async throws -> [DBGame]? {
        return games.filter { $0.teamId == teamId }
    }
    
    /// Creates and adds a new game using the provided `GameDTO`.
    /// - Parameter gameDTO: The data transfer object containing new game details.
    func addNewGame(gameDTO: GameDTO) async throws {
        let id = UUID().uuidString
        let game = DBGame(gameId: id, gameDTO: gameDTO)
        games.append(game)
    }
    
    /// Creates a new placeholder (unknown) game entry for a given team.
    /// Used when scheduling or recording a game before full details are known.
    /// - Parameter teamId: The ID of the team associated with the game.
    /// - Returns: The generated game ID for the new entry.
    func addNewUnkownGame(teamId: String) async throws -> String? {
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
    func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws {
        if let index = games.firstIndex(where: { $0.gameId == gameId}) {
            games[index].duration = duration
        }
    }
    
    /// Updates the title of a specific game.
    /// - Parameters:
    ///   - gameId: The ID of the game to update.
    ///   - teamDocId: The document ID of the team (unused in local mode).
    ///   - title: The new title to assign to the game.
    func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws {
        if let index = games.firstIndex(where: { $0.gameId == gameId }) {
            games[index].title = title
        }
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
    ) async throws {
        if let index = games.firstIndex(where: { $0.gameId == id }) {
            var game = games[index]
            game.title = title ?? ""
            game.startTime = startTime
            game.duration = duration ?? 0
            game.timeBeforeFeedback = timeBeforeFeedback ?? 10
            game.timeAfterFeedback = timeAfterFeedback ?? 10
            game.recordingReminder = recordingReminder ?? false
            game.location = location
            game.scheduledTimeReminder = scheduledTimeReminder ?? 0
        }
    }
    
    /// Deletes a specific game from the local in-memory repository.
    /// - Parameters:
    ///   - gameId: The ID of the game to delete.
    ///   - teamDocId: The team’s document ID (unused locally).
    func deleteGame(gameId: String, teamDocId: String) async throws {
        // Find the index of the game that matches the given gameId
        if let index = games.firstIndex(where: { $0.gameId == gameId }) {
            games.remove(at: index)
        } else {
            print("⚠️ Game with ID \(gameId) not found. Nothing to delete.")
        }
    }
}
