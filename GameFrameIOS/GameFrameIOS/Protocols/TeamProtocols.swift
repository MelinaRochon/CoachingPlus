//
//  TeamProtocols.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

// MARK: - File description

/**
 `TeamProtocols.swift` defines protocols related to team creation and management, ensuring consistency and validation across team-related actions.

 ## Overview:
 This file provides a protocol that enforces validation logic for creating or updating a team:
 - `TeamProtocol`: Ensures that all necessary conditions are met before a team can be added or modified.

 ## Usage:
 The protocol is designed to be adopted by view models responsible for managing team data,
 allowing for structured validation while keeping the UI components clean and concise.

 ## Protocol Details:
 - `addTeamIsValid`: A computed property that determines if the team details meet the required validation criteria.

 This validation property can be used to enable or disable UI elements such as buttons,
 based on whether the provided team data is valid for creation or modification.
 */


// MARK: - Protocols

/// A protocol that defines validation requirements for team-related operations.
/// It ensures that a team's details meet the necessary conditions before being processed.
protocol TeamProtocol {
    /// A computed property that checks if the team details are valid.
    /// A valid team must have:
    /// - A non-empty team name.
    /// - A nickname that does not exceed 10 characters.
    /// - A specified sport, gender, and age group.
    /// - A valid color representation.
    var addTeamIsValid: Bool { get }
}
