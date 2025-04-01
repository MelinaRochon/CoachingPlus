//
//  UserModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

/// **UserModel** manages user-related operations in the app.
///
/// ## Responsibilities:
/// - Creating a new user in the database.
/// - Retrieving authenticated user information.
/// - Fetching the user type (Coach, Player, etc.).
///
/// This class runs on the `@MainActor` to ensure UI-related updates are handled safely.
@MainActor
final class UserModel: ObservableObject {
    
    /// Creates a new user in the database.
    ///
    /// - Parameter userDTO: A `UserDTO` object containing user details.
    /// - Returns: A string representing the newly created user's ID.
    /// - Throws: An error if the user creation process fails.
    func addUser(userDTO: UserDTO) async throws -> String {
        return try await UserManager.shared.createNewUser(userDTO: userDTO)
    }
    
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Returns: A `DBUser` object representing the authenticated user, or `nil` if not found.
    /// - Throws: An error if authentication fails.
    func getUser() async throws -> DBUser? {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        return try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
    
    /// Retrieves the user type (e.g., "Coach" or "Player").
    ///
    /// - Returns: A `String` representing the user's role.
    /// - Throws: An error if the user data is unavailable.
    func getUserType() async throws -> String {
        return try await getUser()!.userType
    }
    
}
