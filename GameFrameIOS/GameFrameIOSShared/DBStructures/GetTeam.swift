//
//  GetTeam.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-26.
//

import Foundation

public struct GetTeam: Equatable {
    public var teamId: String
    public var name: String
    public var nickname: String
    
    public init(teamId: String, name: String, nickname: String) {
        self.teamId = teamId
        self.name = name
        self.nickname = nickname
    }
}
