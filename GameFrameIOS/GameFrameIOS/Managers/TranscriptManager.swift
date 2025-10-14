//
//  TranscriptManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

/// Manages transcript storage, retrieval, and deletion in Firestore.
final class TranscriptManager {
    
    private let repo: TranscriptRepository
    
    init(repo: TranscriptRepository = FirestoreTranscriptRepository()) {
        self.repo = repo
    }
    

    /// Retrieves a specific transcript from Firestore.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    ///   - transcriptId: The ID of the transcript.
    /// - Returns: A `DBTranscript` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript? {
        return try await repo.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
    }
    

    /// Retrieves all transcripts for a specific game.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    /// - Returns: An array of `DBTranscript` objects.
    /// - Throws: An error if the retrieval fails.
    func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]? {
        return try await repo.getAllTranscripts(teamId: teamId, gameId: gameId)
    }
    
    
    func getTranscriptsPreviewWithDocId(teamDocId: String, gameId: String) async throws -> [DBTranscript]? {
        return try await repo.getTranscriptsPreviewWithDocId(teamDocId: teamDocId, gameId: gameId)
    }
    

    /// Retrieves all transcripts for a game using document IDs.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    /// - Returns: An array of `DBTranscript` objects.
    /// - Throws: An error if the retrieval fails.
    func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]? {
        return try await repo.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameDocId)
    }
        
    
    /// Adds a new transcript to Firestore.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - transcriptDTO: The data transfer object containing transcript details.
    /// - Returns: The newly generated transcript ID, or `nil` if the operation fails.
    /// - Throws: An error if the save operation fails.
    func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws -> String?{
        try await repo.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO)
    }
    
    
    /// Deletes a transcript from Firestore for the given team and game.
    ///
    /// - Parameters:
    ///   - teamId: The team identifier.
    ///   - gameId: The game identifier.
    ///   - transcriptId: The transcript identifier to remove.
    ///
    /// - Throws: If the team cannot be found or the delete operation fails.
    func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        try await repo.removeTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
    }
    
    
    /// Deletes all transcript documents for a specific game within a team.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team containing the game.
    ///   - gameId: The document ID of the game whose transcripts should be deleted.
    /// - Throws: Rethrows any errors encountered while fetching or deleting the documents from Firestore.
    /// - Note: This function fetches all documents in the transcript collection for the specified game
    ///         and deletes them one by one. If the collection is large, consider using batch deletes
    ///         or pagination to avoid performance issues.
    func deleteAllTranscripts(teamDocId: String, gameId: String) async throws {
        try await repo.deleteAllTranscripts(teamDocId: teamDocId, gameId: gameId)
    }
    
    
    /// Updates the transcript text in Firestore for a given game and team.
    ///
    /// - Parameters:
    ///   - teamDocId: Firestore document ID for the team.
    ///   - gameId: Identifier for the game.
    ///   - transcriptId: Identifier for the transcript to update.
    ///   - transcript: The new transcript text to save.
    ///
    /// - Throws: If the Firestore update fails.
    func updateTranscript(teamDocId: String, gameId: String, transcriptId: String, transcript: String) async throws {
        try await repo.updateTranscript(teamDocId: teamDocId, gameId: gameId, transcriptId: transcriptId, transcript: transcript)
    }
}
