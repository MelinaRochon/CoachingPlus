//
//  DBTeamMembershipPlan.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// Represents a membership plan for a team, containing pricing, benefits, and duration details.
struct DBTeamMembershipPlan: Codable {
    let planId: String
    let teamId: String
    var name: String
    var price: Double
    var benefits: [String]
    var durationInMonths: Int // Duration of the plan

    init(planId: String, teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) {
        self.planId = planId
        self.teamId = teamId
        self.name = name
        self.price = price
        self.benefits = benefits
        self.durationInMonths = durationInMonths
    }
}
