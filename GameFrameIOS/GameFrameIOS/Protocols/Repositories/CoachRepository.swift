//
//  CoachRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// Protocol defining operations for managing coaches and their associated teams in the database.
protocol CoachRepository {

    /// Adds a new coach to the database.
    /// - Parameter coachId: The unique identifier of the coach to add.
    /// - Throws: An error if the operation fails.
    func addCoach(coachId: String) async throws

    /// Fetches the detailed information of a specific coach.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: A `DBCoach` object if the coach exists, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getCoach(coachId: String) async throws -> DBCoach?

    /// Associates a team with a specific coach.
    /// - Parameters:
    ///   - coachId: The unique identifier of the coach.
    ///   - teamId: The unique identifier of the team to add.
    /// - Throws: An error if the operation fails.
    func addTeamToCoach(coachId: String, teamId: String) async throws

    /// Removes a team from a specific coach’s list of teams.
    /// - Parameters:
    ///   - coachId: The unique identifier of the coach.
    ///   - teamId: The unique identifier of the team to remove.
    /// - Throws: An error if the operation fails.
    func removeTeamToCoach(coachId: String, teamId: String) async throws

    /// Loads a simplified list of teams that a coach is currently coaching.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: An optional array of `GetTeam` objects representing teams the coach manages, or `nil` if none.
    /// - Throws: An error if the retrieval fails.
    func loadTeamsCoaching(coachId: String) async throws -> [GetTeam]?

    /// Loads the full details of all teams a coach is currently coaching.
    /// - Parameter coachId: The unique identifier of the coach.
    /// - Returns: An optional array of `DBTeam` objects representing teams the coach manages, or `nil` if none.
    /// - Throws: An error if the retrieval fails.
    func loadAllTeamsCoaching(coachId: String) async throws -> [DBTeam]?
}
