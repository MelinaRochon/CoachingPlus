//
//  CoachProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
import GameFrameIOSShared

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
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    /// Published state variables to store user and player information
    @Published private(set) var user: DBUser? = nil // Holds the authenticated coach's user profile data
    @Published private(set) var player: DBPlayer? = nil // Holds the player's profile data (if relevant)

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    /**
     Logs out the current user.
     
     This function calls the `signOut()` method from the `AuthenticationManager` to log the coach out of the app.
     It ensures that the user’s session is ended and they are signed out of the system.
     */
    func logOut() throws {
        guard let repo = dependencies?.authenticationManager else {
            print("⚠️ Dependencies not set")
            return
        }

        try repo.signOut()
    }
    
    
    /**
     Resets the user's password by sending a reset email.
     
     This function retrieves the authenticated user's email and calls the `resetPassword()` method from the
     `AuthenticationManager` to send a password reset email to the user. This allows the coach to reset their password.
     */
    func resetPassword() async throws {
        guard let repo = dependencies?.authenticationManager else {
            print("⚠️ Dependencies not set")
            return
        }

        let authUser = try repo.getAuthenticatedUser()
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await repo.resetPassword(email: authUser.email) // TO DO - NEED TO VERIFY USER GETS EMAIL
    }
    
    
    /**
     Loads the current user's profile from the database.
     
     This function retrieves the authenticated user's data using the `getAuthenticatedUser()` method from
     `AuthenticationManager`. Once the user is authenticated, their profile data is fetched using the
     `UserManager.shared.getUser()` method. The user data is stored in the `user` property.
     */
    func loadCurrentUser() async throws {
        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return
        }

        let authDataResult = try repo.authenticationManager.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        self.user = try await repo.userManager.getUser(userId: authDataResult.uid)
    }
    
    
    /**
     Loads both user and player data using their respective IDs.
     
     This function accepts two parameters: `userDocId` and `playerDocId`. It first fetches the user data using
     the provided `userDocId`, and then it retrieves the player's data using the provided `playerDocId`. The
     fetched data is assigned to the `user` and `player` properties, respectively.
     */
    func loadPlayer(userDocId: String, playerDocId: String) async throws {
        // Get the user information from the player's id
        self.user = try await dependencies?.userManager.findUserWithId(id: userDocId)
        
        // Get the player's information
        self.player = try await dependencies?.playerManager.findPlayerWithId(id: playerDocId)
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
            try await dependencies?.playerManager.updatePlayerJerseyAndNickname(playerDocId: player.id, jersey: jersey, nickname: nickname)
        }
    }
    
    
    /**
     Updates the coach's phone number and membership details in the database.
     
     This function accepts two parameters: `phone` (coach's phone number) and `membershipDetails`
     (coach's membership information). It updates the coach's information in the `user` object and calls
     the `UserManager.shared.updateCoachProfile()` method to save the updated information to the database.
     The `user` property is refreshed with the updated data.
     */
    func updateCoachInformation(phone: String, dateOfBirth: Date, membershipDetails: String) {
        guard var user else { return }
        guard let userId = user.userId else { return }
        
        // Update the user's phone number and membership details
        user.phone = phone
        user.dateOfBirth = dateOfBirth
        
        Task {
            // Call UserManager to update the coach's profile
            try await dependencies?.userManager.updateCoachProfile(user: user)
            // Refresh the user object after updating
            self.user = try await dependencies?.userManager.getUser(userId: userId)
        }
    }
    
    
    /// Updates the settings for the currently loaded coach user.
    /// - Parameters:
    ///   - phone: Optional updated phone number for the coach.
    ///   - dateOfBirth: Optional updated date of birth for the coach.
    ///   - firstName: Optional updated first name for the coach.
    ///   - lastName: Optional updated last name for the coach.
    ///   - membershipDetails: Optional updated membership information for the coach.
    func updateCoachSettings(phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) {
        guard var user else { return }
        guard let userId = user.userId else { return }
        
        // Update the user's phone number and membership details
        user.phone = phone
        user.dateOfBirth = dateOfBirth
        if firstName != nil {
            user.firstName = firstName ?? ""
        }
        
        if lastName != nil {
            user.lastName = lastName ?? ""

        }

        Task {
            // Call UserManager to update the coach's profile
            try await dependencies?.userManager.updateCoachSettings(id: user.id, phone: phone, dateOfBirth: dateOfBirth, firstName: firstName, lastName: lastName, membershipDetails: membershipDetails)
            // Refresh the user object after updating
            self.user = try await dependencies?.userManager.getUser(userId: userId)
        }
    }

    
    /// Remove a player from the database
    func removePlayer(teamDocId: String) async throws {
        // TODO: Remove a player from db cannot be done.
        guard let player else { return }
        
        guard let repo = dependencies else {
            throw NSError(domain: "CoachProfileViewModel", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Dependencies not set"])
        }
        
        // Remove the player from the team
        
        // Remove from invites, if player id is found in array
        let inviteDocId = try await repo.teamManager.getInviteDocIdOfPlayerAndTeam(teamDocId: teamDocId, playerDocId: player.id)
        print("the invite doc id is \(inviteDocId ?? "DOES NOT exexist. player was not added by the coach")")
        if inviteDocId != nil {
            // Remove the invite id from the invites array
            print("removing player's invite from the teamP: \(teamDocId)")
            try await repo.teamManager.removeInviteFromTeam(id: teamDocId, inviteDocId: inviteDocId!)
        } else {
            print("player not in invite array... no need to remove")
        }
        
        // Remove from accepted, if player is found in array
        if let playerId = player.playerId {
            print("player id exists. chek if player is assigned to a team ({playersz})")
            let playerIsOnTeam = try await repo.teamManager.isPlayerOnTeam(id: teamDocId, playerId: playerId)
            print("is player set on a team: (\(playerIsOnTeam))")
            if playerIsOnTeam {
                print("removing p0layer from the team")
                try await repo.teamManager.removePlayerFromTeam(id: teamDocId, playerId: playerId)
            } else {
                print("player nhot on the team/. . . no need to remove from the player array (in teams)")
            }
        }
        
        // Remove team id player was enrolled in players team_enrolled array
        try await repo.playerManager.removeTeamFromPlayerWithTeamDocId(id: player.id, teamDocId: teamDocId)
    }
    
    
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        try await dependencies?.userManager.updateUserSettings(
            id: id,
            dateOfBirth: dateOfBirth,
            firstName: firstName,
            lastName: lastName,
            phone: phone
        )
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
            try await dependencies?.playerManager.updatePlayerSettings(
                id: id,
                jersey: jersey,
                nickname: nickname,
                guardianName: guardianName,
                guardianEmail: guardianEmail,
                guardianPhone: guardianPhone,
                gender: gender
            )
            
            self.player = try await dependencies?.playerManager.getPlayer(playerId: player.playerId!)
        }
    }
}
