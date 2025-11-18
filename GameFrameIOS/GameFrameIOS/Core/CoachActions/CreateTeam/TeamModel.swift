//
//  TeamModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation
import SwiftUI
import GameFrameIOSShared
 

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
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    /// Stores the currently loaded team.
    @Published var team: DBTeam? = nil
    
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
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Returns: The `AuthDataResultModel` representing the authenticated user.
    /// - Throws: An error if authentication fails.
    func getAuthUser() async throws -> AuthDataResultModel {
        return try dependencies!.authenticationManager.getAuthenticatedUser()
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
            try await dependencies?.teamManager.createNewTeam(coachId: coachId, teamDTO: teamDTO)
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
        guard let repo = dependencies?.teamManager else {
            throw NSError(domain: "TeamModel", code: 1001, userInfo: [NSLocalizedDescriptionKey : "Dependencies not set"])
        }
        return try await repo.generateUniqueTeamAccessCode()
    }
    
    
    /// Retrieves a team by its unique team ID and updates the `team` property.
    ///
    /// - Parameter teamId: The ID of the team to retrieve.
    /// - Throws: An error if the team cannot be found.
    func getTeam(teamId: String) async throws {
        // Fetch the team from the database.
        guard let tmpTeam = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
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
        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return nil
        }
        let authUser = try repo.authenticationManager.getAuthenticatedUser()
        
        // Determine the user's role (Coach or Player).
        let userType = try await repo.userManager.getUser(userId: authUser.uid)!.userType
                
        if (userType == .coach) {
            // Load all teams that the coach is managing.
            let tmpTeams = try await repo.coachManager.loadAllTeamsCoaching(coachId: authUser.uid)
                return tmpTeams
        } else if (userType == .player) {
            // Load all teams that the player is enrolled in.
            return try await repo.playerManager.getAllTeamsEnrolled(playerId: authUser.uid)
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
        guard let team = try await dependencies?.teamManager.getTeamWithAccessCode(accessCode: accessCode) else {
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
        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return nil
        }
        let authUser = try repo.authenticationManager.getAuthenticatedUser()
        
        // Check if the player is already enrolled in the team.
        let playerEnrolledToTeam = try await repo.playerManager.isPlayerEnrolledToTeam(playerId: authUser.uid, teamId: team.teamId)
        if playerEnrolledToTeam {
            print("player is already enrolled to team")
            throw TeamValidationError.userExists
        }
        
        // Add player to all feedback that is directed to the whole squad
        let rosterCount = try await repo.teamManager.getTeamRosterLength(teamId: team.teamId)
        
        if rosterCount == nil {
            print("invalid team id was entered.. aborting request")
            // TODO: Add an alert here
            return nil
        }
                
        try await addPlayerToAllTeamFeedback(rosterCount: rosterCount!, teamDocId: team.id, teamId: team.teamId, playerId: authUser.uid)
        
        // Fetch the player details.
        guard let player = try await repo.playerManager.getPlayer(playerId: authUser.uid) else {
            print("Error. Access code is invalid")
            throw TeamValidationError.userExists
        }
        
        // Add the team to the player's list of enrolled teams.
        try await repo.playerManager.addTeamToPlayer(id: player.id, teamId: team.teamId)
        
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
        guard let repo = dependencies else {
            throw NSError(domain: "GameModel", code: 1, userInfo: nil)
        }

        // Add the player to the team's players list in the database.
        try await repo.teamManager.addPlayerToTeam(id: teamDocId, playerId: playerId)
                
        // Check all transcripts/key moments and add the player's user_id if the feedback is meant to be for the entire team
        guard let games = try await repo.gameManager.getAllGames(teamId: teamId) else {
            print("No need to add the player to feedback as there are no games for this team")
            return
        }
                
        // Do all games
        for game in games {
            // Get all key moments under this game that have a feedback for all players
            try await repo.keyMomentManager.assignPlayerToKeyMomentsForEntireTeam(teamDocId: teamDocId, gameId: game.gameId, playersCount: rosterCount, playerId: playerId)
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
        try await dependencies?.teamManager.updateTeamSettings(id: id, name: name, nickname: nickname, ageGrp: ageGrp, gender: gender)
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
        guard let repo = dependencies else {
            print("Error")
            throw NSError(domain: "deleteTeam", code: 0, userInfo: nil)
        }
        let team = try await repo.teamManager.getTeamWithDocId(docId: teamDocId)
                
        // Delete the game
        try await repo.gameManager.deleteAllGames(teamDocId: teamDocId)

                
        // Remove the coaches affiliation to the team
        for coachId in team.coaches {
            try await repo.coachManager.removeTeamToCoach(coachId: coachId, teamId: team.teamId)
        }
        
        
        // Remove all players affiliation to the team
        if let players = team.players {
            for playerId in players {
                let playerInfo = try await repo.playerManager.getPlayer(playerId: playerId)
                if let player = playerInfo {
                    try await repo.playerManager.removeTeamFromPlayer(id: player.id, teamId: team.teamId)
                }
            }
        }
        
        // Remove all invites affiliation to the team
        if let invites = team.invites {
            for inviteId in invites {
                try await repo.inviteManager.deleteInvite(id: inviteId)
            }
        }
        
        // TODO: Get the collection under players that Cate created to delete
        
        // Remove team
        try await repo.teamManager.deleteTeam(id: teamDocId)
        
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
// MARK: - Find team by game id

extension TeamModel {
    /// Returns the team that owns the given game id (if any).
    func getTeamForGameId(_ gameId: String) async throws -> DBTeam? {
        guard let deps = dependencies else {
            print("⚠️ Dependencies not set")
            return nil
        }

        // Reuse your existing logic to load all teams for this user
        guard let teams = try await loadAllTeams() else {
            return nil
        }

        for team in teams {
            // Get all games for this team
            guard let games = try await deps.gameManager.getAllGames(teamId: team.teamId) else {
                continue
            }

            // Does this team have a game with that id?
            if games.contains(where: { $0.gameId == gameId }) {
                return team
            }
        }

        return nil
    }

    /// Convenience: return the teamId for a given game id.
    func getTeamIdForGameId(_ gameId: String) async throws -> String? {
        guard let team = try await getTeamForGameId(gameId) else {
            return nil
        }
        return team.teamId    // or `team.id` if you prefer the doc id
    }
}
