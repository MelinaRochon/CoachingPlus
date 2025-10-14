//
//  DBComment.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// Model representing a comment in the database
struct DBComment: Codable {
    let commentId: String
    let keyMomentId: String
    let gameId: String
    let transcriptId: String
    let uploadedBy: String
    let comment: String
    let createdAt: Date
    
    // Initializer for creating a comment with all fields
    init(commentId: String, keyMomentId: String, gameId: String, transcriptId: String, uploadedBy: String, comment: String, createdAt: Date) {
        self.commentId = commentId
        self.keyMomentId = keyMomentId
        self.gameId = gameId
        self.transcriptId = transcriptId
        self.uploadedBy = uploadedBy
        self.comment = comment
        self.createdAt = createdAt
    }
    
    // Initializer using a CommentDTO object
    init(commentId: String, commentDTO: CommentDTO) {
        self.commentId = commentId
        self.keyMomentId = commentDTO.keyMomentId
        self.gameId = commentDTO.gameId
        self.transcriptId = commentDTO.transcriptId
        self.uploadedBy = commentDTO.uploadedBy
        self.comment = commentDTO.comment
        self.createdAt = commentDTO.createdAt
    }
    
    // Enum for coding keys used in encoding and decoding
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case keyMomentId = "key_moment_id"
        case gameId = "game_id"
        case transcriptId = "transcript_id"
        case uploadedBy = "uploaded_by"
        case comment = "comment"
        case createdAt = "created_at"
    }

    // Decode the comment data from a decoder
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.keyMomentId = try container.decode(String.self, forKey: .keyMomentId)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.transcriptId = try container.decode(String.self, forKey: .transcriptId)
        self.uploadedBy = try container.decode(String.self, forKey: .uploadedBy)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
     
    // Encode the comment data to an encoder
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.keyMomentId, forKey: .keyMomentId)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.transcriptId, forKey: .transcriptId)
        try container.encode(self.uploadedBy, forKey: .uploadedBy)
        try container.encode(self.comment, forKey: .comment)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}
