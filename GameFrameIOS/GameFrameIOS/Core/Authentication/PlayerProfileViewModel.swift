//
//  PlayerProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation

@MainActor
final class PlayerProfileViewModel: ObservableObject {
    
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
        try await AuthenticationManager.shared.resetPassword(email: email) // NEED TO VERIFY USER GETS EMAIL
    }
}
