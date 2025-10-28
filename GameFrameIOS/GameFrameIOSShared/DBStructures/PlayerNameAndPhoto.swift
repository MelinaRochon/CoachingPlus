//
//  PlayerNameAndPhoto.swift
//  GameFrameIOSShared
//
//  Created by Mélina Rochon on 2025-10-26.
//

import Foundation

/// A structure representing a player's basic information, including their ID, name, and photo URL.
public struct PlayerNameAndPhoto {
    
    /// The unique identifier of the player.
    public let playerId: String
    
    /// The full name of the player.
    public let name: String
    
    /// An optional URL pointing to the player's profile photo.
    public let photoURL: URL?
    
    public init(playerId: String, name: String, photoURL: URL?) {
        self.playerId = playerId
        self.name = name
        self.photoURL = photoURL
    }
}
