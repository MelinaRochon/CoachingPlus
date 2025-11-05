//
//  GameDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import Foundation

/// `GameDTO` is a Data Transfer Object (DTO) that represents the information associated with a specific game.
/// This structure is used to transfer data about the game between the app and the backend or server, including details like the game’s title, schedule, and timing.
/// It also contains reminders and settings related to feedback and recording for the game.
///
/// ### Properties:
/// - `title`: The title of the game, typically a descriptive name like "Team A vs Team B" or the name of the event.
/// - `duration`: The duration of the game in minutes. This defines how long the game will last from start to finish.
/// - `location`: An optional string representing the location of the game, such as a stadium name or city. This can be `nil` if no location is provided.
/// - `scheduledTimeReminder`: A reminder time in minutes before the scheduled start of the game. This helps send notifications or reminders about the game’s upcoming start.
/// - `startTime`: An optional `Date` object representing the actual start time of the game. This is important for tracking when the game officially begins.
/// - `timeBeforeFeedback`: The amount of time in seconds before feedback can be provided after the game starts. This is typically used to set up the interval during which feedback is delayed or allowed.
/// - `timeAfterFeedback`: The amount of time in seconds after the game ends, during which feedback can still be provided. This is useful for extending the window for feedback submissions after the game concludes.
/// - `recordingReminder`: A boolean value indicating whether a reminder for recording the game is enabled. This helps notify users to start recording at the appropriate time.
/// - `teamId`: A string representing the team ID associated with the game. This links the game to a specific team participating in the event.
public struct GameDTO {
    
    /// The title or name of the game, which could be something like "Team A vs Team B".
    /// This helps identify the game in the system and is usually displayed in the UI to give context to users.
    public let title: String
    
    /// The duration of the game in minutes.
    /// This value specifies how long the game will last and helps to determine the time frame in which certain actions (like feedback or recording) will occur.
    public let duration: Int
    
    /// An optional string representing the location of the game.
    /// This could be the name of a stadium, the city, or any other relevant place where the game is held.
    /// It may be `nil` if the location is not specified.
    public let location: String?
    
    /// A reminder time in minutes before the game starts.
    /// This property helps trigger notifications to alert users of the game's upcoming start at the specified time interval.
    public let scheduledTimeReminder: Int
    
    /// An optional `Date` object representing the actual start time of the game.
    /// This helps track when the game begins and can be used to calculate the game’s ongoing duration or set timers.
    public let startTime: Date?
    
    /// The amount of time in seconds before players or coaches can provide feedback after the game begins.
    /// This is useful for games that have a feedback delay, ensuring feedback is only allowed after a certain period has passed.
    public let timeBeforeFeedback: Int
    
    /// The amount of time in seconds after the game ends during which feedback can still be provided.
    /// This gives users a window after the game ends to submit feedback, even though the game has finished.
    public let timeAfterFeedback: Int
    
    /// A boolean value indicating whether a reminder to record the game is enabled.
    /// If set to `true`, a reminder is triggered for users to start recording the game at the appropriate time.
    public let recordingReminder: Bool
    
    /// A string representing the team ID that is associated with this game.
    /// This links the game to the specific team playing, allowing for easy filtering and association with team-based data.
    public let teamId: String
    
    public init(title: String, duration: Int, location: String?, scheduledTimeReminder: Int, startTime: Date?, timeBeforeFeedback: Int, timeAfterFeedback: Int, recordingReminder: Bool, teamId: String) {
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
}
