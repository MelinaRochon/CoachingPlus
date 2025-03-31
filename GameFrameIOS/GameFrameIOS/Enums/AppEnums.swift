//
//  AppEnums.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

// MARK: - File description

/**
 This file contains the definitions of various enums used throughout the GameFrame iOS application. These enums help standardize different user types, status types, and error states used in the system.

 **Enum Descriptions:**

 1. **UserType**:
 2. **StatusEnum**:
 3. **TeamValidationError**:
*/

// MARK: - Enums

/// **UserType**: Enum representing different user types in the system.
/// - This enum represents the different types of users in the system. The two possible values are:
/// - `coach`: Refers to a user who is a coach.
/// - `player`: Refers to a user who is a player.
/// - This enum can be used for distinguishing between different user roles in the authentication system, access control, and content customization.
enum UserType {
    case coach
    case player
}

/// **StatusEnum**: Enum representing different status types in the system when creating an `Invite`.
/// - This enum defines the possible statuses for an `Invite`. An `Invite` might represent an invitation sent to a user (player/coach) to join a team or other system-specific event.
/// - `pending`: The invite is still waiting for the recipient to respond (i.e., hasn't been accepted yet).
/// - `accepted`: The invite has been accepted by the recipient.
/// - This enum is useful for managing and tracking the state of invitations in the system, whether it's still waiting for action or has been completed.
enum StatusEnum {
    case pending
    case accepted
}

/// **TeamValidationError**: Enum representing different error status type
/// - This enum represents error states encountered during team-related validation, such as verifying a team’s access code.
/// - `invalidAccessCode`: Represents the error that occurs when the access code provided for a team is invalid.
/// - It conforms to the `Error` protocol, meaning it can be used as a type of error in Swift's error handling system. This error type helps in managing team-related validation failures gracefully.
enum TeamValidationError: Error {
    case invalidAccessCode
}
