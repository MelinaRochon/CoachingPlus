//
//  ProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation

/**
  `PlayerProfileModel` is an `ObservableObject` class responsible for managing and updating the player's profile data.
  It contains the logic for logging out, resetting the password, loading user and player data, and updating player or guardian information.
  This view model interacts with the `AuthenticationManager`, `UserManager`, and `PlayerManager` to handle user authentication and profile data management.
*/
@MainActor
final class PlayerProfileModel: ObservableObject {
    
    /**
     A `@Published` property that holds the user’s profile information.
     This state is used to store the user's profile data retrieved from the database and is updated whenever the user data is modified.
     */
    @Published var user: DBUser? = nil // user information
    
    /**
     A `@Published` property that holds the player's profile information.
     This state is used to store the player's data, including the jersey number, nickname, and guardian's information. It will be updated when changes are made to the player's profile.
     */
    @Published var player: DBPlayer? = nil // player information
        
    
    /**
     Logs out the current authenticated user.
     - This function calls `signOut()` from the `AuthenticationManager` to log the user out of the system. After the logout, the user's session is terminated.
     - Throws: It can throw an error if there’s an issue during the sign-out process.
     */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    
    /**
     Resets the current user's password by sending a reset email.
     - This function retrieves the authenticated user's email and calls `resetPassword()` from the `AuthenticationManager` to send a password reset email to the user.
     - Throws: It can throw an error if the user cannot be retrieved or if the password reset fails.
     */
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Send password reset email to the user
        try await AuthenticationManager.shared.resetPassword(email: authUser.email) // TODO: - NEED TO VERIFY USER GETS EMAIL
    }
    
    
    /**
     Loads the authenticated user's and player's data.
     
     - This function fetches the authenticated user's data using `getAuthenticatedUser()`. It then loads the user's and player's profiles using the user ID and stores the results in the `user` and `player` properties.
     
     - Throws: It can throw an error if there is an issue with user authentication or data fetching.
     */
    func loadCurrentPlayer() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        
        let userManager = UserManager()
        // Fetch user and player data from the database
        self.user = try await userManager.getUser(userId: authDataResult.uid)
        self.player = try await PlayerManager.shared.getPlayer(playerId: authDataResult.uid)
    }
    
    
    /**
     Updates the player's information in the database.
     
     - Parameters:
        - jersey: The new jersey number for the player.
        - nickname: The new nickname for the player.
        - guardianName: The new guardian's name.
        - guardianEmail: The new guardian's email.
        - guardianPhone: The new guardian's phone number.
     
     - This function creates a new `DBPlayer` object with the updated information and then calls `updatePlayerInfo()` from `PlayerManager` to update the player's information in the database. The `player` property is then refreshed with the updated data.
     
     - Throws: It can throw an error if there’s an issue updating the player’s information in the database.
     */
    func updatePlayerInformation(jersey: Int, nickname: String, guardianName: String, guardianEmail: String, guardianPhone: String) {
        guard let player else { return }
        
        
        // Create a new DBPlayer object with updated information
        let playerInfo = DBPlayer(id: player.id, playerId: player.playerId, jerseyNum: jersey, nickName: nickname, gender: player.gender, guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone, teamsEnrolled: player.teamsEnrolled)
        
        Task {
            // Update the player's information in the database
            try await PlayerManager.shared.updatePlayerInfo(player: playerInfo)
            // Refresh player data after the update
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /// Updates the settings for the currently loaded player.
    /// - Parameters:
    ///   - id: The unique identifier of the player to update.
    ///   - jersey: Optional updated jersey number.
    ///   - nickname: Optional updated nickname.
    ///   - guardianName: Optional updated guardian's name.
    ///   - guardianEmail: Optional updated guardian's email address.
    ///   - guardianPhone: Optional updated guardian's phone number.
    ///   - gender: Optional updated gender of the player.
    func updatePlayerSettings(id: String, jersey: Int?, nickname: String?, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) {
        guard var player else { return }
        
        player.jerseyNum = jersey ?? player.jerseyNum
        player.nickName = nickname ?? player.nickName
        player.guardianName = guardianName ?? player.guardianName
        player.guardianEmail = guardianEmail ?? player.guardianEmail
        player.guardianPhone = guardianPhone ?? player.guardianPhone
        player.gender = gender ?? player.gender
        
        Task {
            // Update the player's information in the database
            try await PlayerManager.shared.updatePlayerSettings(id: id, jersey: jersey, nickname: nickname, guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone, gender: gender)
            
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /**
     Updates the player's guardian name in the database.
     - Parameters:
        - name: The new guardian's name to update.
     - This function updates the guardian's name in the database for the given player and refreshes the player’s data.
     - This function is not being used anywhere currently.
     - Throws: It can throw an error if there’s an issue updating the guardian's name in the database.
     */
    func updateGuardianName(name: String) {
        guard let player else { return }
        
        Task {
            try await PlayerManager.shared.updateGuardianName(id: player.id, name: name)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /**
     Removes the player's guardian information from the database.
     - This function removes the guardian's information entirely from the player's profile.
     - This function is not being used anywhere currently.
     - Throws: It can throw an error if there’s an issue removing the guardian's information from the database.
     */
    func removeGuardianInfo() {
        guard let player else { return }
        
        Task {
            try await PlayerManager.shared.removeGuardianInfo(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /**
     Removes the guardian's name from the player's profile.
     - This function removes the guardian's name from the player's collection in the database.
     - Throws: It can throw an error if there’s an issue removing the guardian's name from the database.
     */
    func removeGuardianName() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoName(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /**
     Removes the guardian's email from the player's profile.
     - This function removes the guardian's email from the player's collection in the database.
     - Throws: It can throw an error if there’s an issue removing the guardian's email from the database.
     */
    func removeGuardianEmail() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoEmail(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /**
     Removes the guardian's phone number from the player's profile.
     - This function removes the guardian's phone number from the player's collection in the database.
     - Throws: It can throw an error if there’s an issue removing the guardian's phone number from the database.
     */
    func removeGuardianPhone() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoPhone(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
    /// Updates the settings of a specific user by delegating the task to the `UserManager`.
    /// - Parameters:
    ///   - id: The unique identifier of the user whose settings need to be updated.
    ///   - dateOfBirth: Optional updated date of birth for the user.
    ///   - firstName: Optional updated first name for the user.
    ///   - lastName: Optional updated last name for the user.
    ///   - phone: Optional updated phone number for the user.
    /// - Throws: An error if the update operation fails.
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        
        let userManager = UserManager()
        try await userManager.updateUserSettings(id: id, dateOfBirth: dateOfBirth, firstName: firstName, lastName: lastName, phone: phone)
    }
    
}
