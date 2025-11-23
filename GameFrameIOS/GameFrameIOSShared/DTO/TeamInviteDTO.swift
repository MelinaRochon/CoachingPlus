//
//  TeamInviteDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import Foundation

public struct TeamInviteDTO: Encodable {
    public let teamId: String
    public let status: InviteStatus
    public let dateAccepted: Date?
    
    public init(teamId: String, status: InviteStatus, dateAccepted: Date?) {
        self.teamId = teamId
        self.status = status
        self.dateAccepted = dateAccepted
    }
}
