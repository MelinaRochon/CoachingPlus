//
//  DBPlayer.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/**
 A struct representing a player in the database.
 This structure conforms to Codable to easily encode/decode data from Firestore.
 */
public struct DBPlayer: Codable {
    public let id: String
    public var playerId: String?
    public var gender: String?
    public let profilePicture: String?
    public var teamsEnrolled: [String]? // TODO: Think about leaving it as it is or putting it as optional
    
    // Guardian information - optional
    public var guardianName: String?
    public var guardianEmail: String?
    public var guardianPhone: String?
    
    public init(
        id: String,
        playerId: String? = nil,
        gender: String? = nil,
        guardianName: String? = nil,
        guardianEmail: String? = nil,
        guardianPhone: String? = nil,
        profilePicture: String? = nil,
        teamsEnrolled: [String]? = nil
    ) {
        self.id = id
        self.playerId = playerId
        self.gender = gender
        self.guardianName = guardianName
        self.guardianEmail = guardianEmail
        self.guardianPhone = guardianPhone
        self.profilePicture = profilePicture
        self.teamsEnrolled = teamsEnrolled
    }
    
    public init(id: String) {
        self.id = id
        self.playerId = nil
        self.gender = nil
        self.guardianName = nil
        self.guardianEmail = nil
        self.guardianPhone = nil
        self.profilePicture = nil
        self.teamsEnrolled = []
    }
    
    public init(id: String, playerDTO: PlayerDTO) {
        self.id = id
        self.playerId = playerDTO.playerId
        self.gender = playerDTO.gender
        self.guardianName = playerDTO.guardianName
        self.guardianEmail = playerDTO.guardianEmail
        self.guardianPhone = playerDTO.guardianPhone
        self.profilePicture = playerDTO.profilePicture
        self.teamsEnrolled = playerDTO.teamsEnrolled
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case playerId = "player_id"
        case gender = "gender"
        case guardianName = "guardian_name"
        case guardianEmail = "guardian_email"
        case guardianPhone = "guardian_phone"
        case profilePicture = "profile_picture"
        case teamsEnrolled = "teams_enrolled"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.playerId = try container.decodeIfPresent(String.self, forKey: .playerId)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.guardianName = try container.decodeIfPresent(String.self, forKey: .guardianName)
        self.guardianEmail = try container.decodeIfPresent(String.self, forKey: .guardianEmail)
        self.guardianPhone = try container.decodeIfPresent(String.self, forKey: .guardianPhone)
        self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        self.teamsEnrolled = try container.decode([String].self, forKey: .teamsEnrolled)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.playerId, forKey: .playerId)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.guardianName, forKey: .guardianName)
        try container.encodeIfPresent(self.guardianEmail, forKey: .guardianEmail)
        try container.encodeIfPresent(self.guardianPhone, forKey: .guardianPhone)
        try container.encodeIfPresent(self.profilePicture, forKey: .profilePicture)
        try container.encodeIfPresent(self.teamsEnrolled, forKey: .teamsEnrolled)
    }
}
