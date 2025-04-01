//
//  UserDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation

/// Data Transfer Object (DTO) representing a user within the system. This struct contains essential details about a user, including their personal information,
/// contact details, and their type (e.g., coach, player).
///
/// The `UserDTO` is used to transfer and store user-related information across different parts of the system, such as user authentication, profile management,
/// and personalization features.
///
/// ### Properties:
/// - `userId`: A unique identifier for the user. This is an optional field as it may not always be available (e.g., for a new user before registration).
/// - `email`: The email address of the user. This field is required and is typically used for user authentication and communication.
/// - `photoUrl`: An optional URL to the user's profile photo. If available, this can be used to display the user's image within the app.
/// - `userType`: A string indicating the type of user (e.g., "coach," "player," etc.). This field is required to define the user's role within the system.
/// - `firstName`: The user's first name. This is a mutable property and can be updated by the user in their profile settings.
/// - `lastName`: The user's last name. Like `firstName`, this is a mutable property for profile updates.
/// - `dateOfBirth`: An optional field representing the user's date of birth. This can be used to calculate age or for age-based access restrictions.
/// - `phone`: An optional field representing the user's phone number. It can be used for contact purposes or for two-factor authentication.
/// - `country`: An optional field representing the user's country of residence. This can be used for localization, regional preferences, or displaying country-specific content.
struct UserDTO {
    
    /// The unique identifier for the user within the system. This field is optional as it may not be available in certain scenarios (e.g., before user registration).
    let userId: String?
    
    /// The email address of the user, used for authentication and communication purposes. This is a required field.
    let email: String
    
    /// The URL to the user's profile photo. This field is optional and may not always be set, but if available, it allows displaying a user photo.
    var photoUrl: String?
    
    /// The type of user (e.g., "coach", "player"). This field is required to differentiate between different user roles in the system.
    let userType: String
    
    /// The user's first name. This is a mutable field, allowing the user to update their name in their profile.
    var firstName: String
    
    /// The user's last name. Like `firstName`, this field is mutable for updates in the user's profile.
    var lastName: String
    
    /// The user's date of birth. This is an optional field and may be used for age verification or profile personalization.
    var dateOfBirth: Date?
    
    /// The user's phone number. This optional field can be used for contact purposes or as part of two-factor authentication.
    var phone: String?
    
    /// The user's country of residence. This field is optional and can be used for localization or regional settings.
    var country: String?
}
