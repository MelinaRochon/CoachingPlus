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
        
        // Make sure user to be addded is not already a user
        let tmpUser = try await manager.getUser(userId: userId)
        XCTAssertNil(tmpUser)
        
        // Add a new user
        let userDTO = UserDTO(
            userId: userId,
            email: "user@example.com",
            userType: .player,
            firstName: "John",
            lastName: "Doe"
        )
        let user = try await createUser(for: manager, userDTO: userDTO, userId: userId)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.userId, userId)
    }
    
    func testGetValidUserType() async throws {
        let userId = "uid001" // User Id taken from JSON file
        
        // Make sure the user exists before validating the user type
        let tmpUser = try await manager.getUser(userId: userId)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.userId, userId)
        
        // Get the user type
        let userType = try await manager.getUserType()
        
        XCTAssertEqual(userType, UserType.coach, "User type should match \(userType)")
    }
    
    func testGetUser() async throws {
        let userId = "uid001" // User Id taken from JSON file
        
        // Get the user
        let user = try await manager.getUser(userId: userId)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.userId, userId, "User ID should match")
    }
    
    func testGetUserWithDocId() async throws {
        let userDocId = "u001"
                
        // Get the user with the document id
        guard let user = try await manager.getUserWithDocId(id: userDocId) else {
            XCTFail("User should exist")
            return
        }
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user.id, userDocId, "User ID should match")
    }
    
    func testGetUserWithEmail() async throws {
        let userId = "uid001"
        
        // Make sure the user exists
        let sampleUser = try await manager.getUser(userId: userId)
        XCTAssertNotNil(sampleUser)
        XCTAssertEqual(sampleUser?.userId, userId)
        
        // Get the user with the email address
        let user = try await manager.getUserWithEmail(email: sampleUser!.email)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, sampleUser?.id)
        XCTAssertEqual(user?.userId, userId, "User ID should match")
        XCTAssertEqual(sampleUser?.email, user?.email, "User's email should match")
    }
    
    func testUpdatedCoachProfile() async throws {
        let userId = "uid001"
        let updatedFirstName = "Brian"

        // Make sure the user exists before updating the coach's profile
        guard var user = try await manager.getUser(userId: userId) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(user)
        XCTAssertEqual(user.userId, userId)
        XCTAssertNotEqual(user.firstName, updatedFirstName)
        
        // Update the coach profile
        user.firstName = updatedFirstName
        try await manager.updateCoachProfile(user: user)
        let updatedUser = try await manager.getUser(userId: userId)
        
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.userId, userId)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User's first name should have changed")
    }
    
    func testUpdateCoachSettings() async throws {
        let userDocId = "u001"
        let updatedPhone = "6661234567"
        let updatedFirstName = "Brian"
        let updatedLastName = "Adams"
        
        // Make sure the new user settings do not match the old user settings
        let user = try await manager.getUserWithDocId(id: userDocId)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, userDocId)
        XCTAssertNotEqual(user?.phone, updatedPhone)
        XCTAssertNotEqual(user?.firstName, updatedFirstName)
        XCTAssertNotEqual(user?.lastName, updatedLastName)
        
        // Update coach profile
        try await manager.updateCoachSettings(
            id: userDocId,
            phone: updatedPhone,
            dateOfBirth: user!.dateOfBirth,
            firstName: updatedFirstName,
            lastName: updatedLastName,
            membershipDetails: nil
        )
        let updatedUser = try await manager.getUserWithDocId(id: userDocId)
        
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.id, userDocId)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User's first name should have changed")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User's last name should have changed")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User's phone name should have changed")
    }
    
    func testFindUserWithId() async throws {
        let userDocId = "u010"
        let user = try await manager.getUserWithDocId(id: userDocId)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, userDocId)
    }
    
    func testUpdatedUserDTO() async throws {
        let userDocId = "u001"
        let updatedFirstName = "Jane"
        let updatedLastName = "Doe"
        let updatedEmail = "jane@example.com"
        let updatedUserType: UserType = .player
        let updatedPhone = "1112224321"
        let updatedCountry = "Mexico"
        let updatedDob = Date()

        // Make sure the new user settings do not match the old settings
        let user = try await manager.getUserWithDocId(id: userDocId)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, userDocId)
        XCTAssertNotEqual(user?.email, updatedEmail)
        XCTAssertNotEqual(user?.userType, updatedUserType)
        XCTAssertNotEqual(user?.country, updatedCountry)
        XCTAssertNotEqual(user?.dateOfBirth, updatedDob)
        XCTAssertNotEqual(user?.phone, updatedPhone)
        XCTAssertNotEqual(user?.firstName, updatedFirstName)
        XCTAssertNotEqual(user?.lastName, updatedLastName)

        // Update the user DTO
        try await manager.updateUserDTO(
            id: userDocId,
            email: updatedEmail,
            userTpe: updatedUserType,
            firstName: updatedFirstName,
            lastName: updatedLastName,
            dob: updatedDob,
            phone: updatedPhone,
            country: updatedCountry,
            userId: user!.userId!
        )
        let updatedUser = try await manager.getUserWithDocId(id: userDocId)
        
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.id, userDocId)
        XCTAssertEqual(updatedUser?.firstName, updatedFirstName, "User first name should match")
        XCTAssertEqual(updatedUser?.lastName, updatedLastName, "User last name should match")
        XCTAssertEqual(updatedUser?.email, updatedEmail, "User email should match")
        XCTAssertEqual(updatedUser?.userType, updatedUserType, "User user type should match")
        XCTAssertEqual(updatedUser?.phone, updatedPhone, "User phone number should match")
        XCTAssertEqual(updatedUser?.country, updatedCountry, "User country should match")
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdatedUserDoB() async throws {
        let userDocId = "u001"
        let isoFormatter = ISO8601DateFormatter()
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        // Make sure the user exist
        let user = try await manager.getUserWithDocId(id: userDocId)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, userDocId)
        
        // Make sure the new date of birth do not match the old one
        XCTAssertNotEqual(user?.dateOfBirth, updatedDob)

        // Update date of birth
        try await manager.updateUserDOB(id: userDocId, dob: updatedDob)
        let updatedUser = try await manager.getUserWithDocId(id: userDocId)
        
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.id, userDocId)
        XCTAssertEqual(updatedUser?.dateOfBirth, updatedDob, "User date of birth should match")
    }
    
    func testUpdateUserSettings() async throws {
        let userDocId = "u001"
        let isoFormatter = ISO8601DateFormatter()
        let updatedFirstName = "Jane"
        let updatedLastName = "Doe"
        let updatedPhone = "1112221234"
        let updatedDob = isoFormatter.date(from: "2019-05-05T00:00:00Z")!

        // Make sure the user exist
        let user = try await manager.getUserWithDocId(id: userDocId)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, userDocId)
        
        // Make sure the new user settings do not match the old settings
        XCTAssertNotEqual(user?.dateOfBirth, updatedDob)
        XCTAssertNotEqual(user?.firstName, updatedFirstName)
        XCTAssertNotEqual(user?.lastName, updatedLastName)
        XCTAssertNotEqual(user?.phone, updatedPhone)

        // Update the user settings
        try await manager.updateUserSettings(
            id: userDocId,
            dateOfBirth: updatedDob,
            firstName: updatedFirstName,
            lastName: updatedLastName,
            phone: updatedPhone
        )
        let updatedUser = try await manager.getUserWithDocId(id: userDocId)
        
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.id, userDocId)
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
        
        // Check that an unknown user type was found
        XCTAssertEqual(sampleUser.userType, .unknown, "User type should match")
    }

    func testGetInvalidUser() async throws {
        // Get unvalid user
        let userId = "user_123"
        let invalidUser = try await manager.getUser(userId: userId)
        
        XCTAssertNil(invalidUser, "User should be nil")
    }

    func testGetUserWithInvalidDocId() async throws {
        // Try to get a user document with invalid user id
        let invalidUserId = "user_123"
        let user = try await manager.getUserWithDocId(id: invalidUserId)
        XCTAssertNil(user, "User should be nil")
    }
    
    func testGetUserWithInvalidEmail() async throws {
        let userId = "uid001"
        let invalidEmail = "notvalidemail@gmail.com"
        
        // Make sure the user exists
        let user = try await manager.getUser(userId: userId)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.userId, userId)
        
        // Make sure the user does not have the same email configured
        XCTAssertNotEqual(user?.email, invalidEmail)

        // Try to get the user with an invalid email address
        let invalidUser = try await manager.getUserWithEmail(email: invalidEmail)
        XCTAssertNil(invalidUser, "User should be nil")
    }

    
    func testFindUserWithInvalidId() async throws {
        let userDocId = "uu010"
        let user = try await manager.getUserWithDocId(id: userDocId)
        XCTAssertNil(user)
    }
}
