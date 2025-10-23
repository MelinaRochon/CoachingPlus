//
//  LocalTeamMembershipPlanRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
@testable import GameFrameIOS

final class LocalTeamMembershipPlanRepository: TeamMembershipPlanRepository {
    private var teamMembershipPlans: [GameFrameIOS.DBTeamMembershipPlan] = []
    
    func getAllMembershipPlans(teamId: String) async throws -> [GameFrameIOS.DBTeamMembershipPlan] {
        return teamMembershipPlans.filter( { $0.teamId == teamId })
    }
    
    func getMembershipPlan(teamId: String, planId: String) async throws -> GameFrameIOS.DBTeamMembershipPlan? {
        return teamMembershipPlans.first(where: { $0.teamId == teamId && $0.planId == planId })
    }
    
    func addMembershipPlan(teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) async throws {
        let id = UUID().uuidString
        let membershipObj = DBTeamMembershipPlan(planId: id, teamId: teamId, name: name, price: price, benefits: benefits, durationInMonths: durationInMonths)
        teamMembershipPlans.append(membershipObj)
    }
    
    func updateMembershipPlan(teamId: String, planId: String, name: String?, price: Double?, benefits: [String]?, durationInMonths: Int?) async throws {
        // Find the index first so we can persist back into the array
            guard let idx = teamMembershipPlans.firstIndex(where: { $0.teamId == teamId && $0.planId == planId }) else {
                throw NSError(domain: "LocalTeamMembershipPlanRepository",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Membership plan not found"])
            }

            var plan = teamMembershipPlans[idx]
            if let name { plan.name = name }
            if let price { plan.price = price }
            if let benefits { plan.benefits = benefits }
            if let durationInMonths { plan.durationInMonths = durationInMonths }

            teamMembershipPlans[idx] = plan
    }
    
    func removeMembershipPlan(teamId: String, planId: String) async throws {
        guard let index = teamMembershipPlans.firstIndex(where: { $0.teamId == teamId && $0.planId == planId }) else {
            print("Could not find membership plan that matches the plan id \(planId)")
            return
        }
        
        teamMembershipPlans.remove(at: index)
    }
}
