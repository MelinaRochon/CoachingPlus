//
//  PlayerLoginModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation

@MainActor
/** Observable object to be called when the player wants to authenticate by performing one of the
 following action: signIn, signUp. */
final class playerAuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signInPlayer() async throws {
        print("Player - SignIn Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func signUpPlayer() async throws {
        print("Player - SignUp Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}
