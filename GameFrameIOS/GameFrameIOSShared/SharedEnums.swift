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

public enum InviteStatus: String, Codable {
    case accepted = "Accepted"
    case pending = "Pending"
    case unknown = "Unknown" // Throws error

    public var displayName: String {
        return self.rawValue
    }
    
    // Custom init to handle Firestore strings
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Accepted": self = .accepted
        case "Pending": self = .pending
        default: self = .unknown
        }
    }
    
    // Custom encoder to match Firestore values
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .accepted: try container.encode("Accepted")
        case .pending: try container.encode("Pending")
        case .unknown: try container.encode("Unknown")
        }
    }
}

public enum UserAccountStatus: String, Codable {
    case verified = "Verified"
    case unverified = "Unverified"
    case unknown = "Unknown" // Throws error

    public var displayName: String {
        return self.rawValue
    }
    
    // Custom init to handle Firestore strings
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Verified": self = .verified
        case "Unverified": self = .unverified
        default: self = .unknown
        }
    }
    
    // Custom encoder to match Firestore values
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .verified: try container.encode("Verified")
        case .unverified: try container.encode("Unverified")
        case .unknown: try container.encode("Unknown")
        }
    }
}



public enum SoccerPosition: String, CaseIterable, Codable, Identifiable, Comparable {
    case goalkeeper = "GK"
    case centerBack = "CB"
    case rightCenterBack = "RCB"
    case leftCenterBack = "LCB"
    case sweeper = "SW"
    case rightBack = "RB"
    case leftBack = "LB"
    case rightWingBack = "RWB"
    case leftWingBack = "LWB"
    case defensiveMidfielder = "CDM"
    case centralMidfielder = "CM"
    case rightCentralMidfielder = "RCM"
    case leftCentralMidfielder = "LCM"
    case attackingMidfielder = "CAM"
    case rightMidfielder = "RM"
    case leftMidfielder = "LM"
    case rightWinger = "RW"
    case leftWinger = "LW"
    case striker = "ST"
    case centerForward = "CF"
    case falseNine = "F9"
    case secondStriker = "SS"
    case other = "OTHER"

    public var id: String { self.rawValue }

    public var fullName: String {
        switch self {
        case .goalkeeper: return "Goalkeeper"
        case .centerBack: return "Center Back"
        case .rightCenterBack: return "Right Center Back"
        case .leftCenterBack: return "Left Center Back"
        case .sweeper: return "Sweeper"
        case .rightBack: return "Right Back"
        case .leftBack: return "Left Back"
        case .rightWingBack: return "Right Wing-Back"
        case .leftWingBack: return "Left Wing-Back"
        case .defensiveMidfielder: return "Defensive Midfielder"
        case .centralMidfielder: return "Central Midfielder"
        case .rightCentralMidfielder: return "Right Central Midfielder"
        case .leftCentralMidfielder: return "Left Central Midfielder"
        case .attackingMidfielder: return "Attacking Midfielder"
        case .rightMidfielder: return "Right Midfielder"
        case .leftMidfielder: return "Left Midfielder"
        case .rightWinger: return "Right Winger"
        case .leftWinger: return "Left Winger"
        case .striker: return "Striker"
        case .centerForward: return "Center Forward"
        case .falseNine: return "False 9"
        case .secondStriker: return "Second Striker"
        case .other: return "Other"
        }
    }
    
    public static func < (lhs: SoccerPosition, rhs: SoccerPosition) -> Bool {
            let order: [SoccerPosition] = [
                .goalkeeper, .centerBack, .rightCenterBack, .leftCenterBack, .sweeper, .rightBack, .leftBack, .rightWingBack, .leftWingBack, .defensiveMidfielder, .centralMidfielder, .rightCentralMidfielder, .leftCentralMidfielder, .attackingMidfielder, .rightMidfielder, .leftMidfielder, .rightWinger, .leftWinger, .striker, .centerForward, .falseNine, .secondStriker, .other
            ]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "GK": self = .goalkeeper
        case "CB": self = .centerBack
        case "RCB": self = .rightCenterBack
        case "LCB": self = .leftCenterBack
        case "SW": self = .sweeper
        case "RB": self = .rightBack
        case "LB": self = .leftBack
        case "RWB": self = .rightWingBack
        case "LWB": self = .leftWingBack
        case "CDM": self = .defensiveMidfielder
        case "CM": self = .centralMidfielder
        case "RCM": self = .rightCentralMidfielder
        case "LCM": self = .leftCentralMidfielder
        case "CAM": self = .attackingMidfielder
        case "RM": self = .rightMidfielder
        case "LM": self = .leftMidfielder
        case "RW": self = .rightWinger
        case "LW": self = .leftWinger
        case "ST": self = .striker
        case "CF": self = .centerForward
        case "F9": self = .falseNine
        case "SS": self = .secondStriker
        default: self = .other
        }
    }
    
    // Custom encoder to match Firestore values
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .goalkeeper: try container.encode("GK")
        case .centerBack: try container.encode("CB")
        case .rightCenterBack: try container.encode("RCB")
        case .leftCenterBack: try container.encode("LCB")
        case .sweeper: try container.encode("SW")
        case .rightBack: try container.encode("RB")
        case .leftBack: try container.encode("LB")
        case .rightWingBack: try container.encode("RWB")
        case .leftWingBack: try container.encode("LWB")
        case .defensiveMidfielder: try container.encode("CDM")
        case .centralMidfielder: try container.encode("CM")
        case .rightCentralMidfielder: try container.encode("RCM")
        case .leftCentralMidfielder: try container.encode("LCM")
        case .attackingMidfielder: try container.encode("CAM")
        case .rightMidfielder: try container.encode("RM")
        case .leftMidfielder: try container.encode("LM")
        case .rightWinger: try container.encode("RW")
        case .leftWinger: try container.encode("LW")
        case .striker: try container.encode("ST")
        case .centerForward: try container.encode("CF")
        case .falseNine: try container.encode("F9")
        case .secondStriker: try container.encode("SS")
        case .other: try container.encode("OTHER")
        }
    }
}

