//
//  AuthenticationRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

/// A protocol defining the core authentication operations for managing user accounts.
///
/// This abstraction allows different authentication backends (e.g., Firebase, custom APIs)
/// to provide consistent authentication behavior through dependency injection.
public protocol AuthenticationRepository {
    
    // MARK: - User Retrieval
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Returns: An `AuthDataResultModel` representing the authenticated user's data.
    /// - Throws: An error if no user is currently authenticated or if the operation fails.
    func getAuthenticatedUser() throws -> AuthDataResultModel

    // MARK: - Account Creation
    
    /// Creates a new user account with the specified email and password.
    ///
    /// - Parameters:
    ///   - email: The email address to associate with the new user account.
    ///   - password: The password for the new account.
    /// - Returns: An `AuthDataResultModel` containing the newly created user’s authentication information.
    /// - Throws: An error if the account creation fails (e.g., invalid email format, weak password, or network error).
    func createUser(email: String, password: String) async throws -> AuthDataResultModel

    // MARK: - Authentication Actions
    
    /// Signs out the currently authenticated user.
    ///
    /// - Throws: An error if the sign-out operation fails.
    func signOut() throws

    /// Signs in a user using the specified email and password credentials.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: An `AuthDataResultModel` representing the signed-in user.
    /// - Throws: An error if the credentials are invalid or if the sign-in process fails.
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel

    // MARK: - Account Recovery & Updates
    
    /// Sends a password reset email to the specified address.
    ///
    /// - Parameter email: The email address associated with the account to reset.
    /// - Throws: An error if the email is invalid or if the reset process fails.
    func resetPassword(email: String) async throws

    /// Updates the password of the currently authenticated user.
    ///
    /// - Parameter password: The new password to set.
    /// - Throws: An error if the update fails (e.g., weak password or expired session).
    func updatePassword(password: String) async throws

    /// Updates the email address of the currently authenticated user.
    ///
    /// - Parameter email: The new email address to associate with the account.
    /// - Throws: An error if the update fails (e.g., invalid email format or authentication required).
    func updateEmail(email: String) async throws
}
