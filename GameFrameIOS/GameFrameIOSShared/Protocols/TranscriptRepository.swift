//
//  TranscriptRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository responsible for managing transcript data within teams and games.
public protocol TranscriptRepository {
    
    /// Retrieves a specific transcript for a given team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - transcriptId: The unique identifier of the transcript.
    /// - Returns: A `DBTranscript` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript?

    /// Retrieves all transcripts associated with a specific team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    /// - Returns: An optional array of `DBTranscript` objects, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]?

    /// Retrieves lightweight transcript previews (e.g., metadata) for a specific team and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    /// - Returns: An optional array of `DBTranscript` objects containing preview information, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getTranscriptsPreviewWithDocId(teamDocId: String, gameId: String) async throws -> [DBTranscript]?

    /// Retrieves all transcripts for a given team and game using Firestore document identifiers.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameDocId: The Firestore document ID of the game.
    /// - Returns: An optional array of `DBTranscript` objects, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]?

    /// Adds a new transcript record to a team’s game collection.
    /// - Parameters:
    ///   - teamId: The Firestore document ID of the team.
    ///   - transcriptDTO: A data transfer object containing the transcript details to add.
    /// - Returns: The Firestore document ID of the newly created transcript, or `nil` if creation fails.
    /// - Throws: An error if the operation fails.
    func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws -> String?

    /// Removes a specific transcript from a team’s game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - transcriptId: The unique identifier of the transcript to remove.
    /// - Throws: An error if the deletion fails.
    func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws

    /// Deletes all transcripts for a given team and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    /// - Throws: An error if the deletion fails.
    func deleteAllTranscripts(teamDocId: String, gameId: String) async throws

    /// Updates the text content of a specific transcript.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - transcriptId: The unique identifier of the transcript to update.
    ///   - transcript: The new transcript text to store.
    /// - Throws: An error if the update fails.
    func updateTranscript(teamDocId: String, gameId: String, transcriptId: String, transcript: String) async throws
}
