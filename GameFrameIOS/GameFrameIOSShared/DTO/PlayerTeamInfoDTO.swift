//
//  PlayerTeamInfoDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation

public struct PlayerTeamInfoDTO: Codable {
    public let id: String                  // == teamId (doc id)
    public let playerId: String
    public var nickname: String?           // optional
    public var jerseyNum: Int?          // optional
    public var joinedAt: Date?             // optional
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case playerId = "player_id"
        case nickname = "nickname"
        case jerseyNum = "jersey_num"
        case joinedAt = "joined_at"
    }
    
    public init(id: String, playerId: String, nickname: String? = nil, jerseyNum: Int? = nil, joinedAt: Date? = nil) {
        self.id = id
        self.playerId = playerId
        self.nickname = nickname
        self.jerseyNum = jerseyNum
        self.joinedAt = joinedAt
    }
}
