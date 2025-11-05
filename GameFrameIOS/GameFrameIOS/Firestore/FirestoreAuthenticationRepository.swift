//
//  FirestoreAuthenticationRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation
import FirebaseAuth
import GameFrameIOSShared
import FirebaseCore
import FirebaseFirestore


public final class FirestoreAuthenticationRepository: AuthenticationRepository {
    
    private let db: Firestore

    init() {
        guard FirebaseApp.app() != nil else {
            fatalError("FirestoreAuthenticationRepository initialized before FirebaseApp.configure()")
        }
        db = Firestore.firestore()
    }

    /// GET - Retrieves the currently authenticated user.
    /// - Throws: An error if no user is signed in.
    /// - Returns: `AuthDataResultModel` containing user details.
    public func getAuthenticatedUser() throws -> AuthDataResultModel {
        // Check the user locally
        guard let user = Auth.auth().currentUser else { // is user authenticated or not
            throw URLError(.badServerResponse) // TODO: Implement a custom error type.
        }
        print("The authenticated user is: \(user.uid)")
        let dbUser = UserForDB(uid: user.uid, email: user.email ?? "", photoURL: user.photoURL)
        return AuthDataResultModel(user: dbUser)
    }
    
    
    /// POST - Creates a new user account in Firebase Authentication.
    /// - Parameters:
    ///   - email: The email address of the new user.
    ///   - password: The password for the new account.
    /// - Throws: An error if account creation fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    public func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let dbUser = UserForDB(uid: authDataResult.user.uid, email: authDataResult.user.email ?? "", photoURL: authDataResult.user.photoURL)
        return AuthDataResultModel(user: dbUser)
    }
    
    
    /// Signs out the currently authenticated user.
    /// - Throws: An error if sign-out fails.
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    /// Signs in a user with email and password.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The user's password.
    /// - Throws: An error if sign-in fails.
    /// - Returns: `AuthDataResultModel` containing user details.
    @discardableResult
    public func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let dbUser = UserForDB(uid: authDataResult.user.uid, email: authDataResult.user.email ?? "", photoURL: authDataResult.user.photoURL)
        return AuthDataResultModel(user: dbUser)
    }
    
    
    /// Sends a password reset email to the specified email address.
    /// - Parameter email: The email address associated with the account.
    /// - Throws: An error if the request fails.
    public func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    
    /// Updates the authenticated user's password.
    /// - Parameter password: The new password.
    /// - Throws: An error if the update fails.
    public func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TODO: Create custom error guard
        }
        try await user.updatePassword(to: password)
    }
    
    
    /// Updates the authenticated user's email address.
    /// - Parameter email: The new email address.
    /// - Throws: An error if the update fails.
    public func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TODO: Create custom error guard
        }
        try await user.updateEmail(to: email)
    }
}
