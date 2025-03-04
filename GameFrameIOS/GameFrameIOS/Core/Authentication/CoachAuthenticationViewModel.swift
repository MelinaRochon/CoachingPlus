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
final class authenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()
    @Published var phone = ""
    @Published var country = "Canada"
    @Published var timeZone = ""

    
    func signIn() async throws {
        print("SignIn Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        //try await AuthenticationManager.shared.signInUser(email: email, password: password)
        let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
        print("user id: \(authDataResult.uid)")
        //let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, photoUrl: authDataResult.photoUrl, dateCreated: Date(), userType: "Coach")
        try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func signUp(userType: String) async throws {
        print("\(userType) SignUp Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        guard email.contains("@") else {
            print("Not a valid email")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, photoUrl: authDataResult.photoUrl, userType: userType, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, country: country, timeZone: timeZone)
        try await UserManager.shared.createNewUser(user: user)
    }
}
