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
    
}
