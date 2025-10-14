//
//  TeamRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// Defines the interface for all team-related data operations.
/// Implementations can interact with Firestore, local storage, or mock data sources.
protocol TeamRepository {
    
    /// Retrieves a team by its team ID.
    /// - Parameter teamId: The team’s unique identifier.
    /// - Returns: A `DBTeam` object if found, otherwise `nil`.
    func getTeam(teamId: String) async throws -> DBTeam?
    
    
    /// Retrieves multiple teams by their IDs.
    /// - Parameter teamIds: An array of team IDs to fetch.
    /// - Returns: An array of `DBTeam` objects.
    func getAllTeams(teamIds: [String]) async throws -> [DBTeam]
    
    
    /// Retrieves a team by its Firestore document ID.
    /// - Parameter docId: The Firestore document identifier of the team.
    /// - Returns: The corresponding `DBTeam` object.
    func getTeamWithDocId(docId: String) async throws -> DBTeam
    
    
    /// Retrieves a team using its unique access code.
    /// - Parameter accessCode: The access code associated with the team.
    /// - Returns: A `DBTeam` if found, otherwise `nil`.
    func getTeamWithAccessCode(accessCode: String) async throws -> DBTeam?
    
    
    /// Retrieves the name of a team by its ID.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: The name of the team as a `String`.
    func getTeamName(teamId: String) async throws -> String
    
    
    /// Adds a player to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The ID of the player to add.
    func addPlayerToTeam(id: String, playerId: String) async throws
    
    
    /// Checks if a player is currently part of a given team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The player’s unique identifier.
    /// - Returns: `true` if the player belongs to the team, otherwise `false`.
    func isPlayerOnTeam(id: String, playerId: String) async throws -> Bool
    
    
    /// Retrieves the number of players currently on a team’s roster.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: The number of players, or `nil` if the team was not found.
    func getTeamRosterLength(teamId: String) async throws -> Int?
    
    
    /// Removes a player from a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The ID of the player to remove.
    func removePlayerFromTeam(id: String, playerId: String) async throws
    
    
    /// Adds a coach to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - coachId: The ID of the coach to add.
    func addCoachToTeam(id: String, coachId: String) async throws
    
    
    /// Adds an invite document to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - inviteDocId: The ID of the invite document to add.
    func addInviteToTeam(id: String, inviteDocId: String) async throws
    
    
    /// Retrieves the invite document ID for a given player and team.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - playerDocId: The Firestore document ID of the player.
    /// - Returns: The invite document ID if found, otherwise `nil`.
    func getInviteDocIdOfPlayerAndTeam(teamDocId: String, playerDocId: String) async throws -> String?
    
    
    /// Removes an invite document from a team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - inviteDocId: The ID of the invite document to remove.
    func removeInviteFromTeam(id: String, inviteDocId: String) async throws
    
    
    /// Removes a coach from a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - coachId: The ID of the coach to remove.
    func removeCoachFromTeam(id: String, coachId: String) async throws
    
    
    /// Creates a new team document in the database.
    /// - Parameters:
    ///   - coachId: The ID of the coach creating the team.
    ///   - teamDTO: A data transfer object containing the new team’s details.
    func createNewTeam(coachId: String, teamDTO: TeamDTO) async throws
    
    
    /// Checks if a team already exists in the database.
    /// - Parameter teamId: The unique team identifier to check.
    /// - Returns: `true` if the team exists, otherwise `false`.
    func doesTeamExist(teamId: String) async throws -> Bool
    
    
    /// Generates a new, unique access code for team invitations.
    /// - Returns: A unique alphanumeric string for team access.
    func generateUniqueTeamAccessCode() async throws -> String
    
    
    /// Updates one or more properties of a team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team to update.
    ///   - name: Optional new team name.
    ///   - nickname: Optional new nickname.
    ///   - ageGrp: Optional new age group.
    ///   - gender: Optional new gender.
    func updateTeamSettings(id: String, name: String?, nickname: String?, ageGrp: String?, gender: String?) async throws
    
    
    /// Deletes a team and its related data from the database.
    /// - Parameter id: The Firestore document ID of the team to delete.
    func deleteTeam(id: String) async throws
}

