//
//  SharedEnums.swift
//  GameFrameIOS
//  Created to hold enums shared between app and UI tests
// 🚫 No Firebase imports here!
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

/// **UserType**: Enum representing different user types in the system.
/// - This enum represents the different types of users in the system. The two possible values are:
/// - `coach`: Refers to a user who is a coach.
/// - `player`: Refers to a user who is a player.
/// - This enum can be used for distinguishing between different user roles in the authentication system, access control, and content customization.
public enum UserType: String, Codable {
    case coach = "Coach"
    case player = "Player"
    case unknown = "Unknown"
    
    public var displayName: String {
        return self.rawValue
    }
    
    // Custom init to handle Firestore strings
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Coach": self = .coach
        case "Player": self = .player
        default: self = .unknown
        }
    }
    
    // Custom encoder to match Firestore values
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .coach: try container.encode("Coach")
        case .player: try container.encode("Player")
        case .unknown: try container.encode("Unknown")
        }
    }
}


public enum PricingPlan: String, CaseIterable {
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
