//
//  DBInvite.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/**
 A struct representing an invitation to join a team. Used for both storing and retrieving invite data from Firestore.

 - Properties:
    - `id`: The unique identifier of the invite.
    - `userDocId`: The ID of the user who sent the invite.
    - `playerDocId`: The ID of the player being invited.
    - `email`: The email of the invited player.
    - `status`: The current status of the invite (e.g., "pending", "accepted").
    - `dateInviteSent`: The date when the invite was sent.
    - `dateAccepted`: The date when the invite was accepted, or `nil` if not accepted.
 */
public struct DBInvite: Codable {
    public let id: String
    public let userDocId: String
    public let playerDocId: String
    public let email: String
    public var status: UserAccountStatus
    public let dateInviteSent: Date
    public let dateVerified: Date?
    
    public init(id: String, userDocId: String, playerDocId: String, email: String, status: UserAccountStatus, dateInviteSent: Date, dateVerified: Date? = nil) {
        self.id = id
        self.userDocId = userDocId
        self.playerDocId = playerDocId
        self.email = email
        self.status = status
        self.dateInviteSent = dateInviteSent
        self.dateVerified = dateVerified
    }
    
    public init(id: String, inviteDTO: InviteDTO) {
        self.id = id
        self.userDocId = inviteDTO.userDocId
        self.playerDocId = inviteDTO.playerDocId
        self.email = inviteDTO.email
        self.status = inviteDTO.status
        self.dateInviteSent = Date()
        self.dateVerified = inviteDTO.dateVerified
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case userDocId = "user_doc_id"
        case playerDocId = "player_doc_id"
        case email = "email"
        case status = "status"
        case dateInviteSent = "date_invite_sent"
        case dateVerified = "date_verified"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userDocId = try container.decode(String.self, forKey: .userDocId)
        self.playerDocId = try container.decode(String.self, forKey: .playerDocId)
        self.email = try container.decode(String.self, forKey: .email)
        self.status = try container.decode(UserAccountStatus.self, forKey: .status)
        self.dateInviteSent = try container.decode(Date.self, forKey: .dateInviteSent)
        self.dateVerified = try container.decodeIfPresent(Date.self, forKey: .dateVerified)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userDocId, forKey: .userDocId)
        try container.encode(self.playerDocId, forKey: .playerDocId)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.dateInviteSent, forKey: .dateInviteSent)
        try container.encodeIfPresent(self.dateVerified, forKey: .dateVerified)
    }
}

