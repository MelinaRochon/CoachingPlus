//
//  DBFullGameVideoRecording.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation


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
    var fileURL: String?    // The URL to access the video file (optional because it might not be set yet).
    let startTime: Date     // The start time of the video recording.
    var endTime: Date?      // The end time of the video recording (optional because it may not be provided yet).
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
