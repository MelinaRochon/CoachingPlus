//
//  NotificationDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation

/**
 A data transfer object used for creating or modifying a notification.

 This DTO is used when constructing a new `DBNotification` object to store in Firestore.
 It contains only the information needed to *create* the notification—not metadata
 such as the Firestore document ID or timestamps.

 - Properties:
    - `userDocId`: The ID of the user receiving this notification.
    - `teamDocId`: The Firestore team document ID (if applicable).
    - `teamId`: The logical team ID (if applicable).
    - `gameId`: The logical game ID (if applicable).
    - `keyMomentId`: The key moment identifier associated with the notification (optional).
    - `transcriptId`: The transcript identifier associated with the notification (optional).
    - `commentId`: The comment identifier associated with the notification (optional).
    - `type`: The type of the notification (e.g., `.recordingReady`, `.keyMomentFeedback`).
    - `title`: The notification title shown to the user.
    - `body`: A description or summary message.
 */
public struct NotificationDTO {
    
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
    public let body: String

    public init(
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
        body: String
    ) {
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
        self.body = body
    }
}
