//
//  TeamMembershipPlanRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// A repository responsible for managing team membership plans in the database.
public protocol TeamMembershipPlanRepository {
    
    /// Retrieves all membership plans associated with a specific team.
    /// - Parameter teamId: The Firestore document ID of the team.
    /// - Returns: An array of `DBTeamMembershipPlan` objects representing all the membership plans for the team.
    /// - Throws: An error if the retrieval fails.
    func getAllMembershipPlans(teamId: String) async throws -> [DBTeamMembershipPlan]
    
    /// Retrieves a specific membership plan by its ID.
    /// - Parameters:
    ///   - teamId: The Firestore document ID of the team.
    ///   - planId: The Firestore document ID of the membership plan.
    /// - Returns: A `DBTeamMembershipPlan` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getMembershipPlan(teamId: String, planId: String) async throws -> DBTeamMembershipPlan?
    
    /// Adds a new membership plan to the specified team.
    /// - Parameters:
    ///   - teamId: The Firestore document ID of the team.
    ///   - name: The name of the membership plan.
    ///   - price: The cost of the plan.
    ///   - benefits: A list of benefits included in the plan.
    ///   - durationInMonths: The duration of the plan in months.
    /// - Throws: An error if the creation fails.
    func addMembershipPlan(teamId: String,
                           name: String,
                           price: Double,
                           benefits: [String],
                           durationInMonths: Int) async throws
    
    /// Updates an existing membership plan’s details.
    /// - Parameters:
    ///   - teamId: The Firestore document ID of the team.
    ///   - planId: The Firestore document ID of the plan to update.
    ///   - name: The updated name of the plan (optional).
    ///   - price: The updated price of the plan (optional).
    ///   - benefits: The updated list of benefits (optional).
    ///   - durationInMonths: The updated duration of the plan in months (optional).
    /// - Throws: An error if the update fails.
    func updateMembershipPlan(teamId: String,
                              planId: String,
                              name: String?,
                              price: Double?,
                              benefits: [String]?,
                              durationInMonths: Int?) async throws
    
    /// Removes a membership plan from the database.
    /// - Parameters:
    ///   - teamId: The Firestore document ID of the team.
    ///   - planId: The Firestore document ID of the plan to remove.
    /// - Throws: An error if the deletion fails.
    func removeMembershipPlan(teamId: String, planId: String) async throws
}
