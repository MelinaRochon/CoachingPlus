//
//  FullGameVideoRecordingManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation

/**
 This class manages all interactions with Firestore related to full game video recordings. It provides methods
 for adding, retrieving, and managing full game video recordings within the Firestore database for a given team.

 Key responsibilities of this class:
 - Retrieving a specific full game video recording document using the team's and recording's document IDs.
 - Accessing the collection of full game video recordings for a specific team.
 - Adding a new full game video recording to Firestore, including the necessary validation of the team's existence and
   mapping the provided DTO to a Firestore document.

 The class uses Firestore's `DocumentReference` and `CollectionReference` to access and manage video recording data in
 the Firestore database. It ensures that all video recordings are correctly stored and retrieved for the appropriate team
 and game.

 This manager follows the Singleton design pattern, meaning there is only one instance of this class in the app. This
 instance is accessed via the `shared` static property.

 This class acts as the interface between the app and the Firestore database for full game video recording operations.
 */
final class FullGameVideoRecordingManager {
    private let repo: FullGameVideoRecordingRepository
    
    init(repo: FullGameVideoRecordingRepository = FirestoreFullGameVideoRecordingRepository()) {
        self.repo = repo
    }
    

    // MARK: - Public Methods
    
    /**
     * Returns a full game video recording collection for a specific team.
     * - Parameters:
     *   - teamDocId: The team document ID of the team to which the video recordings belong.
     *   - fullGameId: The full game ID of which the video recording belong
     * - Returns: A `DBFullGameVideoRecording?`.
     */
    func getFullGameVideo(teamDocId: String, fullGameId: String) async throws -> DBFullGameVideoRecording? {
        return try await repo.getFullGameVideo(teamDocId: teamDocId, fullGameId: fullGameId)
    }

    /**
     * Adds a new full game video recording to the Firestore database.
     * - Parameters:
     *   - fullGameVideoRecordingDTO: The `FullGameVideoRecordingDTO` object containing the data for the new full game video recording.
     * - Throws: Throws an error if there is an issue creating or saving the video recording to Firestore.
     * - Description: This method will:
     *   1. Ensure the team ID exists by querying the `TeamManager`.
     *   2. Create a new document for the full game video recording in the team's collection.
     *   3. Map the provided `FullGameVideoRecordingDTO` to a `DBFullGameVideoRecording` object.
     *   4. Save the new video recording to Firestore.
     */
    func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws -> String? {
        return try await repo.addFullGameVideoRecording(fullGameVideoRecordingDTO: fullGameVideoRecordingDTO)
    }
    
    
    /// Updates a full game video recording document in Firestore with a new end time and file path.
    ///
    /// - Parameters:
    ///   - fullGameId: The Firestore document ID of the full game recording.
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - endTime: The time when the recording ended.
    ///   - path: The storage path (or URL) of the uploaded video file.
    func updateFullGameVideoRecording(fullGameId: String, teamDocId: String, endTime: Date, path: String) async throws {
        try await repo.updateFullGameVideoRecording(fullGameId: fullGameId, teamDocId: teamDocId, endTime: endTime, path: path)
    }
    
    
    /// Fetches a full game video recording document for a given game from Firestore.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The unique identifier of the game.
    ///
    /// - Returns: A `DBFullGameVideoRecording` object if found, otherwise `nil`.
    /// - Throws: An error if the Firestore query or decoding fails.
    func getFullGameVideoWithGameId(teamDocId: String, gameId: String) async throws -> DBFullGameVideoRecording? {
        return try await repo.getFullGameVideoWithGameId(teamDocId: teamDocId, gameId: gameId)
    }
}
