//
//  CoachProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
@MainActor
/** Observable object to be called when the coach wants to perform one of the following action: logOut, reset password. */
final class CoachProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    /** To log out the user */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    /** To reset the user's password **/
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await AuthenticationManager.shared.resetPassword(email: authUser.email) // TO DO - NEED TO VERIFY USER GETS EMAIL
    }
    
    func loadCurrentUser() async throws {
        //Task {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        //}
    }
    
    /** Update the coach's information on the database */
    func updateCoachInformation(phone: String, membershipDetails: String) {
        guard var user else { return }
        guard let userId = user.userId else { return }

        user.phone = phone
        Task {
            try await UserManager.shared.updateCoachProfile(user: user)
            self.user = try await UserManager.shared.getUser(userId: userId)
        }
        
    }
}
