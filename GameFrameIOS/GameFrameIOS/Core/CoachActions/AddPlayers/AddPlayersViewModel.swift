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
    // @Published var gender: String? // get the team's gender
    @Published var nickname: String = ""
    @Published var email = ""
    @Published var guardianName: String = ""
    @Published var guardianEmail: String = ""
    @Published var guardianPhone: String = ""
    @Published var teamId = "" // get the team id
    
    func addPlayerToTeam(teamId: String) async throws {
        // 1. Get the team's id
        // 2. Get the team's gender -> user will have the same
        // 3. Save the player as an invites (status = pending)
        // -- create invite doc
        // -- create player doc
        // -- create user doc
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            print("Missing information on the player. Cannot proceed")
            return
        }
        
        guard !teamId.isEmpty else {
            print("TeamId missing")
            return
        }
        
        // verify teamId
//        do {
        
        // Check that the team's id exists in one of the team's document on the database
        guard try await TeamManager.shared.doesTeamExist(teamId: teamId) else {
//        if !isValid {
            print("Team ID is invalid")
            return
        }
        
        print("test")
        // Get the team's gender
        // TO DO - Verify that the get team doesn't return nil
        let team = try await TeamManager.shared.getTeam(teamId: teamId)!
        print("comes thru here")
        // Save the new player's info
        // Create a new user
        let user = UserDTO(userId: nil, email: email, userType: "Player", firstName: firstName, lastName: lastName)
        print("and here")
        let userDocId = try await UserManager.shared.createNewUser(userDTO: user)
        print("new user: \(user)")
        print("--- new user doc id: \(userDocId)")
        
        // Create a new player
        let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
        let playerDocId = try await PlayerManager.shared.createNewPlayer(playerDTO: player)
        
        print("new player: \(player)")
        print("--- new player doc id: \(playerDocId)")
        
        // Create a new invite
        let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: teamId)
        let inviteDocId = try await InviteManager.shared.createNewInvite(inviteDTO: invite)
        print("new invite: \(invite)")
        print("--- new invite doc id: \(inviteDocId)")

        
        // Add the new invite to the team
        try await TeamManager.shared.addInviteToTeam(id: team.id, inviteDocId: inviteDocId)
    }
}
