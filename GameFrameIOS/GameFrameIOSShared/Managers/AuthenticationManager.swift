//
//  AuthenticationManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import Foundation

/**
 A singleton manager responsible for handling Firebase Authentication-related tasks.
 The `AuthenticationManager` class provides the following functionality for managing user authentication:
 - Signing in users with email and password.
 - Creating new user accounts.
 - Signing out the currently authenticated user.
 - Resetting user passwords and updating account details such as email and password.
 
 This class is implemented as a singleton to ensure a single, global instance for authentication tasks throughout the app.

 Key methods in this class:
 - `getAuthenticatedUser`: Retrieves the currently authenticated user.
 - `createUser`: Creates a new user account using email and password.
 - `signOut`: Signs out the current authenticated user.
 - `signInUser`: Signs in an existing user using email and password.
 - `resetPassword`: Sends a password reset email to the user.
 - `updatePassword`: Updates the authenticated user's password.
 - `updateEmail`: Updates the authenticated user's email address.

 Singleton usage is enforced by the private initializer, ensuring that only one instance of the manager is used across the app. This approach follows the Singleton design pattern, but dependency injection may offer a more flexible and testable approach (recommended for larger projects).
 */
public final class AuthenticationManager {
    
    private let repo: AuthenticationRepository
        
    // No default value here — we inject it from the app or test target
    public init(repo: AuthenticationRepository) {
        self.repo = repo
    }
    
    /// GET - Retrieves the currently authenticated user.
    /// - Throws: An error if no user is signed in.
    /// - Returns: `AuthDataResultModel` containing user details.
    public func getAuthenticatedUser() throws -> AuthDataResultModel {
        return try repo.getAuthenticatedUser()
    }
    
    
    /// POST - Creates a new user account in Firebase Authentication.
    /// - Parameters:
    ///   - email: The email address of the new user.
    ///   - password: The password for the new account.
    /// - Throws: An error if account creation fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    public func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        return try await repo.createUser(email: email, password: password)
    }
    
    
    /// Signs out the currently authenticated user.
    /// - Throws: An error if sign-out fails.
    public func signOut() throws {
        try repo.signOut()
    }
    
    
    /// Signs in a user with email and password.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The user's password.
    /// - Throws: An error if sign-in fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    public func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        return try await repo.signInUser(email: email, password: password)
    }
    
    
    /// Sends a password reset email to the specified email address.
    /// - Parameter email: The email address associated with the account.
    /// - Throws: An error if the request fails.
    public func resetPassword(email: String) async throws {
        try await repo.resetPassword(email: email)
    }
    
    
    /// Updates the authenticated user's password.
    /// - Parameter password: The new password.
    /// - Throws: An error if the update fails.
    public func updatePassword(password: String) async throws {
        try await repo.updatePassword(password: password)
    }
    
    
    /// Updates the authenticated user's email address.
    /// - Parameter email: The new email address.
    /// - Throws: An error if the update fails.
    public func updateEmail(email: String) async throws {
        try await repo.updateEmail(email: email)
    }
}
