//
//  DBGame.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/**
 This struct represents a game in the Firestore database. It includes details such as the game's title, duration,
 location, time-related settings (such as scheduled time reminder and feedback times), and other metadata like the
 team ID associated with the game. The struct is `Codable`, making it easy to serialize and deserialize between
 Firestore documents and the application's data model.

 Properties:
 - `gameId`: A unique identifier for the game document in Firestore.
 - `title`: The title or name of the game.
 - `duration`: The duration of the game in seconds.
 - `location`: The location where the game is scheduled to take place. This is optional.
 - `scheduledTimeReminder`: A reminder time for the game in minutes. This indicates how far in advance the reminder
   should trigger before the game starts.
 - `startTime`: The scheduled start time of the game. This is optional and may be nil if not set.
 - `timeBeforeFeedback`: The time, in seconds, before feedback can be provided during the game.
 - `timeAfterFeedback`: The time, in seconds, after feedback can be provided.
 - `recordingReminder`: A boolean indicating whether a reminder for recording is enabled for the game.
 - `teamId`: The ID of the team associated with this game.

 The struct has several initializers:
 - A default initializer that takes in all the necessary game properties.
 - A convenience initializer that creates a game with default values if the data is unavailable.
 - An initializer that maps data from a `GameDTO` (Data Transfer Object), which is commonly used when receiving
   game data from an external source like an API.

 The struct is also `Codable` to work with Firestore's data serialization and deserialization features. It includes
 custom `init(from:)` and `encode(to:)` methods for decoding and encoding the game data.

 This model is used to store and retrieve game data from the Firestore database.
 */
public struct DBGame: Codable {
    public let gameId: String
    public var title: String
    public var duration: Int
    public var location: String?
    public var scheduledTimeReminder: Int // in minutes
    public var startTime: Date?
    public var timeBeforeFeedback: Int // in seconds
    public var timeAfterFeedback: Int // in seconds
    public var recordingReminder: Bool
    public let teamId: String
    
    public init(gameId: String, title: String, duration: Int, location: String? = nil, scheduledTimeReminder: Int, startTime: Date? = nil, timeBeforeFeedback: Int, timeAfterFeedback: Int, recordingReminder: Bool, teamId: String) {
        self.gameId = gameId
        self.title = title
        self.duration = duration
        self.location = location
        self.scheduledTimeReminder = scheduledTimeReminder
        self.startTime = startTime
        self.timeBeforeFeedback = timeBeforeFeedback
        self.timeAfterFeedback = timeAfterFeedback
        self.recordingReminder = recordingReminder
        self.teamId = teamId
    }
    
    public init(gameId: String, teamId: String) {
        self.gameId = gameId
        self.title = "Unknown Game"
        self.duration = 0 // by default, 0 seconds
        self.location = nil
        self.scheduledTimeReminder = 0 // by default, 0 minutes
        self.startTime = Date()
        self.timeBeforeFeedback = 10 // by default, 10 seconds
        self.timeAfterFeedback = 10 // by default, 10 seconds
        self.recordingReminder = false
        self.teamId = teamId
    }
    
    public init(gameId: String, gameDTO: GameDTO) {
        self.gameId = gameId
        self.title = gameDTO.title
        self.duration = gameDTO.duration // by default, 0 seconds
        self.location = gameDTO.location
        self.scheduledTimeReminder = gameDTO.scheduledTimeReminder // by default, 0 minutes
        self.startTime = gameDTO.startTime
        self.timeBeforeFeedback = gameDTO.timeBeforeFeedback // by default, 10 seconds
        self.timeAfterFeedback = gameDTO.timeAfterFeedback // by default, 10 seconds
        self.recordingReminder = gameDTO.recordingReminder
        self.teamId = gameDTO.teamId
    }
    
    public enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case title = "title"
        case duration = "duration"
        case location = "location"
        case scheduledTimeReminder = "scheduled_time"
        case startTime = "start_time"
        case timeBeforeFeedback = "time_before_feedback"
        case timeAfterFeedback = "time_after_feedback"
        case recordingReminder = "recording_reminder"
        case teamId = "team_id"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.scheduledTimeReminder = try container.decode(Int.self, forKey: .scheduledTimeReminder)
        self.startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        self.timeBeforeFeedback = try container.decode(Int.self, forKey: .timeBeforeFeedback)
        self.timeAfterFeedback = try container.decode(Int.self, forKey: .timeAfterFeedback)
        self.recordingReminder = try container.decode(Bool.self, forKey: .recordingReminder)
        self.teamId = try container.decode(String.self, forKey: .teamId)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.duration, forKey: .duration)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encode(self.scheduledTimeReminder, forKey: .scheduledTimeReminder)
        try container.encodeIfPresent(self.startTime, forKey: .startTime)
        try container.encode(self.timeBeforeFeedback, forKey: .timeBeforeFeedback)
        try container.encode(self.timeAfterFeedback, forKey: .timeAfterFeedback)
        try container.encode(self.recordingReminder, forKey: .recordingReminder)
        try container.encode(self.teamId, forKey: .teamId)
    }
}
