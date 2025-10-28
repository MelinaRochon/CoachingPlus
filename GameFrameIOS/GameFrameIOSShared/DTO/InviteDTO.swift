//
//  InviteDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

/**
 A data transfer object used for creating or modifying an invite.

 - Properties:
    - `userDocId`: The ID of the user sending the invite.
    - `playerDocId`: The ID of the player being invited.
    - `email`: The email of the player being invited.
    - `status`: The status of the invite (e.g., "pending").
    - `dateAccepted`: The date the invite was accepted (optional).
    - `teamId`: The ID of the team the invite pertains to.
 */
public struct InviteDTO {
    public let userDocId: String
    public let playerDocId: String
    public let email: String
    public let status: String
    public let dateAccepted: Date?
    public let teamId: String
    
    public init(userDocId: String, playerDocId: String, email: String, status: String, dateAccepted: Date?, teamId: String) {
        self.userDocId = userDocId
        self.playerDocId = playerDocId
        self.email = email
        self.status = status
        self.dateAccepted = dateAccepted
        self.teamId = teamId
    }
}
