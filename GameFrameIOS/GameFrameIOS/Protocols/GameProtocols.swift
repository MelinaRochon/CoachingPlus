//
//  GameProtocols.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

// MARK: - File description

//  This file contains the protocols related to game functionality in the GameFrame iOS application.
///
///  - `GameProtocol`: A protocol that defines a requirement for game-related objects to have a validation property.
///    This is used to check if a game meets the necessary criteria for being added (e.g., having a title and a set time).
///

// MARK: - Game protocol

/// A protocol that defines a requirement for a game-related object to have a validation property.
///
/// This protocol is used to check if a game meets certain criteria for being valid for addition.
/// Classes or structs that conform to this protocol must implement the `addGameIsValid` computed property,
/// which determines whether the game is valid for addition based on certain conditions (e.g., title and time).
///
/// Example usage:
/// A class that conforms to `GameProtocol` would use this property to check if the game can be added
/// to a list or database, ensuring that the game has all necessary information before it is created or saved.
protocol GameProtocol {
    /// A computed property that returns a `Bool` indicating if the game is valid to be added.
    ///
    /// - Returns: `true` if the game is valid (e.g., title is non-empty and time is set); `false` otherwise.
    var addGameIsValid: Bool { get }
}
