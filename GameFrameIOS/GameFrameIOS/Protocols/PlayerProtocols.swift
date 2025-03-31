//
//  PlayerProtocol.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

// MARK: - File description

 /** This file defines the `PlayerProtocol` that enforces the validation requirement
  for adding a player to a team. Any view or model that handles player data and
  is responsible for adding players to a team must conform to this protocol.
  The protocol ensures that player data is validated before any addition to a team,
  providing a consistent interface for validation across different views and models.

  ### Features:
  - Contains a computed property `addPlayerToTeamIsValid` to validate player data,
    ensuring the necessary fields are filled in correctly.
  */

// MARK: - Player protocol

/// The `PlayerProtocol` defines the validation requirements for adding a player to a team.
/// Any view or model that manages player data and facilitates adding players to a team
/// must conform to this protocol. The `addPlayerToTeamIsValid` property is used to ensure
/// the necessary player details are provided and valid before proceeding with the addition.
///
/// Conformance to this protocol guarantees consistency in validating player data across
/// different parts of the application.
protocol PlayerProtocol {
    /// A computed property that determines if the player's data is valid for adding to the team.
    /// - Returns: `true` if the player's first name, last name, and email are provided,
    ///           and the email contains the "@" symbol. Otherwise, `false`.
    var addPlayerToTeamIsValid: Bool { get }
}
