//
//  AuthenticationProtocols.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

// MARK: - File description

/**
 `AuthenticationProtocols.swift` defines protocols for authentication-related validation,
 ensuring separation of concerns and reusability across different authentication flows.

 ## Overview:
 This file provides two protocols that enforce validation logic for authentication actions:
 - `AuthenticationLoginProtocol`: Ensures that login credentials meet the necessary conditions.
 - `AuthenticationSignUpProtocol`: Ensures that sign-up credentials are valid,
   including support for access-code-based sign-up validation.

 ## Usage:
 These protocols are intended to be adopted by authentication view models,
 enabling structured validation logic while keeping UI components clean.

 ## Protocol Details:
 - `loginIsValid`: A computed property that determines if login credentials are correctly formatted.
 - `signUpIsValid`: A computed property that validates standard sign-up credentials.
 - `signUpWithAccessCodeValid`: A computed property to validate sign-ups using an access code.

 These validation properties can be used in UI bindings to enable or disable buttons dynamically
 based on user input.
 */

// MARK: - Protocols

/// Protocol defining authentication requirements for login.
protocol AuthenticationLoginProtocol {
    /// A computed property that checks whether the login credentials are valid.
    var loginIsValid: Bool { get }
}


/// Protocol defining authentication requirements for sign up.
protocol AuthenticationSignUpProtocol {
    /// A computed property that checks whether the login credentials are valid.
    var signUpIsValid: Bool { get }
    
    var signUpWithAccessCodeValid: Bool { get }
}

