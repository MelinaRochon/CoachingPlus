//
//  AllTeamsViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-13.
//

import Foundation

struct teamIdName {
    let id: String
    let teamId: String
    let name: String
}


@MainActor
final class AllTeamsViewModel: ObservableObject {
    @Published var teams: [GetTeam] = []
    
    func loadAllTeams() async throws {
        
        // Get the user id
        let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
        
        // get the user type
        let userType = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
                
        if (userType == "Coach") {
            let tmpTeams = try await CoachManager.shared.loadTeamsCoaching(coachId: authUser.uid)
            if tmpTeams != nil {
                self.teams = tmpTeams!
            }
        } else {
            // player
            teams = try await PlayerManager.shared.getTeamsEnrolled(playerId: authUser.uid)
        }
    }
    
    func validateAccessCode(accessCode: String) async throws {
        // Get the user id
        let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
        
        // Verify that it is a valid access code
        // 1. Check that a team has that access code!
        guard let team = try await TeamManager.shared.getTeamWithAccessCode(accessCode: accessCode) else {
            print("Error. Access code is invalid")
            return
        }
        print("TEAM:::: \(team)")
        
        // If a team does have that access code, make sure the player is not enrolled to that team
        let playerEnrolledToTeam = try await PlayerManager.shared.isPlayerEnrolledToTeam(playerId: authUser.uid, teamId: team.teamId)
        if playerEnrolledToTeam {
            print("player is already enrolled to team")
            return
        }
        
        // If no problem, then add player to team
        // 1. insert player id in team players array
        try await TeamManager.shared.addPlayerToTeam(id: team.id, playerId: authUser.uid)
        
        // get the player id's 
        guard let player = try await PlayerManager.shared.getPlayer(playerId: authUser.uid) else {
            print("Error. Access code is invalid")
            return
        }

        // 2. insert team id in player's teamEnrolled array
        try await PlayerManager.shared.addTeamToPlayer(id: player.id, teamId: team.teamId)
        
        // show this new team by adding it to the teams array
        let newTeam = GetTeam(teamId: team.teamId, name: team.name, nickname: team.teamNickname)
        self.teams.append(newTeam) // adding new team to the page
    }
}
