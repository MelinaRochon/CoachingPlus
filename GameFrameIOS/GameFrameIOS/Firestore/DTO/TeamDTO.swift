//
//  TeamDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//

import Foundation

/// Data Transfer Object (DTO) representing a sports team in the system. This struct is used to encapsulate key details about a team, including its name, sport,
/// team members (coaches and players), and related properties like the team's logo, color, and access code for joining the team.
///
/// The `TeamDTO` struct is essential for managing team data and facilitating interactions between coaches, players, and the system. It includes both mandatory
/// and optional fields that enable flexibility in the team creation and management process.
///
/// ### Properties:
/// - `teamId`: The unique identifier for the team, typically assigned by the system. This is a required field to distinguish teams from one another.
/// - `name`: The official name of the team. This is a required field.
/// - `teamNickname`: The team's nickname, which can be used as an informal reference. This is a required field.
/// - `sport`: The sport or game type the team participates in (e.g., "Soccer", "Basketball"). This is a required field.
/// - `logoUrl`: An optional string representing the URL or path to the team's logo image.
/// - `colour`: An optional string representing the primary color associated with the team's uniform or branding.
/// - `gender`: The gender category of the team (e.g., "Male", "Female", "Co-ed"). This is a required field.
/// - `ageGrp`: The age group that the team belongs to (e.g., "U12", "U16"). This is a required field.
/// - `accessCode`: An optional string that represents a unique access code required for players or coaches to join the team.
/// - `coaches`: A list of coach identifiers (strings), indicating the coaches that belong to the team. This is a required field.
/// - `players`: An optional list of player identifiers (strings), representing the players enrolled in the team.
/// - `invites`: An optional list of invitee identifiers (strings), representing players or coaches who have been invited to join the team but have not yet accepted.
struct TeamDTO {
    
    /// The unique identifier for the team. This field is required and is used to distinguish each team in the system.
    let teamId: String
    
    /// The official name of the team. This field is required.
    let name: String
    
    /// The nickname of the team, which is often used informally. This field is required.
    let teamNickname: String
    
    /// The sport or game the team participates in (e.g., "Soccer", "Basketball"). This field is required.
    let sport: String
    
    /// An optional URL or path to the team's logo image. This field is optional and can be used for displaying the team's logo in the app.
    let logoUrl: String?
    
    /// An optional field representing the primary color associated with the team's branding. This field is optional.
    let colour: String?
    
    /// The gender category of the team (e.g., "Male", "Female", "Co-ed"). This field is required.
    let gender: String
    
    /// The age group the team belongs to (e.g., "U12", "U16"). This field is required.
    let ageGrp: String
    
    /// An optional access code that is required for players or coaches to join the team. This field is optional.
    let accessCode: String?
    
    /// A list of coach identifiers (strings) representing the coaches of the team. This field is required to link the team to its coaches.
    let coaches: [String]
    
    /// A list of player identifiers (strings) representing the players who belong to the team. This field is optional.
    let players: [String]?
    
    /// A list of invitee identifiers (strings) representing players or coaches who have been invited to join the team but have not yet accepted the invite.
    /// This field is optional.
    let invites: [String]?
}
