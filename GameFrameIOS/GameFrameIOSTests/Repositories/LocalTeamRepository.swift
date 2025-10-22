//
//  LocalTeamRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
@testable import GameFrameIOS

final class LocalTeamRepository: TeamRepository {

    
    private var teams: [DBTeam] = []
    
    /// Retrieves a team by its team ID.
    /// - Parameter teamId: The team’s unique identifier.
    /// - Returns: A `DBTeam` object if found, otherwise `nil`.
    func getTeam(teamId: String) async throws -> DBTeam? {
        return teams.first(where: { $0.teamId == teamId })
    }
    
    
    /// Retrieves multiple teams by their IDs.
    /// - Parameter teamIds: An array of team IDs to fetch.
    /// - Returns: An array of `DBTeam` objects.
    func getAllTeams(teamIds: [String]) async throws -> [DBTeam] {
        return teams.filter { teamIds.contains($0.teamId) }
    }
    
    
    /// Retrieves a team by its Firestore document ID.
    /// - Parameter docId: The Firestore document identifier of the team.
    /// - Returns: The corresponding `DBTeam` object.
    func getTeamWithDocId(docId: String) async throws -> DBTeam {
        // Look for the team in the local teams array
        guard let team = teams.first(where: { $0.id == docId }) else {
            // Throw an error if the team is not found
            throw NSError(domain: "TeamRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Team not found with id: \(docId)"])
        }
        
        return team
    }
    
    
    /// Retrieves a team using its unique access code.
    /// - Parameter accessCode: The access code associated with the team.
    /// - Returns: A `DBTeam` if found, otherwise `nil`.
    func getTeamWithAccessCode(accessCode: String) async throws -> DBTeam? {
        return teams.first(where: { $0.accessCode == accessCode })
    }
    
    
    /// Retrieves the name of a team by its ID.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: The name of the team as a `String`.
    func getTeamName(teamId: String) async throws -> String {
        return teams.first(where: { $0.teamId == teamId })?.name ?? ""
    }
    
    
    /// Adds a player to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The ID of the player to add.
    func addPlayerToTeam(id: String, playerId: String) async throws {
        // Try to find the index of the team with the given document ID
        guard let index = teams.firstIndex(where: { $0.teamId == id }) else {
            print("Team not found with id: \(id)")
            return
        }
        
        // Retrieve the team object
        var team = teams[index]
        
        // Check if the player is already on the team to avoid duplicates
        guard !team.players!.contains(playerId) else {
            print("Player already part of the team")
            return
        }
        
        // Add the player to the team roster
        team.players?.append(playerId)
        
        // Update the team in the array
        teams[index] = team
    }
    
    
    /// Checks if a player is currently part of a given team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The player’s unique identifier.
    /// - Returns: `true` if the player belongs to the team, otherwise `false`.
    func isPlayerOnTeam(id: String, playerId: String) async throws -> Bool {
        // Find the team with the matching document ID
        guard let team = teams.first(where: { $0.teamId == id }) else {
            // If no team is found, the player cannot be part of it
            return false
        }
        
        // Check whether the playerId exists in the team’s roster
        return team.players!.contains(playerId)
    }
    
    
    /// Retrieves the number of players currently on a team’s roster.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: The number of players, or `nil` if the team was not found.
    func getTeamRosterLength(teamId: String) async throws -> Int? {
        // Try to find the team with the given ID
        guard let team = teams.first(where: { $0.teamId == teamId }) else {
            print("Team not found with id: \(teamId)")
            return nil
        }
        
        // Return the number of players on the team
        return team.players?.count
    }
    
    
    /// Removes a player from a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - playerId: The ID of the player to remove.
    func removePlayerFromTeam(id: String, playerId: String) async throws {
        // Try to find the team with the matching document ID
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }

        // Access the team object
        var team = teams[index]
        
        // Remove the player from the team's players array
        team.players?.removeAll(where: { $0 == playerId })
        
        // Update the team in the local list
        teams[index] = team
        
        print("✅ Player \(playerId) removed from team \(id)")
    }
    
    
    /// Adds a coach to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - coachId: The ID of the coach to add.
    func addCoachToTeam(id: String, coachId: String) async throws {
        // Find the team with the matching document ID
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }

        // Access the team object
        var team = teams[index]
        
        // Add the coach if not already in the list
        if !team.coaches.contains(coachId) {
            team.coaches.append(coachId)
            teams[index] = team
            print("✅ Coach \(coachId) added to team \(id)")
        } else {
            print("⚠️ Coach \(coachId) is already part of team \(id)")
        }
    }
    
    
    /// Adds an invite document to a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - inviteDocId: The ID of the invite document to add.
    func addInviteToTeam(id: String, inviteDocId: String) async throws {
        // Find the team by its document ID
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }
        
        // Access the team object
        var team = teams[index]
        
        // Add the invite if not already present
        if !team.invites!.contains(inviteDocId) {
            team.invites?.append(inviteDocId)
            teams[index] = team
            print("✅ Invite \(inviteDocId) added to team \(id)")
        } else {
            print("⚠️ Invite \(inviteDocId) already exists for team \(id)")
        }
    }
    
    
    /// Retrieves the invite document ID for a given player and team.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - playerDocId: The Firestore document ID of the player.
    /// - Returns: The invite document ID if found, otherwise `nil`.
    func getInviteDocIdOfPlayerAndTeam(teamDocId: String, playerDocId: String) async throws -> String? {
        // Find the team by its document ID
        guard let team = teams.first(where: { $0.id == teamDocId }) else {
            print("❌ Team not found with id: \(teamDocId)")
            return nil
        }
        
        // For local testing, assume each invite ID might contain the playerDocId as part of its format
        // (In Firestore, you’d normally check the actual invite document for this relationship)
        if let inviteId = team.invites!.first(where: { $0.contains(playerDocId) }) {
            print("✅ Found invite \(inviteId) for player \(playerDocId) in team \(teamDocId)")
            return inviteId
        }
        
        print("⚠️ No invite found for player \(playerDocId) in team \(teamDocId)")
        return nil
    }
    
    func getTeamsWithCoach(coachId: String) async throws -> [GameFrameIOS.DBTeam] {        
        return teams.filter { $0.coaches.contains(coachId) }
    }
    
    
    /// Removes an invite document from a team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - inviteDocId: The ID of the invite document to remove.
    func removeInviteFromTeam(id: String, inviteDocId: String) async throws {
        // Find the index of the team by its Firestore document ID
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }

        // Remove the invite ID from the team's list of invites
        teams[index].invites?.removeAll(where: { $0 == inviteDocId })
        print("✅ Removed invite \(inviteDocId) from team \(id)")
    }
    
    
    /// Removes a coach from a specific team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team.
    ///   - coachId: The ID of the coach to remove.
    func removeCoachFromTeam(id: String, coachId: String) async throws {
        // Find the index of the team with the given Firestore document ID
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }

        // Remove the coach ID from the team's list of coaches
        teams[index].coaches.removeAll(where: { $0 == coachId })
        print("✅ Removed coach \(coachId) from team \(id)")
    }
    
    
    /// Creates a new team document in the database.
    /// - Parameters:
    ///   - coachId: The ID of the coach creating the team.
    ///   - teamDTO: A data transfer object containing the new team’s details.
    func createNewTeam(coachId: String, teamDTO: TeamDTO) async throws {
        // Generate a unique team ID (simulating Firestore's automatic document ID)
        let newTeamId = UUID().uuidString
        
        // Create a new DBTeam instance using the provided DTO and coach ID
        let newTeam = DBTeam(id: newTeamId, teamDTO: teamDTO)
        // Append the new team to the local teams array
        teams.append(newTeam)
        
        print("✅ Created new team '\(teamDTO.name)' with ID: \(newTeamId)")

    }
    
    
    /// Checks if a team already exists in the database.
    /// - Parameter teamId: The unique team identifier to check.
    /// - Returns: `true` if the team exists, otherwise `false`.
    func doesTeamExist(teamId: String) async throws -> Bool {
        // Look for a team in the local teams array that matches the provided teamId
        return teams.contains { $0.id == teamId }
    }
    
    
    /// Generates a new, unique access code for team invitations.
    /// - Returns: A unique alphanumeric string for team access.
    func generateUniqueTeamAccessCode() async throws -> String {
        // Define the allowed characters for the access code (uppercase letters + digits)
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        // Generate a random 6-character code
        let code = String((0..<6).compactMap { _ in characters.randomElement() })
        
        // Check if a team already uses this access code (to ensure uniqueness)
        let isDuplicate = teams.contains { $0.accessCode == code }
        
        // If the code already exists, recursively try again
        if isDuplicate {
            return try await generateUniqueTeamAccessCode()
        }
        
        // Return the unique access code
        return code
    }
    
    
    /// Updates one or more properties of a team.
    /// - Parameters:
    ///   - id: The Firestore document ID of the team to update.
    ///   - name: Optional new team name.
    ///   - nickname: Optional new nickname.
    ///   - ageGrp: Optional new age group.
    ///   - gender: Optional new gender.
    func updateTeamSettings(id: String, name: String?, nickname: String?, ageGrp: String?, gender: String?) async throws {
        // Retrieve the team document from the database using the team ID
        guard var team = teams.first(where: { $0.id == id }) else {
            throw NSError(domain: "TeamRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Team not found"])
        }
        
        // Update only the fields that are provided (non-nil)
        if let name = name {
            team.name = name
        }
        if let nickname = nickname {
            team.teamNickname = nickname
        }
        if let ageGrp = ageGrp {
            team.ageGrp = ageGrp
        }
        if let gender = gender {
            team.gender = gender
        }
        
        // Replace the existing team in the array with the updated version
        if let index = teams.firstIndex(where: { $0.id == id }) {
            teams[index] = team
        }
    
    }
    
    
    /// Deletes a team and its related data from the database.
    /// - Parameter id: The Firestore document ID of the team to delete.
    func deleteTeam(id: String) async throws {
        // Find the index of the team in the local array
        guard let index = teams.firstIndex(where: { $0.id == id }) else {
            print("❌ Team not found with id: \(id)")
            return
        }

        // Remove the team from the local list
        teams.remove(at: index)

        // Log for debugging
        print("✅ Deleted team with id: \(id)")
    }
}
