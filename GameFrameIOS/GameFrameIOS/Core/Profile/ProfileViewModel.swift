//
//  ProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation


@MainActor
final class PlayerProfileModel: ObservableObject {
    
    @Published var user: DBUser? = nil // user information
    @Published var player: DBPlayer? = nil // player information
        
    
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
    
    func loadCurrentPlayer() async throws {
        //Task {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        
        print("This is from the loadCurrentUser function: userid = \(authDataResult.uid)")
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        self.player = try await PlayerManager.shared.getPlayer(playerId: authDataResult.uid)
        //}
    }
    
    /** Updates the player's information on the database */
    func updatePlayerInformation(jersey: Int, nickname: String, guardianName: String, guardianEmail: String, guardianPhone: String) {
        guard let player else { return }
                
        let playerInfo = DBPlayer(id: player.id, playerId: player.playerId, jerseyNum: jersey, nickName: nickname, gender: player.gender, guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone, teamsEnrolled: player.teamsEnrolled)
        
        Task {
            // Updating the player information on the database
            try await PlayerManager.shared.updatePlayerInfo(player: playerInfo)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    /** Update the guardian's name - Function is not being used anywhere! */
    func updateGuardianName(name: String) {
        guard let player else { return }
        
        Task {
            try await PlayerManager.shared.updateGuardianName(id: player.id, name: name)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    /** Removes the guardian information from the database - NOT used */
    func removeGuardianInfo() {
        guard let player else { return }
        
        Task {
            try await PlayerManager.shared.removeGuardianInfo(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    /** Removes the guardian name from the player's collection */
    func removeGuardianName() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoName(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    /** Removes the guardian email address from the player's collection */
    func removeGuardianEmail() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoEmail(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    /** Removes the guardian phone number from the player's collection */
    func removeGuardianPhone() {
        guard let player else { return }
        Task {
            try await PlayerManager.shared.removeGuardianInfoPhone(id: player.id)
            self.player = try await PlayerManager.shared.getPlayer(playerId: player.playerId!)
        }
    }
    
    
}
