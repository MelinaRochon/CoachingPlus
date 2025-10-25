//
//  LocalAuthenticationRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation
@testable import GameFrameIOS

final class LocalAuthenticationRepository: AuthenticationRepository {
    private var authUsers: [GameFrameIOS.DBAuthentication] = []
    
    init(authUsers: [DBAuthentication]? = nil) {
        // If no authentication user provided, fallback to default JSON
        self.authUsers = authUsers ?? TestDataLoader.load("TestAuthentications", as: [DBAuthentication].self)
    }
    func getAuthenticatedUser(id: String) throws -> GameFrameIOS.DBAuthentication? {
        return authUsers.first(where: { $0.id == id})
    }
    
    func createUser(email: String, password: String) async throws {
        let id = UUID().uuidString
        if email.contains("@") && password.count > 5 {
            let authUser = DBAuthentication(id: id, email: email, password: password)
            authUsers.append(authUser)
        }
    }
    
    func signOut(id: String) throws {
        if let index = authUsers.firstIndex(where: { $0.id == id }) {
            authUsers[index].isSignedIn = false
        }
    }
    
    func signInUser(email: String, password: String) async throws -> GameFrameIOS.DBAuthentication? {
        if let index = authUsers.firstIndex(where: { $0.email == email && $0.password == password }) {
            authUsers[index].isSignedIn = true
            return authUsers[index]
        }
        return nil
    }
    
    func resetPassword(email: String, newPwd: String) async throws {
        if newPwd.count > 5 {
            if let index = authUsers.firstIndex(where: { $0.email == email }) {
                authUsers[index].password = newPwd
            }
        }
    }
        
    func updateEmail(id: String, email: String) async throws {
        if email.contains("@") {
            if let index = authUsers.firstIndex(where: { $0.id == id }) {
                authUsers[index].email = email
            }
        }
    }
    
    func findUserWithEmail(email: String) async throws -> GameFrameIOS.DBAuthentication? {
        return authUsers.first(where: { $0.email == email })
    }
}
