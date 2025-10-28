//
//  KeyMomentDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation

/// A data transfer object (DTO) representing a "key moment" in a game, which refers to an important or notable event captured during gameplay.
///
/// A key moment typically includes a segment of the game that may involve feedback, player interactions, or other critical events. This struct is designed to
/// store essential details such as the time frame of the event (via `frameStart` and `frameEnd`), the person who uploaded the key moment (via `uploadedBy`),
/// and any associated audio (via `audioUrl`). The key moment can also be linked to specific players or teams who are the recipients of the feedback for that moment.
///
/// Key moments can be part of a full game (referenced by `fullGameId`), or they can exist independently (linked only by `gameId`), providing flexibility in how moments
/// are structured in the system. This DTO is useful for managing, storing, and retrieving key moments in the app's game data flow, particularly when offering post-game
/// feedback or analysis.
///
/// Properties:
/// - `fullGameId`: An optional string linking the key moment to the full game (if applicable).
/// - `gameId`: A required string identifying the specific game this key moment belongs to.
/// - `uploadedBy`: A string representing the user (coach, player, etc.) who uploaded the key moment.
/// - `audioUrl`: An optional string URL pointing to an audio file related to the key moment, if available.
/// - `frameStart`: A `Date` object marking the start time of the transcription for this key moment.
/// - `frameEnd`: A `Date` object marking the end time of the transcription for this key moment.
/// - `feedbackFor`: An optional array of strings identifying the players or people who will receive feedback for this key moment.
///
public struct KeyMomentDTO {
    /// An optional string representing the ID of the full game associated with the key moment.
    /// This is useful for linking a key moment to its corresponding full game, but it may be `nil` if the full game ID is not available.
    public let fullGameId: String?
    
    /// The ID of the game that this key moment belongs to.
    /// This ID is required to associate the key moment with the specific game, ensuring that the key moment is properly tracked and categorized.
    public let gameId: String
    
    /// The user who uploaded or created this key moment.
    /// This could be a coach, player, or other relevant user, and the value provides information about the origin of the key moment.
    public let uploadedBy: String
    
    /// An optional string URL pointing to the audio file related to this key moment.
    /// This could represent the location of a recorded audio file (e.g., a coach’s feedback or a moment in the game captured with audio), and may be `nil` if no audio is associated with the key moment.
    public let audioUrl: String?
    
    /// The start time of the transcription related to this key moment.
    /// This marks when the transcription for the key moment begins, helping to identify the exact window or frame of the game that this key moment refers to.
    public let frameStart: Date
    
    /// The end time of the transcription related to this key moment.
    /// This marks when the transcription for the key moment ends, providing a clear boundary for the moment’s time frame.
    public let frameEnd: Date
    
    /// An optional list of strings representing the players, coaches, or other individuals who will receive feedback for this key moment.
    /// This is useful for targeting specific recipients for feedback based on their involvement in the key moment.
    /// It can be `nil` if no specific feedback recipients are defined.
    public let feedbackFor: [String]?
    
    public init(fullGameId: String?, gameId: String, uploadedBy: String, audioUrl: String?, frameStart: Date, frameEnd: Date, feedbackFor: [String]?) {
        self.fullGameId = fullGameId
        self.gameId = gameId
        self.uploadedBy = uploadedBy
        self.audioUrl = audioUrl
        self.frameStart = frameStart
        self.frameEnd = frameEnd
        self.feedbackFor = feedbackFor
    }
}
