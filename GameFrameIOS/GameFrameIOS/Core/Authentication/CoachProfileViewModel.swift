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
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // TO DO - Create error
        }
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await AuthenticationManager.shared.resetPassword(email: email) // TO DO - NEED TO VERIFY USER GETS EMAIL
    }
    
    func loadCurrentUser() async throws {
        //Task {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        //}
    }
}
