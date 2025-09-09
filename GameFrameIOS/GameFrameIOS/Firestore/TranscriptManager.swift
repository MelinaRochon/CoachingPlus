//
//  TranscriptManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

/// Represents a transcript stored in Firestore, linked to a key moment in a game.
struct DBTranscript: Codable {
    let transcriptId: String
    let keyMomentId: String
    let transcript: String // transcription
    let language: String // Language of the transcript - Only english for now
    let generatedBy: String
    let confidence: Int
    let gameId: String
    
    init(transcriptId: String, keyMomentId: String, transcript: String, language: String, generatedBy: String, confidence: Int, gameId: String) {
        self.transcriptId = transcriptId
        self.keyMomentId = keyMomentId
        self.transcript = transcript
        self.language = language
        self.generatedBy = generatedBy
        self.confidence = confidence
        self.gameId = gameId
    }
    
    init(transcriptId: String, transcriptDTO: TranscriptDTO) {
        self.transcriptId = transcriptId
        self.keyMomentId = transcriptDTO.keyMomentId
        self.transcript = transcriptDTO.transcript
        self.language = transcriptDTO.language
        self.generatedBy = transcriptDTO.generatedBy
        self.confidence = transcriptDTO.confidence
        self.gameId = transcriptDTO.gameId
    }
    
    enum CodingKeys: String, CodingKey {
        case transcriptId = "transcript_id"
        case keyMomentId = "key_moment_id"
        case transcript = "transcript"
        case language = "language"
        case generatedBy = "generated_by"
        case confidence = "confidence"
        case gameId = "game_id"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transcriptId = try container.decode(String.self, forKey: .transcriptId)
        self.keyMomentId = try container.decode(String.self, forKey: .keyMomentId)
        self.transcript = try container.decode(String.self, forKey: .transcript)
        self.language = try container.decode(String.self, forKey: .language)
        self.generatedBy = try container.decode(String.self, forKey: .generatedBy)
        self.confidence = try container.decode(Int.self, forKey: .confidence)
        self.gameId = try container.decode(String.self, forKey: .gameId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.transcriptId, forKey: .transcriptId)
        try container.encode(self.keyMomentId, forKey: .keyMomentId)
        try container.encode(self.transcript, forKey: .transcript)
        try container.encode(self.language, forKey: .language)
        try container.encode(self.generatedBy, forKey: .generatedBy)
        try container.encode(self.confidence, forKey: .confidence)
        try container.encode(self.gameId, forKey: .gameId)
    }
}

/// Manages transcript storage, retrieval, and deletion in Firestore.
final class TranscriptManager {
    
    /// Singleton instance of `TranscriptManager`.
    static let shared = TranscriptManager()
    
    /// Private initializer to enforce singleton usage.
    private init() {} // TO DO - Will need to replace singleton with dependency injection

    /// Returns a reference to a specific transcript document in Firestore.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    ///   - transcriptId: The document ID of the transcript.
    /// - Returns: A reference to the transcript document in Firestore.
    func transcriptDocument(teamDocId: String, gameDocId: String, transcriptId: String) -> DocumentReference {
        return transcriptCollection(teamDocId: teamDocId, gameDocId: gameDocId).document(transcriptId)
    }
    

    /// Returns a reference to the transcript collection for a given game.
    /// - Parameters:
    ///   - teamDocId: The document ID of the team.
    ///   - gameDocId: The document ID of the game.
    /// - Returns: A Firestore collection reference for transcripts.
    func transcriptCollection(teamDocId: String, gameDocId: String) -> CollectionReference {
        return GameManager.shared.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("transcripts")
    }
    

    /// Retrieves a specific transcript from Firestore.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    ///   - transcriptId: The ID of the transcript.
    /// - Returns: A `DBTranscript` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
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
    func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("getAllTranscripts: Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameId).getDocuments()
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
    func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]? {
        
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
    func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws -> String?{
        // Make sure the collection path can be found
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
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
    func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("removeTranscript: Could not find team id. Aborting")
            return
        }

        try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId).delete()
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
        let data: [String:Any?] = [
            DBTranscript.CodingKeys.transcript.rawValue: transcript
        ]
        
        try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId)
            .updateData(data as [AnyHashable : Any])
    }
}
