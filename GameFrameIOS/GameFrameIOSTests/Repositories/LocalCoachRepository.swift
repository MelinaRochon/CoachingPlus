//
//  LocalCoachRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
@testable import GameFrameIOS

final class LocalCoachRepository: CoachRepository {
    private var coaches: [DBCoach] = []
    
    /// Adds a new coach to the database.
    /// - Parameter coachId: The unique identifier of the coach to add.
    /// - Throws: An error if the operation fails.
    func addCoach(coachId: String) async throws {
        let id = UUID().uuidString
        let coach = DBCoach(id: id, coachId: coachId)
        coaches.append(coach)
    }

    /// Fetches the detailed information of a specific coach.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: A `DBCoach` object if the coach exists, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getCoach(coachId: String) async throws -> DBCoach? {
        // Search the local array for a coach with the matching ID
        return coaches.first(where: { $0.id == coachId })
    }

    /// Associates a team with a specific coach.
    /// - Parameters:
    ///   - coachId: The unique identifier of the coach.
    ///   - teamId: The unique identifier of the team to add.
    /// - Throws: An error if the operation fails.
    func addTeamToCoach(coachId: String, teamId: String) async throws {
        // Find the index of the coach in the local array
        guard let index = coaches.firstIndex(where: { $0.id == coachId }) else {
            throw NSError(domain: "LocalCoachRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Coach not found"])
        }
        
        // Initialize the teams array if nil
        if coaches[index].teamsCoaching == nil {
            coaches[index].teamsCoaching = []
        }
        
        // Add the teamId if it is not already in the coach's teams
        if !coaches[index].teamsCoaching!.contains(teamId) {
            coaches[index].teamsCoaching!.append(teamId)
        }
    }

    /// Removes a team from a specific coach’s list of teams.
    /// - Parameters:
    ///   - coachId: The unique identifier of the coach.
    ///   - teamId: The unique identifier of the team to remove.
    /// - Throws: An error if the operation fails.
    func removeTeamToCoach(coachId: String, teamId: String) async throws {
        // Find the index of the coach in the local array
        guard let index = coaches.firstIndex(where: { $0.id == coachId }) else {
            throw NSError(domain: "LocalCoachRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Coach not found"])
        }
        
        // Safely remove the teamId if the teams array exists
        if let teamIndex = coaches[index].teamsCoaching?.firstIndex(of: teamId) {
            coaches[index].teamsCoaching?.remove(at: teamIndex)
        }
    }

    /// Loads a simplified list of teams that a coach is currently coaching.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: An optional array of `GetTeam` objects representing teams the coach manages, or `nil` if none.
    /// - Throws: An error if the retrieval fails.
    func loadTeamsCoaching(coachId: String) async throws -> [GetTeam]? {
        // 1. Find the coach in your local array (or fetch from Firestore)
        guard let coach = coaches.first(where: { $0.coachId == coachId }) else {
            return nil // Coach not found
        }

        // 2. Make sure the coach has teams
        guard let teamIds = coach.teamsCoaching, !teamIds.isEmpty else {
            return nil // No teams for this coach
        }

        // 3. Fetch each team asynchronously
        var getTeams: [GetTeam] = []
        for teamId in teamIds {
            if let team = try await TeamManager().getTeam(teamId: teamId) {
                getTeams.append(GetTeam(teamId: teamId, name: team.name, nickname: team.teamNickname))
            }
        }
        return getTeams
    }

    /// Loads the full details of all teams a coach is currently coaching.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: An optional array of `DBTeam` objects representing teams the coach manages, or `nil` if none.
    /// - Throws: An error if the retrieval fails.
    func loadAllTeamsCoaching(coachId: String) async throws -> [DBTeam]? {
        // 1. Find the coach
        guard let coach = coaches.first(where: { $0.coachId == coachId }) else {
            return nil
        }

        // 2. Make sure the coach has teams
        guard let teamIds = coach.teamsCoaching, !teamIds.isEmpty else {
            return nil
        }

        // 3. Fetch all teams asynchronously
        var teamsList: [DBTeam] = []
        for teamId in teamIds {
            if let team = try await TeamManager().getTeam(teamId: teamId) {
                teamsList.append(team)
            }
        }

        return teamsList
    }

}
