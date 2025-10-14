//
//  FirestoreKeyMomentRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
import FirebaseFirestore

final class FirestoreKeyMomentRepository: KeyMomentRepository {
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
        let gameRepo = FirestoreGameRepository()
        return gameRepo.gameCollection(teamDocId: teamDocId).document(gameDocId).collection("key_moments")
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
        let teamManager = TeamManager()
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
            print("getKeyMoment: Could not find team id. Aborting")
            return nil
        }
        
        return try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId).getDocument(as: DBKeyMoment.self)
    }
    
    
    /// Assigns a player to key moments for the entire team if the feedback list
    /// already has the expected number of players but does not include this player.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - playersCount: The expected number of players in the team.
    ///   - playerId: The ID of the player to be added to the key moment’s feedback list.
    /// - Throws: Rethrows any error that occurs while fetching key moments
    ///   or updating a key moment’s feedback field in Firestore.
    /// - Returns: Nothing. The function is `async` and `throws` but has no return value.
    func assignPlayerToKeyMomentsForEntireTeam(teamDocId: String, gameId: String, playersCount: Int, playerId: String) async throws {
        guard let keyMoments = try await getAllKeyMomentsWithTeamDocId(teamDocId: teamDocId, gameId: gameId) else {
            print("No key moments found")
            return
        }
        
        // Check the length of each feedback_for field
        for keyMoment in keyMoments {
            if let feedbackFor = keyMoment.feedbackFor {
                if feedbackFor.count == playersCount && !feedbackFor.contains(playerId) {
                    try await addPlayerToFeedbackFor(teamDocId: teamDocId, gameId: gameId, keyMomentId: keyMoment.keyMomentId, newPlayerId: playerId)
                }
            }
        }
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

    
    /// Fetches the audio URL associated with a specific key moment in a game.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team to which the game belongs.
    ///   - gameDocId: The document ID of the game containing the key moment.
    ///   - keyMomentId: The document ID of the key moment for which to fetch the audio URL.
    /// - Returns: The `audioUrl` string of the key moment if found, or `nil` if the key moment does not exist.
    /// - Throws: Rethrows any errors encountered while fetching the key moment from the database.
    /// - Note: This function performs an asynchronous fetch for the key moment using `getKeyMoment`.
    ///         If no key moment is found, it prints a debug message and returns `nil`.
    func getAudioUrl(teamDocId: String, gameDocId: String, keyMomentId: String) async throws -> String? {
        guard let keyMoment = try await getKeyMoment(teamId: teamDocId, gameId: gameDocId, keyMomentDocId: keyMomentId) else {
            print("No key moment found. returning")
            return nil
        }
        return keyMoment.audioUrl
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
        let teamManager = TeamManager()
        // Make sure the game document can be found under the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
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
     Fetches all the key moments for a specific game and team.
     - Parameters:
        - teamDocId: The tea's document ID in Firestore.
        - gameId: The ID of the game to locate the game document in Firestore.
     - Returns: An optional array of `DBKeyMoment` objects representing all key moments in the game, or `nil` if no key moments are found.
     - Throws: Errors may be thrown if Firestore operations fail (e.g., missing team or game document).
     */
    func getAllKeyMomentsWithTeamDocId(teamDocId: String, gameId: String) async throws -> [DBKeyMoment]? {
        
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
        let teamManager = TeamManager()
        // Make sure the collection path can be found
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
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
        let teamManager = TeamManager()
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
            print("removeKeyMoment: Could not find team id. Aborting")
            return
        }

        try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId).delete()
    }
    
    
    /// Adds a player ID to the `feedbackFor` field of a key moment document in Firestore.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - keyMomentId: The Firestore document ID of the key moment being updated.
    ///   - newPlayerId: The ID of the player to be added to the `feedbackFor` array field.
    /// - Throws: Rethrows any error that occurs while updating the Firestore document.
    /// - Returns: Nothing. The function is `async` and `throws` but has no return value.
    func addPlayerToFeedbackFor(teamDocId: String, gameId: String, keyMomentId: String, newPlayerId: String) async throws {
        let data: [String: Any] = [
            DBKeyMoment.CodingKeys.feedbackFor.rawValue: FieldValue.arrayUnion([newPlayerId])
        ]
        
        // TODO: - Make sure the playerId that we are adding isn't already in the database
        // Update the document asynchronously
        try await keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId).updateData(data as [AnyHashable : Any])
    }
    
    /// Deletes all key moment documents for a specific game within a team.
    ///
    /// - Parameters:
    ///   - teamDocId: The document ID of the team containing the game.
    ///   - gameId: The document ID of the game whose key moments should be deleted.
    /// - Throws: Rethrows any errors encountered while fetching or deleting the documents from Firestore.
    /// - Note: This function fetches all documents in the key moments collection for the specified game
    ///         and deletes them one by one. If the collection is large, consider using batch deletes
    ///         or pagination to avoid performance issues.
    func deleteAllKeyMoments(teamDocId: String, gameId: String) async throws {
        let collectionRef = keyMomentCollection(teamDocId: teamDocId, gameDocId: gameId)
        let snapshot = try await collectionRef.getDocuments()
        
        for document in snapshot.documents {
            try await collectionRef.document(document.documentID).delete()
        }
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
        let keyMomentRepo = FirestoreKeyMomentRepository()
        let transcriptManager = TranscriptManager()
        
        let feedbackData = feedbackFor.map { $0.playerId }
        
        guard let keyMomentId = try await transcriptManager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)?.keyMomentId else {
            print("Unable to get key moment id for transcript \(transcriptId).")
            return
        }
        
        try await keyMomentRepo.keyMomentDocument(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentId)
            .updateData([
                "feedback_for": feedbackData
            ])
    }
}
