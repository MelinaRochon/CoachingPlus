//
//  PlayerDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation

struct PlayerDTO {
    let playerId: String?
    var jerseyNum: Int
    var nickName: String?
    let gender: String?
    let profilePicture: String?
    let teamsEnrolled: [String] // TO DO - Think about leaving it as it is or putting it as optional
    
    // Guardian information - optional
    var guardianName: String?
    var guardianEmail: String?
    var guardianPhone: String?
}
