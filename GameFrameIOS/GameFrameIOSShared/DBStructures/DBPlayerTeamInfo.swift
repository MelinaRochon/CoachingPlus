//
//  DBPlayerTeamInfo.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation


public struct DBPlayerTeamInfo: Codable {
    public let id: String
    public var jerseyNum: Int?
    public var nickName: String?
    public var positions: [SoccerPosition]?
    public var joinedAt: Date?
    
    public init(
        id: String,
        jerseyNum: Int = 0,
        nickName: String? = nil,
        positions: [SoccerPosition]? = nil,
        joinedAt: Date? = nil
    ) {
        self.id = id
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.positions = positions
        self.joinedAt = joinedAt
    }
    
    
    public init(id: String) {
        self.id = id
        self.jerseyNum = 0
        self.nickName = nil
        self.positions = nil
        self.joinedAt = nil
    }
    
    public init(id: String, playerTeamInfoDTO: PlayerTeamInfoDTO) {
        self.id = id
        self.jerseyNum = playerTeamInfoDTO.jerseyNum
        self.nickName = playerTeamInfoDTO.nickname
        self.positions = playerTeamInfoDTO.positions
        self.joinedAt = playerTeamInfoDTO.joinedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case jerseyNum = "jersey_num"
        case nickName = "nickname"
        case positions = "positions"
        case joinedAt = "added_at"
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.jerseyNum = try container.decodeIfPresent(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.positions = try container.decodeIfPresent([SoccerPosition].self, forKey: .positions)
        self.joinedAt = try container.decodeIfPresent(Date.self, forKey: .joinedAt)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.jerseyNum, forKey: .jerseyNum)
        try container.encodeIfPresent(self.nickName, forKey: .nickName)
        try container.encodeIfPresent(self.positions, forKey: .positions)
        try container.encodeIfPresent(self.joinedAt, forKey: .joinedAt)
    }
}
