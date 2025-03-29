//
//  TeamMembershipPlanManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-27.
//

import Foundation
import FirebaseFirestore

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

final class TeamMembershipPlanManager {
    static let shared = TeamMembershipPlanManager()
    private init() {}
    
    private func membershipPlanCollection(teamId: String) -> CollectionReference {
        return Firestore.firestore().collection("teams").document(teamId).collection("membershipPlans")
    }
    
    /** GET - Retrieve all membership plans for a given team */
    func getAllMembershipPlans(teamId: String) async throws -> [TeamMembershipPlan] {
        let snapshot = try await membershipPlanCollection(teamId: teamId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: TeamMembershipPlan.self) }
    }
    
    /** GET - Retrieve a specific membership plan by ID */
    func getMembershipPlan(teamId: String, planId: String) async throws -> TeamMembershipPlan? {
        let document = try await membershipPlanCollection(teamId: teamId).document(planId).getDocument()
        return try? document.data(as: TeamMembershipPlan.self)
    }
    
    /** POST - Add a new membership plan to the database */
    func addMembershipPlan(teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) async throws {
        let planDocument = membershipPlanCollection(teamId: teamId).document()
        let newPlan = TeamMembershipPlan(planId: planDocument.documentID, teamId: teamId, name: name, price: price, benefits: benefits, durationInMonths: durationInMonths)
        try planDocument.setData(from: newPlan, merge: false)
    }
    
    /** UPDATE - Modify an existing membership plan */
    func updateMembershipPlan(teamId: String, planId: String, name: String? = nil, price: Double? = nil, benefits: [String]? = nil, durationInMonths: Int? = nil) async throws {
        var updatedData: [String: Any] = [:]
        
        if let name = name { updatedData["name"] = name }
        if let price = price { updatedData["price"] = price }
        if let benefits = benefits { updatedData["benefits"] = benefits }
        if let durationInMonths = durationInMonths { updatedData["durationInMonths"] = durationInMonths }
        
        try await membershipPlanCollection(teamId: teamId).document(planId).updateData(updatedData)
    }
    
    /** DELETE - Remove a membership plan from the database */
    func removeMembershipPlan(teamId: String, planId: String) async throws {
        try await membershipPlanCollection(teamId: teamId).document(planId).delete()
    }
}
