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
struct InviteDTO {
    let userDocId: String
    let playerDocId: String
    let email: String
    let status: String
    let dateAccepted: Date?
    let teamId: String
}
