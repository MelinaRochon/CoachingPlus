//
//  CoachManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation

/// `CoachManager` class is responsible for managing coach-related operations in the Firestore database.
/// It includes methods to add, update, retrieve, and delete coach data, as well as manage the teams a coach is associated with.
public final class CoachManager {
    private let repo: CoachRepository
        
    public init(repo: CoachRepository) {
        self.repo = repo
    }
    
    // MARK: - CRUD Operations
        
    /// POST - Add a new coach to the Firestore database
    /// This function creates a new coach document in the "coaches" collection.
    /// - Parameter coachId: The unique coach ID to associate with the new coach.
    public func addCoach(coachId: String) async throws {
        try await repo.addCoach(coachId: coachId)
    }
    
    
    /// GET - Retrieve the coach's information from Firestore
    /// This function fetches a coach's data from the Firestore database and returns it as a `DBCoach` object.
    /// - Parameter coachId: The unique coach ID to fetch the associated coach data.
    /// - Returns: An optional `DBCoach` object containing the coach's data.
    public func getCoach(coachId: String) async throws -> DBCoach? {
        return try await repo.getCoach(coachId: coachId)
    }
    
    
    /// PUT - Add a new team ID to the coach's `teamsCoaching` array
    /// This function updates the coach's `teamsCoaching` field to include a new team ID.
    /// - Parameter coachId: The unique coach ID to update.
    /// - Parameter teamId: The team ID to add to the `teamsCoaching` array.
    public func addTeamToCoach(coachId: String, teamId: String) async throws {
        try await repo.addTeamToCoach(coachId: coachId, teamId: teamId)
    }
    
    
    /// DELETE - Remove a team ID from the coach's `teamsCoaching` array
    /// This function removes a team ID from the coach's `teamsCoaching` field.
    /// - Parameter coachId: The unique coach ID to update.
    /// - Parameter teamId: The team ID to remove from the `teamsCoaching` array.
    public func removeTeamToCoach(coachId: String, teamId: String) async throws {
        try await repo.removeTeamToCoach(coachId: coachId, teamId: teamId)
    }
    
    
    /// GET - Fetch all teams that a coach is associated with
    /// This function retrieves the teams a coach is coaching by using their `teamsCoaching` array, which stores the team IDs.
    /// - Parameter coachId: The unique coach ID to retrieve their teams.
    /// - Returns: An optional array of `GetTeam` objects containing the team information.
    public func loadTeamsCoaching(coachId: String) async throws -> [GetTeam]? {
        return try await repo.loadTeamsCoaching(coachId: coachId)
    }
    

    /// GET - Fetch all teams that a coach is associated with and return them as `DBTeam` objects
    /// This function fetches the full `DBTeam` objects for all teams the coach is coaching.
    /// - Parameter coachId: The unique coach ID to retrieve their teams.
    /// - Returns: An optional array of `DBTeam` objects.
    public func loadAllTeamsCoaching(coachId: String) async throws -> [DBTeam]? {
        return try await repo.loadAllTeamsCoaching(coachId: coachId)
    }
}
