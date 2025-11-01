//
//  CoachProtocols.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-31.
//

import Foundation

protocol UserEditProfileProtocol {
    var saveProfileIsValid: Bool { get }
    
}

protocol TeamSaveProtocol {
    var saveTeamIfValid: Bool { get }
}
