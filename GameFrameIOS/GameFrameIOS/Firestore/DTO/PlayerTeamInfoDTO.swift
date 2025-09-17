//
//  PlayerTeamInfoDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation

struct PlayerTeamInfoDTO: Codable {
    let id: String                  // == teamId (doc id)
    var nickname: String?           // optional
    var jerseyNum: Int?          // optional
    var joinedAt: Date?             // optional
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nickname = "nickname"
        case jerseyNum = "jersey_num"
        case joinedAt = "joined_at"
    }
}
