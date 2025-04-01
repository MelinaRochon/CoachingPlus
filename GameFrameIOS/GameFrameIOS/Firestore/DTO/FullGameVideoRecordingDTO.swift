//
//  FullGameVideoRecordingDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation


/// `FullGameVideoRecordingDTO` is a Data Transfer Object (DTO) that represents the information associated with a full game video recording.
/// This structure is used to transfer video recording data between the app and the backend or server, including details about the game, the team, and the video itself.
///
/// ### Properties:
/// - `gameId`: A unique identifier for the game that the video recording is associated with. This helps to link the video to a specific game.
/// - `uploadedBy`: The user who uploaded the video recording (e.g., coach, player, or admin). This property identifies the source of the video upload.
/// - `fileURL`: A string representing the URL or path to the video file. This points to the location of the video on the server or cloud storage.
/// - `startTime`: A `Date` object representing the timestamp when the video recording started. This is used to track the beginning of the video recording.
/// - `endTime`: An optional `Date` object representing the timestamp when the video recording ended. This marks the end of the video and is useful for defining the length of the recording.
/// - `teamId`: A unique identifier for the team associated with the game. This helps link the video to a specific team participating in the game.

struct FullGameVideoRecordingDTO {
    
    /// A unique identifier for the game the video is associated with.
    /// This helps to link the video to the correct game and ensures the video is correctly referenced within the app's context.
    let gameId: String
    
    /// The ID of the user who uploaded the video.
    /// This could be the coach, player, or admin who uploaded the video recording, helping track who is responsible for the video.
    let uploadedBy: String
    
    /// A string representing the URL or file path to the video file.
    /// This URL allows the app to retrieve and play the video from the specified location, whether it is hosted on a server or cloud storage.
    let fileURL: String?
    
    /// The start time of the video recording.
    /// This `Date` object marks the exact moment when the video recording started, providing a reference for the video’s timeline.
    let startTime: Date
    
    /// The end time of the video recording (optional).
    /// This `Date` object marks when the video recording stopped. If not available, the video may still be considered to have an undefined end time.
    let endTime: Date?
    
    /// A unique identifier for the team associated with the game.
    /// This helps link the video to the correct team, allowing the app to filter or sort videos based on the team.
    let teamId: String
}
