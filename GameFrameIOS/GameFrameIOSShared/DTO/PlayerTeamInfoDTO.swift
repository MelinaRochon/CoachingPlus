//
//  PlayerTeamInfoDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation

public struct PlayerTeamInfoDTO: Codable {
    public let id: String                  // == teamId (doc id)
    public let playerDocId: String
    public var nickname: String?           // optional
    public var jerseyNum: Int          // optional
    public var positions: [SoccerPosition]?
    public var joinedAt: Date?             // optional
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case playerDocId = "player_doc_id"
        case nickname = "nickname"
        case jerseyNum = "jersey_num"
        case positions = "positions"
        case joinedAt = "joined_at"
    }
    
    public init(
        id: String,
        playerDocId: String,
        nickname: String? = nil,
        jerseyNum: Int = 0,
        positions: [SoccerPosition]? = nil,
        joinedAt: Date? = nil
    ) {
        self.id = id
        self.playerDocId = playerDocId
        self.nickname = nickname
        self.positions = positions
        self.jerseyNum = jerseyNum
        self.joinedAt = joinedAt
    }
}
