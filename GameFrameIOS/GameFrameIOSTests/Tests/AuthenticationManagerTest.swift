//
//  AuthenticationManagerTest.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import XCTest
@testable import GameFrameIOSShared

final class AuthenticationManagerTest: XCTestCase {
    var manager: AuthenticationManager!
    var localRepo: LocalAuthenticationRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalAuthenticationRepository()
        manager = AuthenticationManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
    
    func testGetAuthenticatedUser() async throws {
        let email = "coach1@example.com"
        let pwd = "alicesmith"
        
        // Authenticate a user first
        let user = try await manager.signInUser(email: email, password: pwd)
        XCTAssertNotEqual(user.uid, "")
        
        let authUser = try manager.getAuthenticatedUser()
        XCTAssertNotNil(authUser)
        XCTAssertEqual(authUser.uid, user.uid)
    }
    
    func testAddNewUser() async throws {
        let email = "testing@gmail.com"
        let password = "pwd123456"
        
        // Make sure a user with these settings does not already exist
        let user = try await manager.createUser(email: email, password: password)
        XCTAssertEqual(user.email, email)
    }
    
    func testSignOutUser() async throws {
        let email = "coach1@example.com"
        let pwd = "alicesmith"
        
        // Sign in user before proceeding
        let user = try await manager.signInUser(email: email, password: pwd)
        if user.uid == "" {
            XCTFail()
            return
        }
        XCTAssertEqual(user.email, email)
        
        // Sign out user
        try manager.signOut()
        
        do {
            // Make sure user is signed out
            _ = try manager.getAuthenticatedUser()
        } catch AuthError.noAuthenticatedUser {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSignInUser() async throws {
        let email = "coach1@example.com"
        let pwd = "alicesmith"

        do {
            // Make sure user is signed out before proceeding
            _ = try manager.getAuthenticatedUser()
        } catch AuthError.noAuthenticatedUser {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Sign in user
        let user = try await manager.signInUser(email: email, password: pwd)
        XCTAssertEqual(user.email, email)
        
        // Make sure user is signed in
        let userSignedIn = try manager.getAuthenticatedUser()
        XCTAssertEqual(userSignedIn.uid, user.uid)
    }
            
    func testUpdateEmail() async throws {
        let email = "coach1@example.com"
        let newEmail = "coach1@admin.com"
        let pwd = "alicesmith"
        
        let signInUser = try await manager.signInUser(email: email, password: pwd)
        XCTAssertEqual(signInUser.email, email)
        
        // Sign in user before updating email address
        let tmpUser = try manager.getAuthenticatedUser()
        XCTAssertEqual(tmpUser.uid, signInUser.uid)
        XCTAssertEqual(tmpUser.email, email)
        
        // Change the email address
        try await manager.updateEmail(email: newEmail)
        let user = try manager.getAuthenticatedUser()
        XCTAssertEqual(user.uid, signInUser.uid)
        XCTAssertEqual(user.email, newEmail)
    }
    
    // MARK: Negative Tests
    
    func testGetInvalidAuthenticatedUser() async {
        // Try to see who's authenticated
        // Invalid because no user is autenticated at first so will return error
        do {
            _ = try manager.getAuthenticatedUser()
            XCTFail("Expected error not thrown")
        } catch AuthError.noAuthenticatedUser {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateUserWithInvalidEmail() async {
        let email = "testing"
        let password = "pwd123456"
        
        do {
            _ = try await manager.createUser(email: email, password: password)
            XCTFail("Expected error not thrown")
        } catch AuthError.invalidEmail {
            // Error catched
            print("AuthError.invalidEmail error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateUserWithInvalidPwd() async throws {
        let email = "testing@gmail.com"
        let password = "pwd"
                        
        do {
            _ = try await manager.createUser(email: email, password: password)
            XCTFail("Expected error not thrown")
        } catch AuthError.invalidPwd {
            // Error catch
            print("AuthError.invalidPwd error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSignInUserWithInvalidEmail() async throws {
        let invalidEmail = "testing"
        let password = "pwd123456"

        do {
            _ = try await manager.signInUser(email: invalidEmail, password: password)
            XCTFail("Expected error not thrown")
        } catch AuthError.invalidEmail {
            // Error catch
            print("AuthError.invalidEmail error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSignInUserWithInvalidPwd() async throws {
        let invalidPwd = "pwd"
        let email = "testing@gmail.com"
        
        do {
            _ = try await manager.signInUser(email: email, password: invalidPwd)
            XCTFail("Expected error not thrown")
        } catch AuthError.invalidPwd {
            // Error catch
            print("AuthError.invalidPwd error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSignInUserWithInvalidCredentials() async throws {
        let pwd = "pwd123456"
        let email = "testing@testing.com"
        
        do {
            _ = try await manager.signInUser(email: email, password: pwd)
            XCTFail("Expected error not thrown")
        } catch AuthError.userNotFound {
            // Error catch
            print("AuthError.userNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateEmailWithInvalidNewEmail() async {
        let newEmail = "coach1"
        let email = "coach1@example.com"
        let pwd = "alicesmith"

        // Change the email address
        do {
            // Sign in user first
            let user = try await manager.signInUser(email: email, password: pwd)
            XCTAssertEqual(user.email, email)
            
            // Try to update invalid email - should fail
            try await manager.updateEmail(email: newEmail)
            XCTFail("Expected error not thrown")
        } catch AuthError.invalidEmail {
            // Error catch
            print("AuthError.invalidEmail error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateEmailWithInvalidCredentials() async {
        let newEmail = "coach1@coach.com"
        
        // Change the email address
        do {
            try await manager.updateEmail(email: newEmail)
            XCTFail("Expected error not thrown")
        } catch AuthError.noAuthenticatedUser {
            // Error catch
            print("AuthError.userNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
