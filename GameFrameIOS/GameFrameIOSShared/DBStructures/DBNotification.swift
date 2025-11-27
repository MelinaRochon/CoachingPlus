//
//  DBNotification.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation

/// Represents an in-app notification stored in Firestore.
///
/// Notifications are stored under a user document, e.g.:
/// `users/{userId}/notifications/{notificationId}`
///
/// - Properties:
///   - `id`: Firestore document ID of the notification.
///   - `userDocId`: The user document ID this notification belongs to (owner of the notification).
///   - `teamDocId`: Firestore team document ID (if applicable).
///   - `teamId`: Logical team ID (`DBTeam.teamId`) (if applicable).
///   - `gameId`: Logical game ID (`DBGame.gameId`) (if applicable).
///   - `keyMomentId`: ID of the key moment this notification refers to (if any).
///   - `transcriptId`: ID of the transcript this notification refers to (if any).
///   - `commentId`: ID of the comment this notification refers to (if any).
///   - `type`: High–level type of notification (recording ready, key moment feedback, etc.).
///   - `title`: Short title shown in the notifications list.
///   - `body`: Description/body text for the notification.
///   - `createdAt`: When the notification was created.
///   - `isRead`: Whether the user has opened / read this notification.
public struct DBNotification: Identifiable, Codable {
    
    public let id: String
    public let userDocId: String
    public let playerDocId: String?

    public let teamDocId: String?
    public let teamId: String?
    public let gameId: String?
    
    public let keyMomentId: String?
    public let transcriptId: String?
    public let commentId: String?
    
    public let type: NotificationType
    public let title: String
    
    public let createdAt: Date
    public var isRead: Bool
    
    // MARK: - Designated initializer
    
    public init(
        id: String,
        userDocId: String,
        playerDocId: String? = nil,
        teamDocId: String? = nil,
        teamId: String? = nil,
        gameId: String? = nil,
        keyMomentId: String? = nil,
        transcriptId: String? = nil,
        commentId: String? = nil,
        type: NotificationType,
        title: String,
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.userDocId = userDocId
        self.playerDocId = playerDocId
        self.teamDocId = teamDocId
        self.teamId = teamId
        self.gameId = gameId
        self.keyMomentId = keyMomentId
        self.transcriptId = transcriptId
        self.commentId = commentId
        self.type = type
        self.title = title
        self.createdAt = createdAt
        self.isRead = isRead
    }
    
    public init(id: String, notificationDTO: NotificationDTO) {
        self.id = id
        self.userDocId = notificationDTO.userDocId
        self.playerDocId = notificationDTO.playerDocId
        self.teamDocId = notificationDTO.teamDocId
        self.teamId = notificationDTO.teamId
        self.gameId = notificationDTO.gameId
        self.keyMomentId = notificationDTO.keyMomentId
        self.transcriptId = notificationDTO.transcriptId
        self.commentId = notificationDTO.commentId
        self.type = notificationDTO.type
        self.title = notificationDTO.title
        self.isRead = false                     // new notifications start unread
        self.createdAt = Date()                 // stamp creation time
    }
    
    // MARK: - CodingKeys
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case userDocId = "user_doc_id"
        case playerDocId = "player_doc_id"
        case teamDocId = "team_doc_id"
        case teamId = "team_id"
        case gameId = "game_id"
        case keyMomentId = "key_moment_id"
        case transcriptId = "transcript_id"
        case commentId = "comment_id"
        case type = "type"
        case title = "title"
        case createdAt = "created_at"
        case isRead = "is_read"
    }
    
    // MARK: - Codable
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.userDocId = try container.decode(String.self, forKey: .userDocId)
        self.playerDocId = try container.decodeIfPresent(String.self, forKey: .playerDocId)
        
        self.teamDocId = try container.decodeIfPresent(String.self, forKey: .teamDocId)
        self.teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        self.gameId = try container.decodeIfPresent(String.self, forKey: .gameId)
        
        self.keyMomentId = try container.decodeIfPresent(String.self, forKey: .keyMomentId)
        self.transcriptId = try container.decodeIfPresent(String.self, forKey: .transcriptId)
        self.commentId = try container.decodeIfPresent(String.self, forKey: .commentId)
        
        self.type = try container.decode(NotificationType.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userDocId, forKey: .userDocId)
        try container.encodeIfPresent(self.playerDocId, forKey: .playerDocId)
        
        try container.encodeIfPresent(self.teamDocId, forKey: .teamDocId)
        try container.encodeIfPresent(self.teamId, forKey: .teamId)
        try container.encodeIfPresent(self.gameId, forKey: .gameId)
        
        try container.encodeIfPresent(self.keyMomentId, forKey: .keyMomentId)
        try container.encodeIfPresent(self.transcriptId, forKey: .transcriptId)
        try container.encodeIfPresent(self.commentId, forKey: .commentId)
        
        try container.encode(self.type, forKey: .type)
        try container.encode(self.title, forKey: .title)
        
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.isRead, forKey: .isRead)
    }
}
