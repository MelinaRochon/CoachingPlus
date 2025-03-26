//
//  TranscriptManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

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

final class TranscriptManager {
    static let shared = TranscriptManager()
    
    private init() {} // TO DO - Will need to use something else than singleton

    /** Returns a transcript document */
    func transcriptDocument(teamDocId: String, gameDocId: String, transcriptId: String) -> DocumentReference {
        return transcriptCollection(teamDocId: teamDocId, gameDocId: gameDocId).document(transcriptId)
    }
    
    /** Returns the key moment collection */
    func transcriptCollection(teamDocId: String, gameDocId: String) -> CollectionReference {
        return GameManager.shared.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("transcripts")
    }
    
    /** GET - Returns a specific transcript document from the database */
    func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        return try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId).getDocument(as: DBTranscript.self)
    }
    
    /** GET - Returns all transcripts in the collection */
    func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTranscript.self)
        }
    }
    
    /** GET - Returns all transcripts in the collection */
    func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]? {
        
        // Get all documents in the transcript collection
        let snapshot = try await transcriptCollection(teamDocId: teamDocId, gameDocId: gameDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTranscript.self)
        }
    }
        
    /** POST - Add a new transcript to the database */
    func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws {
        // Make sure the collection path can be found
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }

        let transcriptDocument = transcriptCollection(teamDocId: teamDocId, gameDocId: transcriptDTO.gameId).document()
        let documentId = transcriptDocument.documentID // get the document id
        
        // create the transcript object
        let transcript = DBTranscript(transcriptId: documentId, transcriptDTO: transcriptDTO)
        
        // Add the transcript to the database
        try transcriptDocument.setData(from: transcript, merge: false)
    }
    
    /** DELETE - Remove a transcript from the database */
    func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }

        try await transcriptDocument(teamDocId: teamDocId, gameDocId: gameId, transcriptId: transcriptId).delete()
    }
}
