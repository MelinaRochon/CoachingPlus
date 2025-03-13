//
//  AuthenticationManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import Foundation
import FirebaseAuth

/**
 Authentication Data Structure - This structure is called when the user tries to connect to the database to either
 authenticate (signIn and signOut), to reset or update the password, to update its email.
 **/
struct AuthDataResultModel {
    let uid: String
    let email: String
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email ?? ""
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    // singleton pattern - maybe use something else (not the best method)
    // How to use dependency injection tutorial!
    
    static let shared = AuthenticationManager()
    private init() { }
    
    /**This function gets the information of the user that is signed in. **/
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        // Check the user locally
        guard let user = Auth.auth().currentUser else { // is user authenticated or not
            throw URLError(.badServerResponse) // will need to create own error
        }
        print("The authenticated user is: \(user.uid)")

        return AuthDataResultModel(user: user)
    }
    
    /** This function creates a user authentication, which is sent to Firebase **/
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /** This function signs out user */
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /** Sign in user **/
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /** Reset the user's password by sending an email of confirmation to the user. **/
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /** Update authenticated user's password */
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TO DO - Create custom error guard
        }
        try await user.updatePassword(to: password)
    }
    
    /** Update authenticated user's email */
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // TO DO - Create custom error guard
        }
        try await user.updateEmail(to: email)
    }
    
}
