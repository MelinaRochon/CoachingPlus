//
//  TeamModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation
import SwiftUI
 

@MainActor
final class TeamModel: ObservableObject {
    @Published var team: DBTeam? = nil
    
    func getAuthUser() async throws -> AuthDataResultModel {
        return try AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    
    func createTeam(teamDTO: TeamDTO, coachId: String) async throws -> Bool{
        do {
            try await TeamManager.shared.createNewTeam(coachId: coachId, teamDTO: teamDTO)
            return true
            
        } catch {
            print("Failed to create team: \(error.localizedDescription)")
            return false
        }
    }
    
    func generateAccessCode() async throws -> String {
        return try await TeamManager.shared.generateUniqueTeamAccessCode()
    }
    
    func getTeam(teamId: String) async throws {
        // Find the team from the teamId
        guard let tmpTeam = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Error when loading the team. Aborting")
            return
        }
        
        self.team = tmpTeam
    }
    
    func loadAllTeams() async throws -> [DBTeam]? {
        // Get the user id
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // get the user type
        let userType = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
                
        if (userType == "Coach") {
            let tmpTeams = try await CoachManager.shared.loadAllTeamsCoaching(coachId: authUser.uid)
            if tmpTeams != nil {
                return tmpTeams
            }
            return nil
        } else {
            // player
            return try await PlayerManager.shared.getAllTeamsEnrolled(playerId: authUser.uid)
        }
    }
        
    func validateTeamAccessCode(accessCode: String) async throws -> DBTeam {
        guard let team = try await TeamManager.shared.getTeamWithAccessCode(accessCode: accessCode) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.invalidAccessCode
        }
        return team
    }
    func addingPlayerToTeam(team: DBTeam) async throws -> DBTeam? {
        // Get the user id
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // If a team does have that access code, make sure the player is not enrolled to that team
        let playerEnrolledToTeam = try await PlayerManager.shared.isPlayerEnrolledToTeam(playerId: authUser.uid, teamId: team.teamId)
        if playerEnrolledToTeam {
            print("player is already enrolled to team")
            throw TeamValidationError.userExists
        }
        
        // If no problem, then add player to team
        // 1. insert player id in team players array
        try await TeamManager.shared.addPlayerToTeam(id: team.id, playerId: authUser.uid)
        
        // get the player id's
        guard let player = try await PlayerManager.shared.getPlayer(playerId: authUser.uid) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.userExists
        }
        
        // 2. insert team id in player's teamEnrolled array
        try await PlayerManager.shared.addTeamToPlayer(id: player.id, teamId: team.teamId)
        return team
    }
    
    
}
