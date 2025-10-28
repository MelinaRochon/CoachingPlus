//
//  DBTeamMembershipPlan.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

/// Represents a membership plan for a team, containing pricing, benefits, and duration details.
public struct DBTeamMembershipPlan: Codable {
    public let planId: String
    public let teamId: String
    public var name: String
    public var price: Double
    public var benefits: [String]
    public var durationInMonths: Int // Duration of the plan

    public init(planId: String, teamId: String, name: String, price: Double, benefits: [String], durationInMonths: Int) {
        self.planId = planId
        self.teamId = teamId
        self.name = name
        self.price = price
        self.benefits = benefits
        self.durationInMonths = durationInMonths
    }
}
