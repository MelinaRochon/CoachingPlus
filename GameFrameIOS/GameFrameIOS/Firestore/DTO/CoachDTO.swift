//
//  CoachDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation

/// `CoachDTO` is a Data Transfer Object (DTO) that represents a coach's data structure for communication between the app and backend.
/// The DTO is used to simplify the transfer of data, focusing on the specific details needed for the coach in the app's logic.
///
/// ### Properties:
/// - `coachId`: A unique identifier for the coach. This ID is used to uniquely identify the coach within the system.
/// - `teamsCoaching`: An optional array of team identifiers (represented as strings) that the coach is associated with.
///    This field contains the list of teams the coach is actively coaching. If the coach is not coaching any teams, this property will be `nil`.
struct CoachDTO {
    
    /// A unique identifier for the coach.
    /// This ID is used to uniquely identify the coach in the system and is typically retrieved from the backend or database.
    let coachId: String
    
    /// An optional list of team identifiers that the coach is associated with.
    /// Each string in this array represents a unique identifier for a team. If the coach is coaching multiple teams,
    /// this list will contain those team IDs. If the coach is not coaching any teams, this property will be `nil`.
    let teamsCoaching: [String]?
}
