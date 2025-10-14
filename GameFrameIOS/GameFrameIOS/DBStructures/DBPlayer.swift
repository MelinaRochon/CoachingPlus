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
struct DBPlayer: Codable {
    let id: String
    var playerId: String?
    var jerseyNum: Int
    var nickName: String?
    var gender: String?
    let profilePicture: String?
    var teamsEnrolled: [String]? // TODO: Think about leaving it as it is or putting it as optional
    
    // Guardian information - optional
    var guardianName: String?
    var guardianEmail: String?
    var guardianPhone: String?
    
    init(
        id: String,
        playerId: String? = nil,
        jerseyNum: Int,
        nickName: String? = nil,
        gender: String? = nil,
        guardianName: String? = nil,
        guardianEmail: String? = nil,
        guardianPhone: String? = nil,
        profilePicture: String? = nil,
        teamsEnrolled: [String]? = nil
    ) {
        self.id = id
        self.playerId = playerId
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.gender = gender
        self.guardianName = guardianName
        self.guardianEmail = guardianEmail
        self.guardianPhone = guardianPhone
        self.profilePicture = profilePicture
        self.teamsEnrolled = teamsEnrolled
    }
    
    init(id: String) {
        self.id = id
        self.playerId = nil
        self.jerseyNum = 0
        self.nickName = nil
        self.gender = nil
        self.guardianName = nil
        self.guardianEmail = nil
        self.guardianPhone = nil
        self.profilePicture = nil
        self.teamsEnrolled = []
    }
    
    init(id: String, playerDTO: PlayerDTO) {
        self.id = id
        self.playerId = playerDTO.playerId
        self.jerseyNum = playerDTO.jerseyNum
        self.nickName = playerDTO.nickName
        self.gender = playerDTO.gender
        self.guardianName = playerDTO.guardianName
        self.guardianEmail = playerDTO.guardianEmail
        self.guardianPhone = playerDTO.guardianPhone
        self.profilePicture = playerDTO.profilePicture
        self.teamsEnrolled = playerDTO.teamsEnrolled
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case playerId = "player_id"
        case jerseyNum = "jersey_num"
        case nickName = "nickname"
        case gender = "gender"
        case guardianName = "guardian_name"
        case guardianEmail = "guardian_email"
        case guardianPhone = "guardian_phone"
        case profilePicture = "profile_picture"
        case teamsEnrolled = "teams_enrolled"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.playerId = try container.decodeIfPresent(String.self, forKey: .playerId)
        self.jerseyNum = try container.decode(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.guardianName = try container.decodeIfPresent(String.self, forKey: .guardianName)
        self.guardianEmail = try container.decodeIfPresent(String.self, forKey: .guardianEmail)
        self.guardianPhone = try container.decodeIfPresent(String.self, forKey: .guardianPhone)
        self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        self.teamsEnrolled = try container.decode([String].self, forKey: .teamsEnrolled)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.playerId, forKey: .playerId)
        try container.encode(self.jerseyNum, forKey: .jerseyNum)
        try container.encodeIfPresent(self.nickName, forKey: .nickName)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.guardianName, forKey: .guardianName)
        try container.encodeIfPresent(self.guardianEmail, forKey: .guardianEmail)
        try container.encodeIfPresent(self.guardianPhone, forKey: .guardianPhone)
        try container.encodeIfPresent(self.profilePicture, forKey: .profilePicture)
        try container.encodeIfPresent(self.teamsEnrolled, forKey: .teamsEnrolled)
    }
}
