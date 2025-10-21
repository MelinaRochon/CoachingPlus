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
    
    func testGetUserType() async throws {
        let userId = "user_123"
        let userType = UserType.player
        
        // Add a new user
        let userDTO = UserDTO(userId: userId, email: "user@example.com", userType: userType, firstName: "John", lastName: "Doe")
        guard let user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userType, userType, "User type should match")
    }
    
    func testGetUser() async throws {
        let userId = "user_123"
        let userType = UserType.coach
        let email = "user@example.com"
        let firstName = "John"
        let lastName = "Doe"
        
        // Add a new user
        let userDTO = UserDTO(userId: userId, email: email, userType: userType, firstName: firstName, lastName: lastName)
        guard let user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
        XCTAssertEqual(user.firstName, firstName, "User's first name should match")
        XCTAssertEqual(user.lastName, lastName, "User's last name should match")
        XCTAssertEqual(user.userType, userType, "User type should match")
        XCTAssertEqual(user.email, email, "User's email should match")
    }
    
    func testGetUserWithDocId() async throws {
        let userId = "user_123"
        
        // Add a new user
        let userDTO = UserDTO(userId: userId, email: "user@example.com", userType: .player, firstName: "John", lastName: "Doe")
        let id = try await manager.createNewUser(userDTO: userDTO)

        // Get the user with the document id
        guard let user = try await manager.getUserWithDocId(id: id) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
    }
    
    func testGetUserWithEmail() async throws {
        let userId = "user_123"
        let email = "user@example.com"

        // Add a new user
        let userDTO = UserDTO(userId: userId, email: email, userType: .player, firstName: "John", lastName: "Doe")
        try await manager.createNewUser(userDTO: userDTO)
        guard let user = try await manager.getUserWithEmail(email: email) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
        XCTAssertEqual(user.email, email, "User's email should match")
    }
    
    func testUpdatedCoachProfile() async throws {
        let userId = "user_123"
        let userType = UserType.coach
        let updatedFirstName = "Brian"
        
        var userDTO = UserDTO(userId: userId, email: "user@example.com", userType: userType, firstName: "John", lastName: "Doe")
        guard var user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userType, userType, "User type should match")
       
        // Update coach profile
        user.firstName = updatedFirstName
        try await manager.updateCoachProfile(user: user)
        
        let updatedUser = try await manager.getUser(userId: userId)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User's first name should have changed")
    }
    
    func testUpdateCoachSettings() async throws {
        let userId = "user_123"
        let userType = UserType.coach
        
        var userDTO = UserDTO(userId: userId, email: "user@example.com", userType: userType, firstName: "John", lastName: "Doe")
        guard var user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userType, userType, "User type should match")
        
        let updatedPhone = "6661234567"
        let updatedFirstName = "Brian"
        let updatedLastName = "Adams"
        
        // Update coach profile
        try await manager.updateCoachSettings(id: user.id, phone: updatedPhone, dateOfBirth: user.dateOfBirth, firstName: updatedFirstName, lastName: updatedLastName, membershipDetails: nil)
        
        let updatedUser = try await manager.getUser(userId: userId)
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
        let userId = "user_123"
        
        var userDTO = UserDTO(userId: userId, email: "user@example.com", userType: .player, firstName: "John", lastName: "Doe")
        guard var user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
        
        // Update DTO
        let updatedFirstName = "Jane"
        let updatedLastName = "Smith"
        let updatedEmail = "jane@example.com"
        let updatedUserType: UserType = .coach
        let updatedPhone = "1234567890"
        let updatedCountry = "Mexico"
        let updatedDob = Date()
        
        try await manager.updateUserDTO(id: user.id, email: updatedEmail, userTpe: updatedUserType, firstName: updatedFirstName, lastName: updatedLastName, dob: updatedDob, phone: updatedPhone, country: updatedCountry, userId: userId)
        
        let updatedUser = try await manager.getUser(userId: userId)
        XCTAssertEqual(updatedUser?.userId, userId, "User ID should match")
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User first name should match")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User last name should match")
        XCTAssertEqual(updatedUser?.email, updatedEmail, "User email should match")
        XCTAssertEqual(updatedUser?.userType, updatedUserType, "User user type should match")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User phone number should match")
        XCTAssertEqual(updatedUser?.country, updatedCountry, "User country should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdatedUserDoB() async throws {
        let userId = "user_123"
        let isoFormatter = ISO8601DateFormatter()
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        var userDTO = UserDTO(userId: userId, email: "user@example.com", userType: .player, firstName: "John", lastName: "Doe")
        guard var user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
        
        // Update date of birth
        try await manager.updateUserDOB(id: user.id, dob: updatedDob)
    
        let updatedUser = try await manager.getUser(userId: userId)
        XCTAssertEqual(updatedUser?.userId, userId, "User ID should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdateUserSettings() async throws {
        let userId = "user_123"
        let isoFormatter = ISO8601DateFormatter()

        var userDTO = UserDTO(userId: userId, email: "user@example.com", userType: .player, firstName: "John", lastName: "Doe")
        guard var user = try await createUser(for: manager, userDTO: userDTO, userId: userId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertEqual(user.userId, userId, "User ID should match")
        
        // Update DTO
        let updatedFirstName = "Jane"
        let updatedLastName = "Smith"
        let updatedPhone = "1234567890"
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        
        try await manager.updateUserSettings(id: user.id, dateOfBirth: updatedDob, firstName: updatedFirstName, lastName: updatedLastName, phone: updatedPhone)
        let updatedUser = try await manager.getUser(userId: userId)
        XCTAssertEqual(updatedUser?.userId, userId, "User ID should match")
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User first name should match")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User last name should match")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User phone number should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
}
