//
//  TeamDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//

import Foundation

struct TeamDTO {
    let teamId: String
    let name: String
    let sport: String
    let logoUrl: String?
    let colour: String?
    let gender: String
    let ageGrp: String
    let accessCode: String?
    let coaches: [String]
    let players: [String]?
    let invites: [String]?
}
