//
//  TeamMembershipPlanManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-27.
//

import Foundation


/// Manages team membership plans, allowing for creation, retrieval, updating, and deletion.
public final class TeamMembershipPlanManager {
    
    private let repo: TeamMembershipPlanRepository
    
    public init(repo: TeamMembershipPlanRepository) {
        self.repo = repo
    }
    
    /// Retrieves all membership plans for a specific team.
    /// - Parameter teamId: The ID of the team.
    /// - Returns: An array of `TeamMembershipPlan` objects.
    /// - Throws: An error if the database query fails.
    public func getAllMembershipPlans(teamId: String) async throws -> [DBTeamMembershipPlan] {
        return try await repo.getAllMembershipPlans(teamId: teamId)
    }
    
    
    /// Retrieves a specific membership plan by its ID.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - planId: The ID of the membership plan.
    /// - Returns: A `TeamMembershipPlan` object if found, otherwise `nil`.
    /// - Throws: An error if the database query fails.
    public func getMembershipPlan(teamId: String, planId: String) async throws -> DBTeamMembershipPlan? {
        return try await repo.getMembershipPlan(teamId: teamId, planId: planId)
    }
    
    
    /// Adds a new membership plan to a team.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - name: The name of the membership plan.
    ///   - price: The price of the membership plan.
    ///   - benefits: A list of benefits included in the plan.
    ///   - durationInMonths: The duration of the plan in months.
    /// - Throws: An error if the operation fails.
    public func addMembershipPlan(teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) async throws {
        try await repo.addMembershipPlan(teamId: teamId, name: name, price: price, benefits: benefits, durationInMonths: durationInMonths)
    }
    
    
    /// Updates an existing membership plan with new details.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - planId: The ID of the membership plan to update.
    ///   - name: (Optional) New name of the membership plan.
    ///   - price: (Optional) New price of the membership plan.
    ///   - benefits: (Optional) Updated list of benefits.
    ///   - durationInMonths: (Optional) Updated duration of the plan in months.
    /// - Throws: An error if the update fails.
    public func updateMembershipPlan(teamId: String, planId: String, name: String? = nil, price: Double? = nil, benefits: [String]? = nil, durationInMonths: Int? = nil) async throws {
        try await repo.updateMembershipPlan(
            teamId: teamId,
            planId: planId,
            name: name,
            price: price,
            benefits: benefits,
            durationInMonths: durationInMonths
        )
    }
    
    
    /// Removes a membership plan from a team.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - planId: The ID of the membership plan to delete.
    /// - Throws: An error if the deletion fails.
    public func removeMembershipPlan(teamId: String, planId: String) async throws {
        try await repo.removeMembershipPlan(teamId: teamId, planId: planId)
    }
}
