//
//  LocalAuthenticationRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

public final class LocalAuthenticationRepository: AuthenticationRepository {
    private var authUsers: [AuthDataResultModel] = []
    private var pwdUsers: [AuthPwd] = []
    
    public init(authUsers: [AuthDataResultModel]? = nil, pwdUsers: [AuthPwd]? = nil) {
        // If not authenticated user is provided, fallback to default JSON
        self.authUsers = authUsers ?? TestDataLoader.load("TestAuthDataResults", as: [AuthDataResultModel].self)
        // If not authenticated password is provided, fallback to default JSON
        self.pwdUsers = pwdUsers ?? TestDataLoader.load("TestAuthPwds", as: [AuthPwd].self)
    }
    
    public func getAuthenticatedUser() throws -> AuthDataResultModel {
        // Find the authenticated user associated
        guard let userAuthenticated = pwdUsers.first(where: { $0.isSignedIn }),
              let user = authUsers.first(where: { $0.uid == userAuthenticated.authUserId }) else {
            throw AuthError.noAuthenticatedUser
        }
        return user
    }
    
    public func getUser(id: String) throws -> AuthDataResultModel? {
        return authUsers.first(where: { $0.uid == id })
    }
    
    public func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        guard email.contains("@") else {
            throw AuthError.invalidEmail
        }
        
        guard password.count > 5 else {
            throw AuthError.invalidPwd
        }
        
        // Verification passed - Creating a new user
        let userId = UUID().uuidString
        let user = UserForDB(
            uid: userId,
            email: email,
            photoURL: nil
        )
        let authUser = AuthDataResultModel(user: user)
        // Add password to list of passwords
        let pwdUser = AuthPwd(id: UUID().uuidString, authUserId: userId, password: password, isSignedIn: true)
        pwdUsers.append(pwdUser)
        authUsers.append(authUser)
        return authUser
    }
    
    public func signOut() throws {
        let authenticatedUser = try getAuthenticatedUser()
        if authenticatedUser.uid == "" { return }
        if let index = pwdUsers.firstIndex(where: { $0.authUserId == authenticatedUser.uid }) {
            pwdUsers[index].isSignedIn = false
        }
    }
    
    public func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        guard email.contains("@") else {
            throw AuthError.invalidEmail
        }
        
        guard password.count > 5 else {
            throw AuthError.invalidPwd
        }
        
        // Find user
        guard let authUser = try await findUserWithEmail(email: email) else {
            print("Could not find user with email address given")
            throw AuthError.userNotFound
        }
        
        // Make sure password matches
        guard let pwdUserIdx = pwdUsers.firstIndex(where: { $0.authUserId == authUser.uid && $0.password == password }) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        pwdUsers[pwdUserIdx].isSignedIn = true
        return authUser
    }
    
    public func resetPassword(email: String) async throws {
        guard email.contains("@") else {
            throw AuthError.invalidEmail
        }
        // Find user
        guard let authUser = try await findUserWithEmail(email: email) else {
            print("Could not find user with email address given")
            throw AuthError.userNotFound
        }
        if let index = pwdUsers.firstIndex(where: { $0.authUserId == authUser.uid }) {
            pwdUsers[index].password = UUID().uuidString
        }
    }
    
    public func updatePassword(password: String) async throws {
        let authenticatedUser = try getAuthenticatedUser()
        if authenticatedUser.uid == "" { return }
        if password.count > 5 {
            if let index = pwdUsers.firstIndex(where: { $0.id == authenticatedUser.uid }) {
                pwdUsers[index].password = password
            }
        }
    }
    
    public func updateEmail(email: String) async throws {
        let authenticatedUser = try getAuthenticatedUser()
        
        // Validate the new email
        guard email.contains("@") else {
            throw AuthError.invalidEmail
        }

        // Find the authenticated user in the list
        guard let index = authUsers.firstIndex(where: { $0.uid == authenticatedUser.uid }) else {
            throw AuthError.userNotFound
        }
        
        authUsers[index].email = email
    }
    
    public func findUserWithEmail(email: String) async throws -> AuthDataResultModel? {
        return authUsers.first(where: { $0.email == email })
    }
}

