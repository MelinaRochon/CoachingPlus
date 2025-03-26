//
//  KeyMomentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

struct DBKeyMoment: Codable {
    let keyMomentId: String
    let fullGameId: String? // Only applies if key moment is associated to a video recording
    let gameId: String
    let uploadedBy: String
    let audioUrl: String?
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [String]?
    
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

final class KeyMomentManager {
    static let shared = KeyMomentManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    /** Returns a specific key moment document */
    func keyMomentDocument(teamDocId: String, gameDocId: String, keyMomentDocId: String) -> DocumentReference {
        return keyMomentCollection(teamDocId: teamDocId, gameDocId: gameDocId).document(keyMomentDocId)
    }
    
    /** Returns the key moment collection */
    func keyMomentCollection(teamDocId: String, gameDocId: String) -> CollectionReference {
        return GameManager.shared.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("key_moments")
    }
    
    /** GET - Returns a specific key moment document from the database */
    func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        return try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId).getDocument(as: DBKeyMoment.self)
    }
    
    /** GET - Returns a specific key moment document from the database using doc ids */
    func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameDocId, keyMomentDocId: keyMomentDocId).getDocument(as: DBKeyMoment.self)
    }
    
    /** GET - Returns all the key moments in the collection */
    func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]? {
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the key moment collection
        let snapshot = try await keyMomentCollection(teamDocId: teamDocId, gameDocId: gameId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBKeyMoment.self)
        }
    }
    
    /** POST - Add a new key moment to the database */
    func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String? {
        // Make sure the collection path can be found
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
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
    
    /** DELETE - Remove a key moment from the database */
    func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }

        try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId).delete()
    }

}
