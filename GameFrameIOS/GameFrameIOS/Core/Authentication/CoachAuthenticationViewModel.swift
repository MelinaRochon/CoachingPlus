//
//  AuthenticationViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
@MainActor
/** Observable object to be called when the coach wants to authenticate by performing one of the
 following action: signIn, signUp. */
final class coachAuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signInCoach() async throws {
        print("Coach - SignIn Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        //try await AuthenticationManager.shared.signInUser(email: email, password: password)
        let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: authDataResult, userType: "Coach")
    }
    
    func signUpCoach() async throws {
        print("Coach - SignUp Test!")
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
