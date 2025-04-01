//
//  CoachProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation

/**
  This file defines the `CoachProfileViewModel`, an observable object that manages the coach's
  profile information and actions in the "GameFrameIOS" app. It is responsible for handling the
  coach's authentication and updating their profile data. The ViewModel is used to manage tasks
  related to logging out, resetting passwords, and updating both the coach's and player's profile information.

  Key functionalities include:
  - **Log out**: The coach can log out of the app.
  - **Reset password**: The coach can reset their password by triggering an email reset.
  - **Load current user**: Fetches the authenticated coach’s profile details from the database.
  - **Load player**: Loads a specific player's information based on the user and player document IDs.
  - **Update player information**: Updates the player's jersey number and nickname in the database.
  - **Update coach information**: Updates the coach's phone number and membership details in the database.

  The ViewModel relies on `AuthenticationManager`, `UserManager`, and `PlayerManager` for
  managing authentication, and interacting with the user and player data stored in the database.
  It provides asynchronous methods that update the UI on completion of background tasks using the `@MainActor` annotation.

  This ViewModel is crucial for managing the coach’s interactions with the app, particularly in terms of
  updating personal and player information as well as handling authentication-related actions.
*/
@MainActor
final class CoachProfileViewModel: ObservableObject {
    
    /// Published state variables to store user and player information
    @Published private(set) var user: DBUser? = nil // Holds the authenticated coach's user profile data
    @Published private(set) var player: DBPlayer? = nil // Holds the player's profile data (if relevant)

    
    /**
     Logs out the current user.
     
     This function calls the `signOut()` method from the `AuthenticationManager` to log the coach out of the app.
     It ensures that the user’s session is ended and they are signed out of the system.
     */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    
    /**
     Resets the user's password by sending a reset email.
     
     This function retrieves the authenticated user's email and calls the `resetPassword()` method from the
     `AuthenticationManager` to send a password reset email to the user. This allows the coach to reset their password.
     */
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await AuthenticationManager.shared.resetPassword(email: authUser.email) // TO DO - NEED TO VERIFY USER GETS EMAIL
    }
    
    
    /**
     Loads the current user's profile from the database.
     
     This function retrieves the authenticated user's data using the `getAuthenticatedUser()` method from
     `AuthenticationManager`. Once the user is authenticated, their profile data is fetched using the
     `UserManager.shared.getUser()` method. The user data is stored in the `user` property.
     */
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    
    /**
     Loads both user and player data using their respective IDs.
     
     This function accepts two parameters: `userDocId` and `playerDocId`. It first fetches the user data using
     the provided `userDocId`, and then it retrieves the player's data using the provided `playerDocId`. The
     fetched data is assigned to the `user` and `player` properties, respectively.
     */
    func loadPlayer(userDocId: String, playerDocId: String) async throws {
        
        // Get the user information from the player's id
        self.user = try await UserManager.shared.findUserWithId(id: userDocId)
        
        // Get the player's information
        self.player = try await PlayerManager.shared.findPlayerWithId(id: playerDocId)
    }
    
    
    /**
     Updates the player's jersey number and nickname in the database.
     
     This function accepts two parameters: `jersey` (jersey number) and `nickname` (player's nickname).
     It checks if the `player` exists, then uses the `PlayerManager.shared.updatePlayerJerseyAndNickname()`
     method to update the player's information in the database. The updated player profile is stored in the
     `player` property.
     */
    func updatePlayerInformation(jersey: Int, nickname: String) {
        guard let player else { return }
    
        Task {
            // Updating the player information on the database
            try await PlayerManager.shared.updatePlayerJerseyAndNickname(playerDocId: player.id, jersey: jersey, nickname: nickname)
        }
    }
    
    
    /**
     Updates the coach's phone number and membership details in the database.
     
     This function accepts two parameters: `phone` (coach's phone number) and `membershipDetails`
     (coach's membership information). It updates the coach's information in the `user` object and calls
     the `UserManager.shared.updateCoachProfile()` method to save the updated information to the database.
     The `user` property is refreshed with the updated data.
     */
    func updateCoachInformation(phone: String, membershipDetails: String) {
        guard var user else { return }
        guard let userId = user.userId else { return }
        
        // Update the user's phone number and membership details
        user.phone = phone
        Task {
            // Call UserManager to update the coach's profile
            try await UserManager.shared.updateCoachProfile(user: user)
            // Refresh the user object after updating
            self.user = try await UserManager.shared.getUser(userId: userId)
        }
        
    }
}
