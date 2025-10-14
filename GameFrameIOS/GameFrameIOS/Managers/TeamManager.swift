//
//  TeamManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-04.
//

import Foundation


/// Manages operations related to teams, such as fetching, updating, and creating teams in Firestore.
/// This class follows a singleton pattern to ensure a single instance is used throughout the app.
final class TeamManager {
    
    private let repo: TeamRepository
    
    init(repo: TeamRepository = FirestoreTeamRepository()) {
        self.repo = repo
    }

    
    /// Retrieves a team by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getTeam(teamId: String) async throws -> DBTeam? {
        return try await repo.getTeam(teamId: teamId)
    }
    
    /// Retrieves all teams by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getAllTeams(teamIds: [String]) async throws -> [DBTeam] {
        return try await repo.getAllTeams(teamIds: teamIds)
    }
    
    
    /// Retrieves a team by its Firestore document ID.
    /// - Parameter docId: Firestore document ID of the team.
    /// - Returns: A `DBTeam` instance.
    func getTeamWithDocId(docId: String) async throws -> DBTeam {
        return try await repo.getTeamWithDocId(docId: docId)
    }
    
    
    /// Retrieves a team using the access code.
    /// - Parameters:
    ///   - accessCpde: Team access code.
    ///   - Returns: A `DBTeam` instance, if found, otherwise `nil`
    func getTeamWithAccessCode(accessCode: String) async throws -> DBTeam? {
        return try await repo.getTeamWithAccessCode(accessCode: accessCode)
    }
    
    
    /// Retrieves a team name by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `String` with the team name,.
    func getTeamName(teamId: String) async throws -> String {
       return try await repo.getTeamName(teamId: teamId)
    }
        
    /// Adds a player to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - playerId: ID of the player to be added.
    func addPlayerToTeam(id: String, playerId: String) async throws {
        try await repo.addPlayerToTeam(id: id, playerId: playerId)
    }
    
    
    /// Checks whether a player belongs to a specific team.
    ///
    /// - Parameters:
    ///   - id: The document ID of the team in the database.
    ///   - playerId: The unique identifier of the player to check.
    /// - Returns: `true` if the player is on the team, otherwise `false`.
    /// - Throws: An error if the team could not be fetched from the database.
    func isPlayerOnTeam(id: String, playerId: String) async throws -> Bool {
        return try await repo.isPlayerOnTeam(id: id, playerId: playerId)
    }
    
    
    /// Retrieves the roster size (number of players) for a given team.
    ///
    /// - Parameter teamId: The unique identifier of the team to fetch.
    ///
    /// - Throws: An error if the Firestore request or data decoding fails.
    ///
    /// - Returns: The number of players in the team's roster, or:
    ///   - `nil` if no team with the given ID exists,
    ///   - `0` if the team exists but has no roster.
    func getTeamRosterLength(teamId: String) async throws -> Int? {
        return try await repo.getTeamRosterLength(teamId: teamId)
    }
 
    
    /// Removes a player from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - playerId: ID of the player to be removed.
    func removePlayerFromTeam(id: String, playerId: String) async throws {
        try await repo.removePlayerFromTeam(id: id, playerId: playerId)
    }
    
    /// Adds a coach to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - coachId: ID of the coach to be added.
    func addCoachToTeam(id: String, coachId: String) async throws {
        try await repo.addCoachToTeam(id: id, coachId: coachId)
    }
    
    
    /// Adds an invite to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - inviteDocId: Firestore document ID of the invite.
    func addInviteToTeam(id: String, inviteDocId: String) async throws {
        try await repo.addInviteToTeam(id: id, inviteDocId: inviteDocId)
    }
    
    func getInviteDocIdOfPlayerAndTeam(teamDocId: String, playerDocId: String) async throws -> String? {
        return try await repo.getInviteDocIdOfPlayerAndTeam(teamDocId: teamDocId, playerDocId: playerDocId)
    }
    
    
    /// Removes an invite from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - inviteDocId: Firestore document ID of the invite.
    func removeInviteFromTeam(id: String, inviteDocId: String) async throws {
        try await repo.removeInviteFromTeam(id: id, inviteDocId: inviteDocId)
    }
    
    
    /// Removes a coach from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - coachId: ID of the coach to be removed.
    func removeCoachFromTeam(id: String, coachId: String) async throws {
        try await repo.removeCoachFromTeam(id: id, coachId: coachId)
    }
    

    /// Creates a new team in Firestore and associates it with a coach.
    /// - Parameters:
    ///   - coachId: The ID of the coach creating the team.
    ///   - teamDTO: The data transfer object containing team details.
    func createNewTeam(coachId: String, teamDTO: TeamDTO) async throws {
        try await repo.createNewTeam(coachId: coachId, teamDTO: teamDTO)
    }
    
    
    /// Checks whether a team exists in the database.
    /// - Parameter teamId: The team ID to check.
    /// - Returns: `true` if the team exists, otherwise `false`.
    func doesTeamExist(teamId: String) async throws -> Bool {
        return try await repo.doesTeamExist(teamId: teamId)
    }
    
    /// Generates a unique 8-character access code for a team.
    /// - Returns: A unique alphanumeric access code.
    func generateUniqueTeamAccessCode() async throws -> String {
        return try await repo.generateUniqueTeamAccessCode()
    }
    
    
    /// Updates the fields of a team document in Firestore (or another data source).
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the team document to update.
    ///   - name: Optional new name for the team. If `nil`, the name field will not be updated.
    ///   - nickname: Optional new nickname for the team. If `nil`, the nickname field will not be updated.
    ///   - ageGrp: Optional new age group for the team. If `nil`, the age group field will not be updated.
    ///   - gender: Optional new gender value for the team. If `nil`, the gender field will not be updated.
    ///
    /// - Throws: Rethrows any errors from Firestore’s `updateData` call.
    func updateTeamSettings(id: String, name: String?, nickname: String?, ageGrp: String?, gender: String?) async throws {
        try await repo.updateTeamSettings(id: id, name: name, nickname: nickname, ageGrp: ageGrp, gender: gender)
    }
    
    
    /// Deletes a team in Firestore
    ///
    /// - Parameters:
    ///    - id: The ID of the team to delete
    ///  - Throws: An error if the delete process fails
    func deleteTeam(id: String) async throws {
        try await repo.deleteTeam(id: id)
    }
}
