//
//  AddPlayersViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//

import Foundation

@MainActor
final class AddPlayersViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var jersey: Int = 0
    @Published var nickname: String = ""
    @Published var email = ""
    @Published var guardianName: String = ""
    @Published var guardianEmail: String = ""
    @Published var guardianPhone: String = ""
    @Published var teamId = "" // get the team id
    
    func addPlayerToTeam(teamId: String) async throws -> Bool {

        do {
            guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
                print("Missing information on the player. Cannot proceed")
                return false
            }
            
            guard !teamId.isEmpty else {
                print("TeamId missing")
                return false
            }
            
            // Check that the team's id exists in one of the team's document on the database
            guard try await TeamManager.shared.doesTeamExist(teamId: teamId) else {
                //        if !isValid {
                print("Team ID is invalid")
                return false
            }
            
            // TO DO - Verify that the get team doesn't return nil
            let team = try await TeamManager.shared.getTeam(teamId: teamId)!
            // Save the new player's info
            // Create a new user
            let user = UserDTO(userId: nil, email: email, userType: "Player", firstName: firstName, lastName: lastName)
            let userDocId = try await UserManager.shared.createNewUser(userDTO: user)
            
            // Create a new player
            let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
            let playerDocId = try await PlayerManager.shared.createNewPlayer(playerDTO: player)
                        
            // Create a new invite
            let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: teamId)
            let inviteDocId = try await InviteManager.shared.createNewInvite(inviteDTO: invite)
            
            // Add the new invite to the team
            try await TeamManager.shared.addInviteToTeam(id: team.id, inviteDocId: inviteDocId)
            return true
        } catch {
            print("Failed to add player to the team.. \(error.localizedDescription)")
            return false
        }
    }
}
