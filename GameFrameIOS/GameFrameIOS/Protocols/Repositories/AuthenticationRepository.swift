//
//  AuthenticationRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

protocol AuthenticationRepository {
    func getAuthenticatedUser(id: String) throws -> DBAuthentication?
    func createUser(email: String, password: String) async throws
    func signOut(id: String) throws
    func signInUser(email: String, password: String) async throws -> DBAuthentication?
    func resetPassword(email: String, newPwd: String) async throws
    func updateEmail(id: String, email: String) async throws
    func findUserWithEmail(email: String) async throws -> DBAuthentication?
}
