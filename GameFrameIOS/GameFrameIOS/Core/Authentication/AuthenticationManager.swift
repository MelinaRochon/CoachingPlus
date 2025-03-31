//
//  AuthenticationManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import Foundation
import FirebaseAuth

/**
 A data model representing authentication details of a signed-in user.
 This structure helps store essential user data retrieved from Firebase.
 */
struct AuthDataResultModel {
    let uid: String
    let email: String
    let photoUrl: String?
    
    /// Initializes the model using a Firebase `User` object.
    /// - Parameter user: The authenticated Firebase user.
    init(user: User) {
        self.uid = user.uid
        self.email = user.email ?? ""
        self.photoUrl = user.photoURL?.absoluteString
    }
}

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
final class AuthenticationManager {
    
    // singleton pattern - maybe use something else (not the best method)
    // How to use dependency injection tutorial!
    static let shared = AuthenticationManager()
    
    /// Private initializer to enforce singleton usage.
    private init() { }
    
    
    /// GET - Retrieves the currently authenticated user.
    /// - Throws: An error if no user is signed in.
    /// - Returns: `AuthDataResultModel` containing user details.
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        // Check the user locally
        guard let user = Auth.auth().currentUser else { // is user authenticated or not
            throw URLError(.badServerResponse) // TODO: Implement a custom error type.
        }
        print("The authenticated user is: \(user.uid)")

        return AuthDataResultModel(user: user)
    }
    
    
    /// POST - Creates a new user account in Firebase Authentication.
    /// - Parameters:
    ///   - email: The email address of the new user.
    ///   - password: The password for the new account.
    /// - Throws: An error if account creation fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    /// Signs out the currently authenticated user.
    /// - Throws: An error if sign-out fails.
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    /// Signs in a user with email and password.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The user's password.
    /// - Throws: An error if sign-in fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    /// Sends a password reset email to the specified email address.
    /// - Parameter email: The email address associated with the account.
    /// - Throws: An error if the request fails.
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    /// Updates the authenticated user's password.
    /// - Parameter password: The new password.
    /// - Throws: An error if the update fails.
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TODO: Create custom error guard
        }
        try await user.updatePassword(to: password)
    }
    
    
    /// Updates the authenticated user's email address.
    /// - Parameter email: The new email address.
    /// - Throws: An error if the update fails.
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TODO: Create custom error guard
        }
        try await user.updateEmail(to: email)
    }
    
}
