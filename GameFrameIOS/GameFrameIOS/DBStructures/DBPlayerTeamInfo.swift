//
//  DBPlayerTeamInfo.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation


struct DBPlayerTeamInfo: Codable {
    let id: String
    var jerseyNum: Int?
    var nickName: String?
    var joinedAt: Date?
    
    init(
        id: String,
        jerseyNum: Int? = nil,
        nickName: String? = nil,
        joinedAt: Date? = nil
    ) {
        self.id = id
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.joinedAt = joinedAt
    }
    
    
    init(id: String) {
        self.id = id
        self.jerseyNum = nil
        self.nickName = nil
        self.joinedAt = nil
    }
    
    init(id: String, playerTeamInfoDTO: PlayerTeamInfoDTO) {
        self.id = id
        self.jerseyNum = playerTeamInfoDTO.jerseyNum
        self.nickName = playerTeamInfoDTO.nickname
        self.joinedAt = playerTeamInfoDTO.joinedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case jerseyNum = "jersey_num"
        case nickName = "nickname"
        case joinedAt = "added_at"
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.jerseyNum = try container.decode(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.jerseyNum, forKey: .jerseyNum)
        try container.encodeIfPresent(self.nickName, forKey: .nickName)
        try container.encodeIfPresent(self.joinedAt, forKey: .joinedAt)
    }
}
