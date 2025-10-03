//
//  GameFrameIOSTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-01-30.
//

//import Testing
//@testable import GameFrameIOS
//
//struct GameFrameIOSTests {
//
//    @Test func example() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }
//
//}

import Testing
@testable import GameFrameIOS
import Foundation

struct GameFrameIOSTests {
    
    /// Tests that the DBUser model correctly loads from a JSON file
    /// and that userType is mapped to the correct enum values.
    @Test
    func testLoadUsersFromJSON() async throws {
        // Load test data from TestUsers.json
        let users: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        
        // Verify number of users loaded
        #expect(users.count == 2)  // Example: expecting 2 users in the JSON
        
        // Verify first user is mapped to coach
        #expect(users.first?.userType == .coach)
        
        // Verify last user is mapped to player
        #expect(users.last?.userType == .player)
    }
}
