//
//  DBTeam.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// Represents a team in the database with all necessary properties.
/// This structure conforms to `Codable` to support encoding and decoding
/// between Swift objects and Firestore documents.
public struct DBTeam: Codable {
    public let id: String
    public let teamId: String
    public var name: String
    public var teamNickname: String
    public let sport: String
    public let logoUrl: String?
    public let colour: String?
    public var gender: String
    public var ageGrp: String
    public let accessCode: String?
    public var coaches: [String]
    public var players: [String]?
    public var invites: [String]?
    
    public init(
        id: String,
        teamId: String,
        name: String,
        teamNickname: String,
        sport: String,
        logoUrl: String? = nil,
        colour: String? = nil,
        gender: String,
        ageGrp: String,
        accessCode: String? = nil,
        coaches: [String],
        players: [String]? = nil,
        invites: [String]? = nil
    ) {
        self.id = id
        self.teamId = teamId
        self.name = name
        self.teamNickname = teamNickname
        self.sport = sport
        self.logoUrl = logoUrl
        self.colour = colour
        self.gender = gender
        self.ageGrp = ageGrp
        self.accessCode = accessCode
        self.coaches = coaches
        self.players = players
        self.invites = invites
    }
    
    public init(id: String, teamDTO: TeamDTO) {
        self.id = id
        self.teamId = teamDTO.teamId
        self.name = teamDTO.name
        self.teamNickname = teamDTO.teamNickname
        self.sport = teamDTO.sport
        self.logoUrl = teamDTO.logoUrl
        self.colour = teamDTO.colour
        self.gender = teamDTO.gender
        self.ageGrp = teamDTO.ageGrp
        self.accessCode = teamDTO.accessCode //
        self.coaches = teamDTO.coaches
        self.players = teamDTO.players
        self.invites = teamDTO.invites
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case teamId = "team_id"
        case name = "name"
        case teamNickname = "team_nickname"
        case sport = "sport"
        case logoUrl = "logo_url"
        case colour = "colour"
        case gender = "gender"
        case ageGrp = "age_grp"
        case accessCode = "access_code"
        case coaches = "coaches"
        case players = "players"
        case invites = "invites"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.teamId = try container.decode(String.self, forKey: .teamId)
        self.name = try container.decode(String.self, forKey: .name)
        self.teamNickname = try container.decode(String.self, forKey: .teamNickname)
        self.sport = try container.decode(String.self, forKey: .sport)
        self.logoUrl = try container.decodeIfPresent(String.self, forKey: .logoUrl)
        self.colour = try container.decodeIfPresent(String.self, forKey: .colour)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.ageGrp = try container.decode(String.self, forKey: .ageGrp)
        self.accessCode = try container.decodeIfPresent(String.self, forKey: .accessCode)
        self.coaches = try container.decode([String].self, forKey: .coaches)
        self.players = try container.decodeIfPresent([String].self, forKey: .players)
        self.invites = try container.decodeIfPresent([String].self, forKey: .invites)

    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.teamId, forKey: .teamId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.teamNickname, forKey: .teamNickname)
        try container.encode(self.sport, forKey: .sport)
        try container.encodeIfPresent(self.logoUrl, forKey: .logoUrl)
        try container.encodeIfPresent(self.colour, forKey: .colour)
        try container.encode(self.gender, forKey: .gender)
        try container.encode(self.ageGrp, forKey: .ageGrp)
        try container.encodeIfPresent(self.accessCode, forKey: .accessCode)
        try container.encode(self.coaches, forKey: .coaches)
        try container.encodeIfPresent(self.players, forKey: .players)
        try container.encodeIfPresent(self.invites, forKey: .invites)
    }
}
