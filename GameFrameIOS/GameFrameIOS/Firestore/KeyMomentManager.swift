//
//  KeyMomentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

/**
  This structure represents a "Key Moment" in a game, encapsulating key details related to specific moments
  captured during a game session. A "Key Moment" could be related to a video recording, transcription, or
  feedback related to a particular moment in the game. It includes details like the unique identifier for
  the moment, the game it's associated with, timestamps indicating the start and end of the moment,
  and optional feedback recipients, among other attributes.

  Properties:
  - `keyMomentId`: The unique identifier for the key moment, used for database operations.
  - `fullGameId`: (Optional) The full game ID if the key moment is linked to a video recording.
  - `gameId`: The ID of the game where this key moment is located.
  - `uploadedBy`: The user ID or name who uploaded the key moment.
  - `audioUrl`: (Optional) A URL to the audio associated with this key moment.
  - `frameStart`: The start date or timestamp of the transcription or key moment.
  - `frameEnd`: The end date or timestamp of the transcription or key moment.
  - `feedbackFor`: (Optional) An array of users or players who are receiving feedback for this key moment.
 */
struct DBKeyMoment: Codable {
    let keyMomentId: String
    let fullGameId: String? // Only applies if key moment is associated to a video recording
    let gameId: String
    let uploadedBy: String
    let audioUrl: String?
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [String]?
    
    // Initializer for setting up the DBKeyMoment object
    init(keyMomentId: String, fullGameId: String? = nil, gameId: String, uploadedBy: String, audioUrl: String? = nil, frameStart: Date, frameEnd: Date, feedbackFor: [String]? = nil) {
        self.keyMomentId = keyMomentId
        self.fullGameId = fullGameId
        self.gameId = gameId
        self.uploadedBy = uploadedBy
        self.audioUrl = audioUrl
        self.frameStart = frameStart
        self.frameEnd = frameEnd
        self.feedbackFor = feedbackFor
    }
    
    // Convert the DTO to a DBKeyMoment
    init(keyMomentId: String, keyMomentDTO: KeyMomentDTO) {
        self.keyMomentId = keyMomentId
        self.fullGameId = keyMomentDTO.fullGameId
        self.gameId = keyMomentDTO.gameId
        self.uploadedBy = keyMomentDTO.uploadedBy
        self.audioUrl = keyMomentDTO.audioUrl
        self.frameStart = keyMomentDTO.frameStart
        self.frameEnd = keyMomentDTO.frameEnd
        self.feedbackFor = keyMomentDTO.feedbackFor
    }
    
    // Enum for coding keys to map the JSON keys to properties
    enum CodingKeys: String, CodingKey {
        case keyMomentId = "key_moment_id"
        case fullGameId = "full_game_id"
        case gameId = "game_id"
        case uploadedBy = "uploaded_by"
        case audioUrl = "audio_url"
        case frameStart = "frame_start"
        case frameEnd = "frame_end"
        case feedbackFor = "feedback_for"
    }
    
    // Decoder for decoding the object from JSON
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyMomentId = try container.decode(String.self, forKey: .keyMomentId)
        self.fullGameId = try container.decodeIfPresent(String.self, forKey: .fullGameId)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.uploadedBy = try container.decode(String.self, forKey: .uploadedBy)
        self.audioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl)
        self.frameStart = try container.decode(Date.self, forKey: .frameStart)
        self.frameEnd = try container.decode(Date.self, forKey: .frameEnd)
        self.feedbackFor = try container.decodeIfPresent([String].self, forKey: .feedbackFor)
    }
    
    // Encoder for encoding the object to JSON
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.keyMomentId, forKey: .keyMomentId)
        try container.encodeIfPresent(self.fullGameId, forKey: .fullGameId)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.uploadedBy, forKey: .uploadedBy)
        try container.encodeIfPresent(self.audioUrl, forKey: .audioUrl)
        try container.encode(self.frameStart, forKey: .frameStart)
        try container.encode(self.frameEnd, forKey: .frameEnd)
        try container.encodeIfPresent(self.feedbackFor, forKey: .feedbackFor)
    }
}


/**
  The `KeyMomentManager` class is responsible for managing and interacting with the key moments
  of games in the Firestore database. It provides methods for CRUD (Create, Read, Update, Delete)
  operations on key moments, allowing you to fetch, add, and remove key moments from the database.

  This class uses Firestore document and collection references to handle the interaction with
  the Firestore database efficiently. It also provides methods to retrieve key moment documents
  and collections based on team and game IDs.

  Key Features:
  - Singleton pattern ensures only one instance of `KeyMomentManager` is used throughout the app.
  - Provides methods to fetch specific key moments, all key moments for a game, and add or delete
    key moments from Firestore.
  - Uses async/await pattern for asynchronous database operations.
  - Interacts with `TeamManager` to ensure team documents exist before performing any operations.
*/
final class KeyMomentManager {
    static let shared = KeyMomentManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    /**
     Returns a reference to a specific key moment document within the Firestore collection.
     - Parameters:
        - teamDocId: The unique document ID for the team in Firestore.
        - gameDocId: The unique document ID for the game in the team’s collection.
        - keyMomentDocId: The unique document ID for the key moment in the game’s collection.
     - Returns: A `DocumentReference` to the key moment document.
     */
    func keyMomentDocument(teamDocId: String, gameDocId: String, keyMomentDocId: String) -> DocumentReference {
        return keyMomentCollection(teamDocId: teamDocId, gameDocId: gameDocId).document(keyMomentDocId)
    }
    
    
    /**
     Returns a reference to the collection of key moments for a specific game under a team.
     - Parameters:
        - teamDocId: The unique document ID for the team in Firestore.
        - gameDocId: The unique document ID for the game in the team’s collection.
     - Returns: A `CollectionReference` pointing to the key moments sub-collection in Firestore.
     */
    func keyMomentCollection(teamDocId: String, gameDocId: String) -> CollectionReference {
        return GameManager.shared.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("key_moments")
    }
    
    
    /**
     Fetches a specific key moment document from the database using the team ID, game ID, and key moment document ID.
     - Parameters:
        - teamId: The team’s ID to locate the associated team document in Firestore.
        - gameId: The ID of the game to locate the associated game document in Firestore.
        - keyMomentDocId: The ID of the key moment document to fetch.
     - Returns: An optional `DBKeyMoment` object that represents the key moment document, or `nil` if not found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team, game, or key moment document).
     */
    func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("getKeyMoment: Could not find team id. Aborting")
            return nil
        }
        
        return try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId).getDocument(as: DBKeyMoment.self)
    }
    
    
    /**
     Fetches a specific key moment document using the document IDs for the team, game, and key moment.
     - Parameters:
        - teamDocId: The document ID for the team in Firestore.
        - gameDocId: The document ID for the game in Firestore.
        - keyMomentDocId: The document ID for the key moment to fetch.
     - Returns: An optional `DBKeyMoment` object representing the key moment document, or `nil` if not found.
     - Throws: Errors may be thrown if Firestore operations fail.
     */
    func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameDocId, keyMomentDocId: keyMomentDocId).getDocument(as: DBKeyMoment.self)
    }
    
    
    /**
     Fetches all the key moments for a specific game and team.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - gameId: The ID of the game to locate the game document in Firestore.
     - Returns: An optional array of `DBKeyMoment` objects representing all key moments in the game, or `nil` if no key moments are found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team or game document).
     */
    func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("getAllKeyMoments: Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the key moment collection
        let snapshot = try await keyMomentCollection(teamDocId: teamDocId, gameDocId: gameId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBKeyMoment.self)
        }
    }
    
    
    /**
     Adds a new key moment to the Firestore database under a specific team and game.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - keyMomentDTO: The data transfer object (`KeyMomentDTO`) representing the key moment to add.
     - Returns: The document ID of the newly created key moment document, or `nil` if the key moment could not be added.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team document or database write failure).
     */
    func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String? {
        // Make sure the collection path can be found
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("addNewKeyMoment: Could not find team id. Aborting")
            return nil
        }
        
        let keyMomentDocument = keyMomentCollection(teamDocId: teamDocId, gameDocId: keyMomentDTO.gameId).document()
        let documentId = keyMomentDocument.documentID // get the document ID
        
        // Create a new key moment object
        let keyMoment = DBKeyMoment(keyMomentId: documentId, keyMomentDTO: keyMomentDTO)
        
        // Add the key moment to the database
        try keyMomentDocument.setData(from: keyMoment, merge: false)
        
        return documentId // return the key moment document id
    }
    
    
    /**
     Removes a specific key moment document from the Firestore database.
     - Parameters:
        - teamId: The team’s ID to locate the team document in Firestore.
        - gameId: The game’s ID to locate the game document in Firestore.
        - keyMomentId: The ID of the key moment document to delete.
     - Returns: This function does not return any value.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing documents or deletion failure).
     */
    func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("removeKeyMoment: Could not find team id. Aborting")
            return
        }

        try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId).delete()
    }
    
    
    /// Updates the list of players who received feedback for a transcript.
    ///
    /// - Parameters:
    ///   - transcriptId: The transcript identifier.
    ///   - gameId: The game identifier.
    ///   - teamId: The team identifier.
    ///   - teamDocId: Firestore document ID for the team.
    ///   - feedbackFor: List of players to save as feedback recipients.
    ///
    /// - Throws: If fetching the transcript or updating Firestore fails.
    func updateFeedbackFor(
        transcriptId: String,
        gameId: String,
        teamId: String,
        teamDocId: String,
        feedbackFor: [PlayerNameAndPhoto]
    ) async throws {
        let feedbackData = feedbackFor.map { $0.playerId }
        
        guard let keyMomentId = try await TranscriptManager.shared.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)?.keyMomentId else {
            print("Unable to get key moment id for transcript \(transcriptId).")
            return
        }
        
        try await KeyMomentManager.shared.keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId)
            .updateData([
                "feedback_for": feedbackData
            ])
    }
}


