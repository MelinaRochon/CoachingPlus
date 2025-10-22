//
//  UserManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-21.
//

import XCTest
@testable import GameFrameIOS

final class UserManagerTests: XCTestCase {
    var manager: UserManager!
    var localRepo: LocalUserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalUserRepository()
        manager = UserManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }

    func testAddUser() async throws {
        let userId = "user_123"
        
        // Add a new user
        let userDTO = UserDTO(userId: userId, email: "user@example.com", userType: .player, firstName: "John", lastName: "Doe")
        let user = try await createUser(for: manager, userDTO: userDTO, userId: userId)
        
        XCTAssertNotNil(user, "User should exist after being added")
        XCTAssertEqual(user?.userId, userId)
    }
    
    func testGetValidUserType() async throws {
        let userId = "uid001" // User Id taken from JSON file
        let userType = UserType.coach
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        let sampleUser = sampleUsers.first(where: { $0.userId == userId })
        guard let user = try await createUserFromJSON(for: manager, user: sampleUser!, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userType, userType, "User type should match \(userType)")
    }
    
    func testGetUser() async throws {
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard let user = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, sampleUser.userId!, "User ID should match")
        XCTAssertEqual(user.firstName, sampleUser.firstName, "User's first name should match")
        XCTAssertEqual(user.lastName, sampleUser.lastName, "User's last name should match")
        XCTAssertEqual(user.userType, sampleUser.userType, "User type should match")
        XCTAssertEqual(user.email, sampleUser.email, "User's email should match")
    }
    
    func testGetUserWithDocId() async throws {
        let userId = "uid001"
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        let sampleUser = sampleUsers.first(where: { $0.userId == userId })
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser!, userId: userId) else {
            XCTFail("User should exist")
            return
        }

        // Get the user with the document id
        guard let user = try await manager.getUserWithDocId(id: jsonUser.id) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
    }
    
    func testGetUserWithEmail() async throws {
        let userId = "uid001"
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        let sampleUser = sampleUsers.first(where: { $0.userId == userId })
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser!, userId: userId) else {
            XCTFail("User should exist")
            return
        }

        let user = try await manager.getUserWithEmail(email: jsonUser.email)
        XCTAssertEqual(user?.userId, userId, "User ID should match")
        XCTAssertEqual(jsonUser.email, user?.email, "User's email should match")
    }
    
    func testUpdatedCoachProfile() async throws {
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard var jsonUser = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }

        // Update coach profile
        let updatedFirstName = "Brian"
        jsonUser.firstName = updatedFirstName
        try await manager.updateCoachProfile(user: jsonUser)
        
        let updatedUser = try await manager.getUser(userId: jsonUser.userId!)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User's first name should have changed")
    }
    
    func testUpdateCoachSettings() async throws {
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }
        
        let updatedPhone = "6661234567"
        let updatedFirstName = "Brian"
        let updatedLastName = "Adams"
        
        // Update coach profile
        try await manager.updateCoachSettings(id: jsonUser.id, phone: updatedPhone, dateOfBirth: jsonUser.dateOfBirth, firstName: updatedFirstName, lastName: updatedLastName, membershipDetails: nil)
        
        let updatedUser = try await manager.getUser(userId: jsonUser.userId!)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User's first name should have changed")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User's last name should have changed")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User's phone name should have changed")
    }
    
    func testFindUserWithId() async throws {
        let id = "u010"
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        
        XCTAssertEqual(sampleUsers.first(where: { $0.id == id })?.id, id, "User doc ID should match")
    }
    
    func testUpdatedUserDTO() async throws {
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }
        
        // Update DTO
        let updatedFirstName = "Jane"
        let updatedLastName = "Smith"
        let updatedEmail = "jane@example.com"
        let updatedUserType: UserType = .coach
        let updatedPhone = "1234567890"
        let updatedCountry = "Mexico"
        let updatedDob = Date()
        
        try await manager.updateUserDTO(id: jsonUser.id, email: updatedEmail, userTpe: updatedUserType, firstName: updatedFirstName, lastName: updatedLastName, dob: updatedDob, phone: updatedPhone, country: updatedCountry, userId: jsonUser.userId!)
        
        let updatedUser = try await manager.getUser(userId: jsonUser.userId!)
        XCTAssertEqual(updatedUser?.userId, jsonUser.userId!, "User ID should match")
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User first name should match")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User last name should match")
        XCTAssertEqual(updatedUser?.email, updatedEmail, "User email should match")
        XCTAssertEqual(updatedUser?.userType, updatedUserType, "User user type should match")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User phone number should match")
        XCTAssertEqual(updatedUser?.country, updatedCountry, "User country should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdatedUserDoB() async throws {
        let isoFormatter = ISO8601DateFormatter()
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }
        
        // Update date of birth
        try await manager.updateUserDOB(id: jsonUser.id, dob: updatedDob)
    
        let updatedUser = try await manager.getUser(userId: jsonUser.userId!)
        XCTAssertEqual(updatedUser?.userId, jsonUser.userId!, "User ID should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdateUserSettings() async throws {
        let isoFormatter = ISO8601DateFormatter()

        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard let jsonUser = try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) else {
            XCTFail("User should exist")
            return
        }
        
        // Update DTO
        let updatedFirstName = "Jane"
        let updatedLastName = "Smith"
        let updatedPhone = "1234567890"
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        try await manager.updateUserSettings(id: jsonUser.id, dateOfBirth: updatedDob, firstName: updatedFirstName, lastName: updatedLastName, phone: updatedPhone)
        
        let updatedUser = try await manager.getUser(userId: jsonUser.userId!)
        XCTAssertEqual(updatedUser?.userId, sampleUser.userId!, "User ID should match")
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User first name should match")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User last name should match")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User phone number should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    // MARK: Negative Testing
    
    /// Tests an invalid user type
    func testGetInvalidUserType() async throws {
        let userId = "uid001" // User Id taken from JSON file
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("InvalidTestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first(where: { $0.userId == userId }) else {
            XCTFail("No user found with userId \(userId)")
            return
        }

        // Add a new user
        guard let user = try await createUserFromJSON(for: manager, user: sampleUser, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        // Check that an unknown user type was found
        XCTAssertEqual(user.userType, .unknown, "User type should match")
    }

    func testGetInvalidUser() async throws {
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first else { return }
        guard try await createUserFromJSON(for: manager, user: sampleUser, userId: sampleUser.userId!) != nil else {
            XCTFail("User should exist")
            return
        }
        
        // Get unvalid user
        let userId = "user_123"
        let invalidUser = try await manager.getUser(userId: userId)
        
        XCTAssertNil(invalidUser, "User should be nil")
    }

    func testGetUserWithInvalidDocId() async throws {
        let userId = "uid001"
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        guard let sampleUser = sampleUsers.first(where: { $0.userId == userId }) else { return }
        guard try await createUserFromJSON(for: manager, user: sampleUser, userId: userId) != nil else {
            XCTFail("User should exist")
            return
        }

        // Try to get a user document with invalid user id
        let invalidUserId = "user_123"
        let user = try await manager.getUserWithDocId(id: invalidUserId)
        XCTAssertNil(user, "User should be nil")
    }
    
    func testGetUserWithInvalidEmail() async throws {
        let userId = "uid001"
        
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        let sampleUser = sampleUsers.first(where: { $0.userId == userId })
        guard try await createUserFromJSON(for: manager, user: sampleUser!, userId: userId) != nil else {
            XCTFail("User should exist")
            return
        }

        // Try to get the user with an invalid email address
        let user = try await manager.getUserWithEmail(email: "notvalidemail@gmail.com")
        XCTAssertNil(user, "User should be nil")
    }

    
    func testFindUserWithInvalidId() async throws {
        let id = "uu010"
        // Load users from JSON test file
        let sampleUsers: [DBUser] = TestDataLoader.load("TestUsers", as: [DBUser].self)
        
        XCTAssertNotEqual(sampleUsers.first(where: { $0.id == id })?.id, id, "User doc ID should not match")
    }
}
