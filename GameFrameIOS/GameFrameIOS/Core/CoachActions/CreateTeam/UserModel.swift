//
//  UserModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation
import GameFrameIOSShared

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
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    /// Creates a new user in the database.
    ///
    /// - Parameter userDTO: A `UserDTO` object containing user details.
    /// - Returns: A string representing the newly created user's ID.
    /// - Throws: An error if the user creation process fails.
    func addUser(userDTO: UserDTO) async throws -> String {
        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            throw NSError(domain: "UserModel", code: 1, userInfo: nil)
        }

        return try await repo.userManager.createNewUser(userDTO: userDTO)
    }
    
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Returns: A `DBUser` object representing the authenticated user, or `nil` if not found.
    /// - Throws: An error if authentication fails.
    func getUser() async throws -> DBUser? {
        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return nil
        }

        let authUser = try repo.authenticationManager.getAuthenticatedUser()
        
        return try await repo.userManager.getUser(userId: authUser.uid)
    }
    
        
    /// Updates the settings of a specific user by delegating the task to the `UserManager`.
    /// - Parameters:
    ///   - id: The unique identifier of the user whose settings need to be updated.
    ///   - dateOfBirth: Optional updated date of birth for the user.
    ///   - firstName: Optional updated first name for the user.
    ///   - lastName: Optional updated last name for the user.
    ///   - phone: Optional updated phone number for the user.
    /// - Throws: An error if the update operation fails.
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        try await dependencies?.userManager.updateUserSettings(id: id, dateOfBirth: dateOfBirth, firstName: firstName, lastName: lastName, phone: phone)
    }
    
    
    /// Finds and returns a user document based on an email address.
    ///
    /// - Parameter email: The email address to search for in the database.
    /// - Returns: A `DBUser` if one exists with the provided email, or `nil` if no matching user is found.
    /// - Throws: An error if the underlying repository call fails.
    /// - Note: This method does *not* throw when the user doesn't exist; it simply returns `nil`.
    func findUserWithEmail(email: String) async throws -> DBUser? {
        return try await dependencies?.userManager.getUserWithEmail(email: email)
    }
}
