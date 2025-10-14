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
            let teamManager = TeamManager()
            try await teamManager.createNewTeam(coachId: coachId, teamDTO: teamDTO)
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
        let teamManager = TeamManager()
        return try await teamManager.generateUniqueTeamAccessCode()
    }
    
    
    /// Retrieves a team by its unique team ID and updates the `team` property.
    ///
    /// - Parameter teamId: The ID of the team to retrieve.
    /// - Throws: An error if the team cannot be found.
    func getTeam(teamId: String) async throws {
        // Fetch the team from the database.
        let teamManager = TeamManager()
        guard let tmpTeam = try await teamManager.getTeam(teamId: teamId) else {
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
        let userManager = UserManager()
        let coachManager = CoachManager()
        let playerManager = PlayerManager()
        // Get the authenticated user's details.
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Determine the user's role (Coach or Player).
        let userType = try await userManager.getUser(userId: authUser.uid)!.userType
                
        if (userType == .coach) {
            // Load all teams that the coach is managing.
            let tmpTeams = try await coachManager.loadAllTeamsCoaching(coachId: authUser.uid)
            if tmpTeams != nil {
                return tmpTeams
            }
            return nil
        } else if (userType == .player) {
            // Load all teams that the player is enrolled in.
            return try await playerManager.getAllTeamsEnrolled(playerId: authUser.uid)
        } else {
            // TODO: Unknown user in database. Return error
            return nil
        }
    }
        
    
    /// Validates a team's access code and retrieves the corresponding team.
    ///
    /// - Parameter accessCode: The unique access code for the team.
    /// - Returns: The `DBTeam` associated with the access code.
    /// - Throws: `TeamValidationError.invalidAccessCode` if the access code is invalid.
    func validateTeamAccessCode(accessCode: String) async throws -> DBTeam {
        let teamManager = TeamManager()
        guard let team = try await teamManager.getTeamWithAccessCode(accessCode: accessCode) else {
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
        let teamManager = TeamManager()
        let playerManager = PlayerManager()
        // Get the authenticated user's details.
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Check if the player is already enrolled in the team.
        let playerEnrolledToTeam = try await playerManager.isPlayerEnrolledToTeam(playerId: authUser.uid, teamId: team.teamId)
        if playerEnrolledToTeam {
            print("player is already enrolled to team")
            throw TeamValidationError.userExists
        }
        
        // Add player to all feedback that is directed to the whole squad
        let rosterCount = try await teamManager.getTeamRosterLength(teamId: team.teamId)
        
        if rosterCount == nil {
            print("invalid team id was entered.. aborting request")
            // TODO: Add an alert here
            return nil
        }
                
        try await addPlayerToAllTeamFeedback(rosterCount: rosterCount!, teamDocId: team.id, teamId: team.teamId, playerId: authUser.uid)
        
        // Fetch the player details.
        guard let player = try await playerManager.getPlayer(playerId: authUser.uid) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.userExists
        }
        
        // Add the team to the player's list of enrolled teams.
        try await playerManager.addTeamToPlayer(id: player.id, teamId: team.teamId)
        
        return team
    }
    
    
    /// Adds a player to a team and updates all team-related feedback in games.
    ///
    /// - Parameters:
    ///   - rosterCount: The expected number of players in the team (used to check if feedback is for the entire team).
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - teamId: The team’s unique identifier used to fetch its games.
    ///   - playerId: The ID of the player being added.
    ///
    /// - Throws: Rethrows any errors encountered while updating the team roster
    ///           or while fetching and updating games/key moments.
    /// - Returns: Nothing. The function is `async` and `throws` but does not return a value.
    func addPlayerToAllTeamFeedback(rosterCount: Int, teamDocId: String, teamId: String, playerId: String) async throws {
        let teamManager = TeamManager()
        let gameManager = GameManager()
        let keyMomentManager = KeyMomentManager()
        // Add the player to the team's players list in the database.
        try await teamManager.addPlayerToTeam(id: teamDocId, playerId: playerId)
                
        // Check all transcripts/key moments and add the player's user_id if the feedback is meant to be for the entire team
        guard let games = try await gameManager.getAllGames(teamId: teamId) else {
            print("No need to add the player to feedback as there are no games for this team")
            return
        }
                
        // Do all games
        for game in games {
            // Get all key moments under this game that have a feedback for all players
            try await keyMomentManager.assignPlayerToKeyMomentsForEntireTeam(teamDocId: teamDocId, gameId: game.gameId, playersCount: rosterCount, playerId: playerId)
        }
    }
    
    
    /// Updates the settings of a specific team in the data source (e.g., Firestore).
    ///
    /// - Parameters:
    ///   - id: The unique document ID of the team to update.
    ///   - name: The new team name, or `nil` if it hasn’t changed.
    ///   - nickname: The new team nickname, or `nil` if it hasn’t changed.
    ///   - ageGrp: The new age group, or `nil` if it hasn’t changed.
    ///   - gender: The new gender value, or `nil` if it hasn’t changed.
    ///
    /// - Throws: Rethrows any errors encountered during the update process.
    /// - Note: This function is asynchronous and must be called from within an `async` context.
    ///         Internally, it forwards the request to `TeamManager.shared.updateTeamSettings`.
    func updatingTeamSettings(id: String, name: String?, nickname: String?, ageGrp: String?, gender: String?) async throws {
        let teamManager = TeamManager()
        try await teamManager.updateTeamSettings(id: id, name: name, nickname: nickname, ageGrp: ageGrp, gender: gender)
    }
    
    
    /**
     Deletes a team and removes all of its associations in the database.

     This function performs a cascading deletion:
     - Fetches the team document using its document ID.
     - Removes the team's reference from all associated coaches.
     - Removes the team's reference from all associated players.
     - Deletes all invites tied to the team.
     - Finally, deletes the team document itself.

     - Parameter teamDocId: The Firestore document ID of the team to delete.
     - Throws: An error if fetching the team, updating related documents, or deleting the team fails.
     - Note: Player subcollections (created by Cate) are not yet handled — see TODO in the function.
     */
    func deleteTeam(teamDocId: String) async throws {
        let teamManager = TeamManager()
        let gameManager = GameManager()
        let playerManager = PlayerManager()
        let coachManager = CoachManager()
        let team = try await teamManager.getTeamWithDocId(docId: teamDocId)
                
        // Delete the game
        try await gameManager.deleteAllGames(teamDocId: teamDocId)

                
        // Remove the coaches affiliation to the team
        for coachId in team.coaches {
            try await coachManager.removeTeamToCoach(coachId: coachId, teamId: team.teamId)
        }
        
        
        // Remove all players affiliation to the team
        if let players = team.players {
            for playerId in players {
                let playerInfo = try await playerManager.getPlayer(playerId: playerId)
                if let player = playerInfo {
                    try await playerManager.removeTeamFromPlayer(id: player.id, teamId: team.teamId)
                }
            }
        }
        
        // Remove all invites affiliation to the team
        if let invites = team.invites {
            for inviteId in invites {
                try await InviteManager().deleteInvite(id: inviteId)
            }
        }
        
        // TODO: Get the collection under players that Cate created to delete
        
        // Remove team
        try await teamManager.deleteTeam(id: teamDocId)
        
        // Delete all audio files in the storage under the team id
        let folderPath = "audio/\(team.teamId)"
        StorageManager.shared.deleteAllAudioUnderPath(in: folderPath) { error in
            if let error = error {
                print("Failed to delete all audio files under this path: \(folderPath). Error: \(error.localizedDescription)")
            } else {
                print("Successfully deleted all audio files under this path: \(folderPath)")
            }
        }

    }
    
}
