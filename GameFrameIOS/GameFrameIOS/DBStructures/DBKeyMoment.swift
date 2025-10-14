//
//  DBKeyMoment.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

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
    var feedbackFor: [String]?
//    let feedbackForCount: Int
    
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
//        self.feedbackForCount = feedbackForCount
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
//        self.feedbackForCount = keyMomentDTO.feedbackFor?.count ?? 0
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
//        case feedbackForCount = "feedback_for_count"
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
//        self.feedbackForCount = try container.decode(Int.self, forKey: .feedbackForCount)
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
//        try container.encode(self.feedbackForCount, forKey: .feedbackForCount)
    }
}
