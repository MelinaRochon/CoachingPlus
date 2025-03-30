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
 A manager responsible for handling authentication-related tasks, including:
 - Signing in and signing out users
 - Creating accounts
 - Resetting and updating passwords
 - Updating email addresses
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
