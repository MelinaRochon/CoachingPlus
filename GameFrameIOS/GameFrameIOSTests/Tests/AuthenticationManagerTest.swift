//
//  AuthenticationManagerTest.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import XCTest
@testable import GameFrameIOS

final class AuthenticationManagerTest: XCTestCase {
    var repo: LocalAuthenticationRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        repo = LocalAuthenticationRepository()
    }

    override func tearDownWithError() throws {
        repo = nil
        try super.tearDownWithError()
    }
    
    func testGetAuthenticatedUser() throws {
        let authId = "auth002"
        
        let authUser = try repo.getAuthenticatedUser(id: authId)
        XCTAssertNotNil(authUser)
        XCTAssertEqual(authUser?.id, authId)
    }
    
    func testAddNewUser() async throws {
        let email = "testing@gmail.com"
        let password = "pwd123456"
        
        // Make sure a user with these settings does not already exist
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNil(tmpUser)
        
        try await repo.createUser(email: email, password: password)
        let authUser = try await repo.findUserWithEmail(email: email)
        
        XCTAssertNotNil(authUser)
        XCTAssertEqual(authUser?.email, email)
        XCTAssertEqual(authUser?.password, password)
    }
    
    func testSignOutUser() async throws {
        let email = "coach1@example.com"
        let pwd = "alicesmith"
        
        // Sign in user before proceeding
        guard let user = try await repo.signInUser(email: email, password: pwd) else {
            XCTFail()
            return
        }
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.password, pwd)
        XCTAssertTrue(user.isSignedIn)
        
        // Sign out user
        try repo.signOut(id: user.id)
        
        // Make sure user is signed out
        let userAfterSignOut = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(userAfterSignOut)
        XCTAssertEqual(userAfterSignOut?.email, email)
        XCTAssertFalse(userAfterSignOut?.isSignedIn ?? true)
    }
    
    func testSignInUser() async throws {
        let id = "auth001"
        
        // Make sure user is signed out before proceeding
        guard let authUser = try repo.getAuthenticatedUser(id: id) else {
            XCTFail()
            return
        }
        XCTAssertEqual(authUser.id, id)
        XCTAssertFalse(authUser.isSignedIn)
        
        // Sign in user
        let user = try await repo.signInUser(email: authUser.email, password: authUser.password)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, id)
        XCTAssertEqual(user?.email, authUser.email)
        XCTAssertEqual(user?.password, authUser.password)
        XCTAssertTrue(user?.isSignedIn ?? false)
    }
    
    func testResetPassword() async throws {
        let email = "coach1@example.com"
        let newPwd = "newPassword123"

        // Make sure user exists before reseting password
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.email, email)
        
        // Make sure the current password does not match the new one
        XCTAssertNotEqual(tmpUser?.password, newPwd)
        
        // Reset password
        try await repo.resetPassword(email: email, newPwd: newPwd)
        
        // Make sure new password was saved
        let user = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, email)
        XCTAssertEqual(user?.password, newPwd)
    }
        
    func testUpdateEmail() async throws {
        let id = "auth001"
        let newEmail = "coach1@admin.com"

        // Make sure user exists before reseting password
        let tmpUser = try repo.getAuthenticatedUser(id: id)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.id, id)
        XCTAssertNotEqual(tmpUser?.email, newEmail)
        
        // Change the email address
        try await repo.updateEmail(id: id, email: newEmail)
        let user = try repo.getAuthenticatedUser(id: id)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, id)
        XCTAssertEqual(user?.email, newEmail)
    }
    
    func testFindUserWithEmail() async throws {
        let email = "coach1@example.com"
        
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.email, email)
    }
    
    // MARK: Negative Tests
    
    func testGetInvalidAuthenticatedUser() async throws {
        let authId = "auth111"
        
        let authUser = try repo.getAuthenticatedUser(id: authId)
        XCTAssertNil(authUser)
    }
    
    func testCreateUserWithInvalidEmail() async throws {
        let email = "testing"
        let password = "pwd123456"
        
        // Make sure a user with these settings does not already exist
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNil(tmpUser)
        
        try await repo.createUser(email: email, password: password)
        let authUser = try await repo.findUserWithEmail(email: email)
        
        XCTAssertNil(authUser)
    }
    
    func testCreateUserWithInvalidPwd() async throws {
        let email = "testing@gmail.com"
        let password = "pwd"
        
        // Make sure a user with these settings does not already exist
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNil(tmpUser)
        
        try await repo.createUser(email: email, password: password)
        let authUser = try await repo.findUserWithEmail(email: email)
        
        XCTAssertNil(authUser)
    }
    
    
    func testSignInUserWithInvalidEmail() async throws {
        let id = "auth001"
        let invalidEmail = "testing"
        
        // Make sure user is signed out before proceeding
        guard let authUser = try repo.getAuthenticatedUser(id: id) else {
            XCTFail()
            return
        }
        XCTAssertEqual(authUser.id, id)
        XCTAssertFalse(authUser.isSignedIn)
        
        // Sign in user
        let user = try await repo.signInUser(email: invalidEmail, password: authUser.password)
        XCTAssertNil(user)
    }

    func testSignInUserWithInvalidPwd() async throws {
        let id = "auth001"
        let invalidPwd = "pwd"
        
        // Make sure user is signed out before proceeding
        guard let authUser = try repo.getAuthenticatedUser(id: id) else {
            XCTFail()
            return
        }
        XCTAssertEqual(authUser.id, id)
        XCTAssertFalse(authUser.isSignedIn)
        
        // Sign in user
        let user = try await repo.signInUser(email: authUser.email, password: invalidPwd)
        XCTAssertNil(user)
    }
    
    func testResetPasswordWithInvalidEmail() async throws {
        let email = "coach1"
        let newPwd = "newPassword123"
        
        // Reset password
        try await repo.resetPassword(email: email, newPwd: newPwd)
        
        // Make sure new password was saved
        let user = try await repo.findUserWithEmail(email: email)
        XCTAssertNil(user)
    }
    
    func testResetPasswordWithInvalidNewPwd() async throws {
        let email = "coach1@example.com"
        let newPwd = "pwd"

        // Make sure user exists before reseting password
        let tmpUser = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.email, email)
        
        // Make sure the current password does not match the new one
        XCTAssertNotEqual(tmpUser?.password, newPwd)
        
        // Reset password
        try await repo.resetPassword(email: email, newPwd: newPwd)
        
        // Make sure new password was saved
        let user = try await repo.findUserWithEmail(email: email)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.email, email)
        XCTAssertNotEqual(user?.password, newPwd) // should not have changed
        XCTAssertEqual(user?.password, tmpUser?.password)
    }

    func testUpdateEmailWithInvalidId() async throws {
        let id = "auth111"
        let newEmail = "coach1@admin.com"

        // Change the email address
        try await repo.updateEmail(id: id, email: newEmail)
        let user = try repo.getAuthenticatedUser(id: id)
        XCTAssertNil(user)
    }

    func testUpdateEmailWithInvalidNewEmail() async throws {
        let id = "auth001"
        let newEmail = "coach1"

        // Make sure user exists before reseting password
        let tmpUser = try repo.getAuthenticatedUser(id: id)
        XCTAssertNotNil(tmpUser)
        XCTAssertEqual(tmpUser?.id, id)
        XCTAssertNotEqual(tmpUser?.email, newEmail)
        
        // Change the email address
        try await repo.updateEmail(id: id, email: newEmail)
        let user = try repo.getAuthenticatedUser(id: id)
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, id)
        XCTAssertNotEqual(user?.email, newEmail)
        XCTAssertEqual(user?.email, tmpUser?.email)
    }
}
