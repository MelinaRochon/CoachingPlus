//
//  FullGameVideoRecordingManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import FirebaseFirestore

/**
 This struct represents a full game video recording in the Firestore database. It contains all the necessary details
 related to a video recording of a soccer game, such as the game ID, the uploader's ID, the URL of the video,
 the start and end times of the video, and the associated team's ID.

 The struct is `Codable`, meaning it can be easily serialized and deserialized to and from Firestore documents.

 Properties:
 - `id`: A unique identifier for the video recording document in Firestore.
 - `gameId`: The ID of the game associated with the video recording.
 - `uploadedBy`: The ID or username of the person who uploaded the video.
 - `fileURL`: The URL to access the video file. It can be nil if the file URL is not available.
 - `startTime`: The start time of the video recording.
 - `endTime`: The end time of the video recording. This can be nil if the recording has no specified end time.
 - `teamId`: The ID of the team associated with the game and video recording.

 The struct includes methods for encoding and decoding data for Firestore operations and a custom initializer to
 initialize it from a Data Transfer Object (DTO) (`FullGameVideoRecordingDTO`).

 This model helps in storing and retrieving the full game video recording details from Firestore.
 */
struct DBFullGameVideoRecording: Codable {
    let id: String          // The unique identifier of the video recording document.
    let gameId: String      // The ID of the game that this video recording is related to.
    let uploadedBy: String  // The ID or username of the person who uploaded the video.
    let fileURL: String?    // The URL to access the video file (optional because it might not be set yet).
    let startTime: Date     // The start time of the video recording.
    let endTime: Date?      // The end time of the video recording (optional because it may not be provided yet).
    let teamId: String      // The ID of the team associated with the video recording.

    // Initializer that is used to create an instance of DBFullGameVideoRecording from individual parameters.
    init(id: String,
         gameId: String,
         uploadedBy: String,
         fileURL: String?,
         startTime: Date,
         endTime: Date?,
         teamId: String
    ) {
        self.id = id
        self.gameId = gameId
        self.uploadedBy = uploadedBy
        self.fileURL = fileURL
        self.startTime = startTime
        self.endTime = endTime
        self.teamId = teamId
    }
    
    // Initializer that creates a DBFullGameVideoRecording instance using a DTO (Data Transfer Object).
    init(id: String, fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) {
        self.id = id
        self.gameId = fullGameVideoRecordingDTO.gameId
        self.uploadedBy = fullGameVideoRecordingDTO.uploadedBy
        self.fileURL = fullGameVideoRecordingDTO.fileURL
        self.startTime = fullGameVideoRecordingDTO.startTime
        self.endTime = fullGameVideoRecordingDTO.endTime
        self.teamId = fullGameVideoRecordingDTO.teamId
    }
    
    // Coding keys for mapping properties to Firestore field names.
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case gameId = "game_id"
        case uploadedBy = "uploaded_by"
        case fileURL = "file_url"
        case startTime = "start_time"
        case endTime = "end_time"
        case teamId = "team_id"
    }
    
    // Decoding initializer to map Firestore fields to the struct properties.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.uploadedBy = try container.decode(String.self, forKey: .uploadedBy)
        self.fileURL = try container.decodeIfPresent(String.self, forKey: .fileURL)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        self.teamId = try container.decode(String.self, forKey: .teamId)
    }
    
    // Encoding method to serialize the struct into Firestore fields.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.uploadedBy, forKey: .uploadedBy)
        try container.encode(self.fileURL, forKey: .fileURL)
        try container.encode(self.startTime, forKey: .startTime)
        try container.encode(self.endTime, forKey: .endTime)
        try container.encode(self.teamId, forKey: .teamId)
    }
}


/**
 This singleton class manages all interactions with Firestore related to full game video recordings. It provides methods
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

 Methods:
 - `fullGameVideoRecordingDocument(teamDocId:fgDocId:)`: Returns a reference to a specific full game video recording document.
 - `fullGameVideoRecordingCollection(teamDocId:)`: Returns a reference to the collection of full game video recordings for a team.
 - `addFullGameVideoRecording(fullGameVideoRecordingDTO:)`: Adds a new full game video recording to Firestore.

 This class acts as the interface between the app and the Firestore database for full game video recording operations.
 */
final class FullGameVideoRecordingManager {
    static let shared = FullGameVideoRecordingManager()
    private init() {}
    
    // MARK: - Private Helper Methods

        /**
         * Returns a reference to a specific full game video recording document in Firestore.
         * - Parameters:
         *   - teamDocId: The document ID of the team to which the video recording belongs.
         *   - fgDocId: The document ID of the full game video recording.
         * - Returns: A `DocumentReference` pointing to the specified full game video recording document in Firestore.
         */
    func fullGameVideoRecordingDocument(teamDocId: String, fgDocId: String) -> DocumentReference {
        return fullGameVideoRecordingCollection(teamDocId: teamDocId).document(fgDocId)
    }
    
    
    /**
     * Returns a reference to the full game video recording collection for a specific team.
     * - Parameters:
     *   - teamDocId: The document ID of the team to which the video recordings belong.
     * - Returns: A `CollectionReference` to the team's full game video recording collection in Firestore.
     */
    func fullGameVideoRecordingCollection(teamDocId: String) -> CollectionReference {
        return TeamManager.shared.teamCollection.document(teamDocId).collection("fg_video_recording")
    }
    

    // MARK: - Public Methods

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
    func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws {
        //Create new full game video recording
        do {
            print("Sending new full game recording to Firestore: \(fullGameVideoRecordingDTO)")
            
            guard let teamDocId = try await TeamManager.shared.getTeam(teamId: fullGameVideoRecordingDTO.teamId)?.id else {
                print("Could not find team id. Aborting")
                return
            }

            let fgvRecordingDocument = fullGameVideoRecordingCollection(teamDocId: teamDocId).document()
            let documentId = fgvRecordingDocument.documentID // get the document id

            // create a new full game video recording object
            let fgvRecording = DBFullGameVideoRecording(id: documentId, fullGameVideoRecordingDTO: fullGameVideoRecordingDTO)
            
            // create a new full game video recording
            try fgvRecordingDocument.setData(from: fgvRecording, merge: false)
            
            print("Full game video recording created!")
        } catch let error as NSError {
            print("Error creating full game video recording: \(error.localizedDescription)")
            throw error
        }
    }
}
