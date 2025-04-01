//
//  TeamModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation
import SwiftUI
 

/// **TeamModel** is responsible for handling all team-related operations.
///
/// ## Responsibilities:
/// - Managing team creation and retrieval.
/// - Handling player enrollment in teams.
/// - Validating team access codes.
/// - Loading teams based on user type (Coach or Player).
///
/// This class ensures all operations run on the main actor to prevent concurrency issues in SwiftUI.
@MainActor
final class TeamModel: ObservableObject {
    
    /// Stores the currently loaded team.
    @Published var team: DBTeam? = nil
    
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Returns: The `AuthDataResultModel` representing the authenticated user.
    /// - Throws: An error if authentication fails.
    func getAuthUser() async throws -> AuthDataResultModel {
        return try AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    
    /// Creates a new team and assigns it to the specified coach.
    ///
    /// - Parameters:
    ///   - teamDTO: The `TeamDTO` object containing the new team’s details.
    ///   - coachId: The ID of the coach who is creating the team.
    /// - Returns: `true` if the team was successfully created, `false` otherwise.
    /// - Throws: An error if the creation process fails.
    func createTeam(teamDTO: TeamDTO, coachId: String) async throws -> Bool{
        do {
            try await TeamManager.shared.createNewTeam(coachId: coachId, teamDTO: teamDTO)
            return true
            
        } catch {
            print("Failed to create team: \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// Generates a unique access code for a team.
    ///
    /// - Returns: A `String` representing the unique team access code.
    /// - Throws: An error if the access code generation fails.
    func generateAccessCode() async throws -> String {
        return try await TeamManager.shared.generateUniqueTeamAccessCode()
    }
    
    
    /// Retrieves a team by its unique team ID and updates the `team` property.
    ///
    /// - Parameter teamId: The ID of the team to retrieve.
    /// - Throws: An error if the team cannot be found.
    func getTeam(teamId: String) async throws {
        // Fetch the team from the database.
        guard let tmpTeam = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Error when loading the team. Aborting")
            return
        }
        
        self.team = tmpTeam
    }
    
    
    /// Loads all teams associated with the authenticated user.
    ///
    /// - Returns: An optional array of `DBTeam` objects representing the user's teams.
    /// - Throws: An error if the retrieval fails.
    func loadAllTeams() async throws -> [DBTeam]? {
        // Get the authenticated user's details.
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Determine the user's role (Coach or Player).
        let userType = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
                
        if (userType == "Coach") {
            // Load all teams that the coach is managing.
            let tmpTeams = try await CoachManager.shared.loadAllTeamsCoaching(coachId: authUser.uid)
            if tmpTeams != nil {
                return tmpTeams
            }
            return nil
        } else {
            // Load all teams that the player is enrolled in.
            return try await PlayerManager.shared.getAllTeamsEnrolled(playerId: authUser.uid)
        }
    }
        
    
    /// Validates a team's access code and retrieves the corresponding team.
    ///
    /// - Parameter accessCode: The unique access code for the team.
    /// - Returns: The `DBTeam` associated with the access code.
    /// - Throws: `TeamValidationError.invalidAccessCode` if the access code is invalid.
    func validateTeamAccessCode(accessCode: String) async throws -> DBTeam {
        guard let team = try await TeamManager.shared.getTeamWithAccessCode(accessCode: accessCode) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.invalidAccessCode
        }
        return team
    }
    
    
    /// Adds the authenticated player to a team using a valid access code.
    ///
    /// - Parameter team: The `DBTeam` the player is attempting to join.
    /// - Returns: The updated `DBTeam` object if successful, or `nil` if an error occurs.
    /// - Throws: `TeamValidationError.userExists` if the player is already enrolled in the team.
    func addingPlayerToTeam(team: DBTeam) async throws -> DBTeam? {
        // Get the authenticated user's details.
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Check if the player is already enrolled in the team.
        let playerEnrolledToTeam = try await PlayerManager.shared.isPlayerEnrolledToTeam(playerId: authUser.uid, teamId: team.teamId)
        if playerEnrolledToTeam {
            print("player is already enrolled to team")
            throw TeamValidationError.userExists
        }
        
        // Add the player to the team's players list in the database.
        try await TeamManager.shared.addPlayerToTeam(id: team.id, playerId: authUser.uid)
        
        // Fetch the player details.
        guard let player = try await PlayerManager.shared.getPlayer(playerId: authUser.uid) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.userExists
        }
        
        // Add the team to the player's list of enrolled teams.
        try await PlayerManager.shared.addTeamToPlayer(id: player.id, teamId: team.teamId)
        
        return team
    }
    
}
