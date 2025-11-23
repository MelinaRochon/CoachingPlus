//
//  DBTeamInvite.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import Foundation

public struct DBTeamInvite: Codable {
    public let id: String
    public let status: InviteStatus
    public let dateTeamInviteSent: Date
    public let dateAccepted: Date?
    
    public init(id: String, status: InviteStatus, dateTeamInviteSent: Date, dateAccepted: Date? = nil) {
        self.id = id
        self.status = status
        self.dateTeamInviteSent = dateTeamInviteSent
        self.dateAccepted = dateAccepted
    }
    
    public init(teamInviteDTO: TeamInviteDTO) {
        self.id = teamInviteDTO.teamId
        self.status = teamInviteDTO.status
        self.dateTeamInviteSent = Date()
        self.dateAccepted = teamInviteDTO.dateAccepted
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "status"
        case dateTeamInviteSent = "date_team_invite_sent"
        case dateAccepted = "date_accepted"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.status = try container.decode(InviteStatus.self, forKey: .status)
        self.dateTeamInviteSent = try container.decode(Date.self, forKey: .dateTeamInviteSent)
        self.dateAccepted = try container.decodeIfPresent(Date.self, forKey: .dateAccepted)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.dateTeamInviteSent, forKey: .dateTeamInviteSent)
        try container.encodeIfPresent(self.dateAccepted, forKey: .dateAccepted)
    }
}

