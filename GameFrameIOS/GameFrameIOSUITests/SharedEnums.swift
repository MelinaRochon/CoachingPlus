//
//  SharedEnums.swift
//  GameFrameIOS
//  Created to hold enums shared between app and UI tests
// 🚫 No Firebase imports here!
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

public enum PricingPlanTestUI: String, CaseIterable {
    case free = "Free"
    case plus = "Plus"
    case premium = "Premium"
    
    public var description: String {
        switch self {
        case .free:
            return "Limited features, no cost!"
        case .plus:
            return "More features for personal use!"
        case .premium:
            return "Best for teams and professionals!"
        }
    }
    
    public var accessibilityId: String {
        "pricing.plan.\(self.rawValue.lowercased()).btn"
    }
}
