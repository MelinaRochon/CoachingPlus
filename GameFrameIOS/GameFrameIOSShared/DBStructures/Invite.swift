//
//  Invite.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-21.
//

import Foundation

/**
 A struct representing an invitation to join a team. Used for both storing and retrieving invite data from Firestore.

 - Properties:
    - `id`: The unique identifier of the invite.
    - `userDocId`: The ID of the user who sent the invite.
    - `playerDocId`: The ID of the player being invited.
    - `email`: The email of the invited player.
    - `status`: The current status of the user account (e.g., "verified", "unverified").
    - `dateInviteSent`: The date when the invite was sent.
    - `dateAccepted`: The date when the invite was accepted, or `nil` if not accepted.
    - `teamId`: The ID of the team to which the invite pertains.
    - `teamStatus`: The current status of the invite (e.g., "pending", "accepted").
    - `dateTeamInviteSent`: The date that the team invite was sent
    - `dateAccepted`: The date that the invitation was accepted by the player
 */
public struct Invite: Codable {
    public let id: String
    public let userDocId: String
    public let playerDocId: String
    public let email: String
    public var status: UserAccountStatus
    public let dateInviteSent: Date
    public let dateVerified: Date?
    public let teamId: String
    public let teamStatus: InviteStatus
    public let dateTeamInviteSent: Date
    public let dateAccepted: Date?

    
    public init(id: String, userDocId: String, playerDocId: String, email: String, status: UserAccountStatus, dateInviteSent: Date, dateVerified: Date? = nil, teamId: String, teamStatus: InviteStatus, dateTeamInviteSent: Date, dateAccepted: Date? = nil) {
        self.id = id
        self.userDocId = userDocId
        self.playerDocId = playerDocId
        self.email = email
        self.status = status
        self.dateInviteSent = dateInviteSent
        self.dateVerified = dateVerified
        self.teamId = teamId
        self.teamStatus = teamStatus
        self.dateTeamInviteSent = dateTeamInviteSent
        self.dateAccepted = dateAccepted
    }
    
    public init(invite: DBInvite, teamInvite: DBTeamInvite) {
        self.id = invite.id
        self.userDocId = invite.userDocId
        self.playerDocId = invite.playerDocId
        self.email = invite.email
        self.status = invite.status
        self.dateInviteSent = Date()
        self.dateVerified = invite.dateVerified
        self.teamId = teamInvite.id
        self.teamStatus = teamInvite.status
        self.dateTeamInviteSent = teamInvite.dateTeamInviteSent
        self.dateAccepted = teamInvite.dateAccepted
    }
}
