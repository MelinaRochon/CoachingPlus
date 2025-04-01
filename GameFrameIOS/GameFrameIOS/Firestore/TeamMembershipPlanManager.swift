//
//  TeamMembershipPlanManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-27.
//

import Foundation
import FirebaseFirestore

/// Represents a membership plan for a team, containing pricing, benefits, and duration details.
struct TeamMembershipPlan: Codable {
    let planId: String
    let teamId: String
    let name: String
    let price: Double
    let benefits: [String]
    let durationInMonths: Int // Duration of the plan

    init(planId: String, teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) {
        self.planId = planId
        self.teamId = teamId
        self.name = name
        self.price = price
        self.benefits = benefits
        self.durationInMonths = durationInMonths
    }
}

/// Manages team membership plans, allowing for creation, retrieval, updating, and deletion.
final class TeamMembershipPlanManager {
    
    static let shared = TeamMembershipPlanManager()
    private init() {}
    
    
    /// Returns a reference to the Firestore collection for membership plans of a specific team.
    /// - Parameter teamId: The ID of the team.
    /// - Returns: A reference to the Firestore collection for the team's membership plans.
    private func membershipPlanCollection(teamId: String) -> CollectionReference {
        return Firestore.firestore().collection("teams").document(teamId).collection("membershipPlans")
    }
    
    
    /// Retrieves all membership plans for a specific team.
    /// - Parameter teamId: The ID of the team.
    /// - Returns: An array of `TeamMembershipPlan` objects.
    /// - Throws: An error if the database query fails.
    func getAllMembershipPlans(teamId: String) async throws -> [TeamMembershipPlan] {
        let snapshot = try await membershipPlanCollection(teamId: teamId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: TeamMembershipPlan.self) }
    }
    
    
    /// Retrieves a specific membership plan by its ID.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - planId: The ID of the membership plan.
    /// - Returns: A `TeamMembershipPlan` object if found, otherwise `nil`.
    /// - Throws: An error if the database query fails.
    func getMembershipPlan(teamId: String, planId: String) async throws -> TeamMembershipPlan? {
        let document = try await membershipPlanCollection(teamId: teamId).document(planId).getDocument()
        return try? document.data(as: TeamMembershipPlan.self)
    }
    
    
    /// Adds a new membership plan to a team.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - name: The name of the membership plan.
    ///   - price: The price of the membership plan.
    ///   - benefits: A list of benefits included in the plan.
    ///   - durationInMonths: The duration of the plan in months.
    /// - Throws: An error if the operation fails.
    func addMembershipPlan(teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) async throws {
        let planDocument = membershipPlanCollection(teamId: teamId).document()
        let newPlan = TeamMembershipPlan(planId: planDocument.documentID, teamId: teamId, name: name, price: price, benefits: benefits, durationInMonths: durationInMonths)
        try planDocument.setData(from: newPlan, merge: false)
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
    func updateMembershipPlan(teamId: String, planId: String, name: String? = nil, price: Double? = nil, benefits: [String]? = nil, durationInMonths: Int? = nil) async throws {
        var updatedData: [String: Any] = [:]
        
        if let name = name { updatedData["name"] = name }
        if let price = price { updatedData["price"] = price }
        if let benefits = benefits { updatedData["benefits"] = benefits }
        if let durationInMonths = durationInMonths { updatedData["durationInMonths"] = durationInMonths }
        
        try await membershipPlanCollection(teamId: teamId).document(planId).updateData(updatedData)
    }
    
    
    /// Removes a membership plan from a team.
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - planId: The ID of the membership plan to delete.
    /// - Throws: An error if the deletion fails.
    func removeMembershipPlan(teamId: String, planId: String) async throws {
        try await membershipPlanCollection(teamId: teamId).document(planId).delete()
    }
}
