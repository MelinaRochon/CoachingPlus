//
//  FirestoreTranscriptRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreTranscriptRepository: TranscriptRepository {
    
    /// Returns a reference to a specific transcript document in Firestore.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    ///   - transcriptId: The document ID of the transcript.
    /// - Returns: A reference to the transcript document in Firestore.
    public func transcriptDocument(teamDocId: String, gameDocId: String, transcriptId: String) -> DocumentReference {
        return transcriptCollection(teamDocId: teamDocId, gameDocId: gameDocId).document(transcriptId)
    }
    

    /// Returns a reference to the transcript collection for a given game.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    /// - Returns: A Firestore collection reference for transcripts.
    public func transcriptCollection(teamDocId: String, gameDocId: String) -> CollectionReference {
        let gameRepo = FirestoreGameRepository()
        return gameRepo.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("transcripts")
    }
    

    /// Retrieves a specific transcript from Firestore.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    ///   - transcriptId: The ID of the transcript.
    /// - Returns: A `DBTranscript` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    public func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("getTranscript: Could not find team id. Aborting")
            return nil
        }
        
        return try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId).getDocument(as: DBTranscript.self)
    }
    

    /// Retrieves all transcripts for a specific game.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    /// - Returns: An array of `DBTranscript` objects.
    /// - Throws: An error if the retrieval fails.
    public func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("getAllTranscripts: Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTranscript.self)
        }
    }
    
    
    public func getTranscriptsPreviewWithDocId(teamDocId: String, gameId: String) async throws -> [DBTranscript]? {
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameId)
            .limit(to: 3)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTranscript.self)
        }
    }
    

    /// Retrieves all transcripts for a game using document IDs.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    /// - Returns: An array of `DBTranscript` objects.
    /// - Throws: An error if the retrieval fails.
    public func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]? {
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTranscript.self)
        }
    }
        
    
    /// Adds a new transcript to Firestore.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - transcriptDTO: The data transfer object containing transcript details.
    /// - Returns: The newly generated transcript ID, or `nil` if the operation fails.
    /// - Throws: An error if the save operation fails.
    public func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws -> String?{
        // Make sure the collection path can be found
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("addNewTranscript: Could not find team id. Aborting")
            return nil
        }

        let transcriptDocument = transcriptCollection(teamDocId: teamDocId, gameDocId: transcriptDTO.gameId).document()
        let documentId = transcriptDocument.documentID // get the document id
        
        // create the transcript object
        let transcript = DBTranscript(transcriptId: documentId, transcriptDTO: transcriptDTO)
        
        do {
            // Add the transcript to the database
            try await transcriptDocument.setData(from: transcript, merge: false)
            print("Successfully added transcript with ID: \(documentId)")
            return documentId // ✅ Return the generated transcript ID
        } catch {
            print("Error saving transcript: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// Deletes a transcript from Firestore for the given team and game.
    ///
    /// - Parameters:
    ///   - teamId: The team identifier.
    ///   - gameId: The game identifier.
    ///   - transcriptId: The transcript identifier to remove.
    ///
    /// - Throws: If the team cannot be found or the delete operation fails.
    public func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("removeTranscript: Could not find team id. Aborting")
            return
        }

        try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId).delete()
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
    public func deleteAllTranscripts(teamDocId: String, gameId: String) async throws {
        let collectionRef = transcriptCollection(teamDocId: teamDocId, gameDocId: gameId)
        let snapshot = try await collectionRef.getDocuments()
        
        for document in snapshot.documents {
            try await collectionRef.document(document.documentID).delete()
        }
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
    public func updateTranscript(teamDocId: String, gameId: String, transcriptId: String, transcript: String) async throws {
        let data: [String:Any?] = [
            DBTranscript.CodingKeys.transcript.rawValue: transcript
        ]
        
        try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId)
            .updateData(data as [AnyHashable : Any])
    }
}
