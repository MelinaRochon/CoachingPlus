//
//  CommentDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation

/// `CommentDTO` is a Data Transfer Object (DTO) that represents a comment associated with a specific key moment or transcript within a game.
/// This structure is used to transfer comment data between the app and the backend or server.
///
/// ### Properties:
/// - `keyMomentId`: A unique identifier for the key moment that the comment is associated with. This links the comment to a specific key moment in the game.
/// - `gameId`: A unique identifier for the game where the comment was made. This property helps link the comment to the corresponding game.
/// - `transcriptId`: A unique identifier for the transcript that the comment is related to. This property connects the comment to the relevant transcript.
/// - `uploadedBy`: The user (coach, player, etc.) who uploaded the comment. This is typically the ID of the user who created the comment.
/// - `comment`: The text content of the comment itself. This is the actual comment made by the user (e.g., feedback, notes, or observations).
/// - `createdAt`: The date and time when the comment was created. This helps track when the comment was posted and could be used for sorting or filtering comments by date.
public struct CommentDTO {
    /// A unique identifier for the key moment the comment is associated with.
    /// This ID links the comment directly to a specific key moment in the game, allowing for precise feedback and tracking.
    public let keyMomentId: String
    
    /// A unique identifier for the game the comment was made in.
    /// This helps to identify which game the comment pertains to and is essential for linking it to the correct game context.
    public let gameId: String
    
    /// A unique identifier for the transcript that the comment is related to.
    /// This ID allows the comment to be tied to a specific transcript, which could be a recorded game event or player feedback.
    public let transcriptId: String
    
    /// The ID of the user who uploaded the comment.
    /// This could be a coach, player, or other relevant users. This property helps identify who made the comment and may be useful for permissions or user-specific filtering.
    public let uploadedBy: String
    
    /// The text content of the comment.
    /// This is the actual feedback or message provided by the user. It could include notes, observations, or specific feedback on the game, key moments, or player performance.
    public let comment: String
    
    /// The date and time when the comment was created.
    /// This is important for tracking the timeline of the comment and could be useful for sorting, filtering, or displaying comments chronologically.
    public let createdAt: Date
    
    public init(keyMomentId: String, gameId: String, transcriptId: String, uploadedBy: String, comment: String, createdAt: Date) {
        self.keyMomentId = keyMomentId
        self.gameId = gameId
        self.transcriptId = transcriptId
        self.uploadedBy = uploadedBy
        self.comment = comment
        self.createdAt = createdAt
    }
}
