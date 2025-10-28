//
//  PlayerDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation


/// Data Transfer Object (DTO) representing a player in the system. This struct encapsulates essential details about a player, including personal information,
/// team enrollments, and guardian information (for minors). It is primarily used for organizing and transferring player-related data within the application.
///
/// The `PlayerDTO` struct is flexible enough to accommodate both adult players and minors. For minor players, guardian details (e.g., name, email, and phone) can
/// be stored as optional fields. The struct allows for easy management of player profiles, including personal identifiers, team participation, and contact details.
///
/// ### Properties:
/// - `playerId`: A unique identifier for the player, typically assigned by the system. It is optional as not all player records might have it at creation.
/// - `jerseyNum`: The player's jersey number. It is a required field, as it uniquely identifies a player within a team.
/// - `nickName`: An optional string for storing the player's nickname, if applicable.
/// - `gender`: An optional string indicating the player's gender, useful for categorizing players in gender-specific teams or competitions.
/// - `profilePicture`: An optional string that can store a URL or path to the player's profile picture.
/// - `teamsEnrolled`: A list of team identifiers (strings) that the player is enrolled in. This is a required field, as it links the player to the teams they are part of.
/// - `guardianName`: An optional string to store the name of the player's guardian (for minors).
/// - `guardianEmail`: An optional string to store the guardian's email address.
/// - `guardianPhone`: An optional string to store the guardian's phone number.
public struct PlayerDTO {
    
    /// The unique identifier for the player. This field is optional because the player might not have an ID assigned at the time of creation.
    public let playerId: String?
    
    /// The jersey number of the player. This is a required field to identify the player within the team.
    public var jerseyNum: Int
    
    /// The nickname of the player, if any. This is an optional field.
    public var nickName: String?
    
    /// The gender of the player, if provided. This field is optional and can be used for sorting or filtering players by gender.
    public let gender: String?
    
    /// A link or path to the player's profile picture. This field is optional as not all players may have an image associated with their profile.
    public let profilePicture: String?
    
    /// A list of team IDs that the player is enrolled in. This field is required, ensuring that the player is linked to one or more teams.
    public let teamsEnrolled: [String] // TO DO - Think about leaving it as it is or making it optional
    
    // Guardian information - optional, applicable to minor players
    /// The name of the player's guardian, if applicable. This field is optional and is used for players who are minors.
    public var guardianName: String?
    
    /// The guardian's email address, if applicable. This field is optional.
    public var guardianEmail: String?
    
    /// The guardian's phone number, if applicable. This field is optional.
    public var guardianPhone: String?
    
    public init(playerId: String?, jerseyNum: Int, nickName: String? = nil, gender: String?, profilePicture: String?, teamsEnrolled: [String], guardianName: String? = nil, guardianEmail: String? = nil, guardianPhone: String? = nil) {
        self.playerId = playerId
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.gender = gender
        self.profilePicture = profilePicture
        self.teamsEnrolled = teamsEnrolled
        self.guardianName = guardianName
        self.guardianEmail = guardianEmail
        self.guardianPhone = guardianPhone
    }
}
