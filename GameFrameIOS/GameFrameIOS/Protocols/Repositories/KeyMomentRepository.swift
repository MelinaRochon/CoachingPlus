//
//  KeyMomentRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository protocol for managing key moments within games and teams.
/// Provides methods for retrieving, creating, updating, and deleting key moments and related data.
protocol KeyMomentRepository {
    
    /// Retrieves a specific key moment for a given team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - keyMomentDocId: The Firestore document ID of the key moment to retrieve.
    /// - Throws: An error if the key moment cannot be fetched or does not exist.
    func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment?
    
    /// Assigns a player to all key moments for an entire team in a specific game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - playersCount: The total number of players on the team.
    ///   - playerId: The Firestore document ID of the player being assigned.
    /// - Throws: An error if the assignment process fails.
    func assignPlayerToKeyMomentsForEntireTeam(teamDocId: String, gameId: String, playersCount: Int, playerId: String) async throws
    
    /// Retrieves a key moment document by its Firestore document ID.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameDocId: The Firestore document ID of the game.
    ///   - keyMomentDocId: The Firestore document ID of the key moment.
    /// - Returns: A `DBKeyMoment` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment?
    
    /// Retrieves the download URL for a key moment’s associated audio file.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameDocId: The Firestore document ID of the game.
    ///   - keyMomentId: The Firestore document ID of the key moment.
    /// - Returns: A string containing the audio file's download URL, or `nil` if not available.
    /// - Throws: An error if the URL cannot be retrieved.
    func getAudioUrl(teamDocId: String, gameDocId: String, keyMomentId: String) async throws -> String?
    
    /// Retrieves all key moments for a specific team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    /// - Returns: An array of `DBKeyMoment` objects, or `nil` if none exist.
    /// - Throws: An error if retrieval fails.
    func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]?
    
    /// Retrieves all key moments for a specific team document and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    /// - Returns: An array of `DBKeyMoment` objects, or `nil` if none exist.
    /// - Throws: An error if retrieval fails.
    func getAllKeyMomentsWithTeamDocId(teamDocId: String, gameId: String) async throws -> [DBKeyMoment]?
    
    /// Adds a new key moment to a team’s game collection.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - keyMomentDTO: A data transfer object containing the key moment’s details.
    /// - Returns: The Firestore document ID of the newly created key moment, or `nil` if creation fails.
    /// - Throws: An error if adding the key moment fails.
    func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String?
    
    /// Removes a specific key moment from a team’s game collection.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - keyMomentId: The Firestore document ID of the key moment to remove.
    /// - Throws: An error if the deletion fails.
    func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws
    
    /// Adds a new player to the feedback section of a specific key moment.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - keyMomentId: The Firestore document ID of the key moment.
    ///   - newPlayerId: The Firestore document ID of the player to add to the feedback list.
    /// - Throws: An error if the update fails.
    func addPlayerToFeedbackFor(teamDocId: String, gameId: String, keyMomentId: String, newPlayerId: String) async throws
    
    /// Deletes all key moments associated with a specific team and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    /// - Throws: An error if deletion fails.
    func deleteAllKeyMoments(teamDocId: String, gameId: String) async throws
    
    /// Updates the feedback data for a specific key moment transcript.
    /// - Parameters:
    ///   - transcriptId: The Firestore document ID of the transcript.
    ///   - gameId: The Firestore document ID of the game.
    ///   - teamId: The unique identifier of the team.
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - feedbackFor: An array of `PlayerNameAndPhoto` objects representing updated feedback recipients.
    /// - Throws: An error if the feedback update fails.
    func updateFeedbackFor(transcriptId: String, gameId: String, teamId: String, teamDocId: String, feedbackFor: [PlayerNameAndPhoto]) async throws
}
