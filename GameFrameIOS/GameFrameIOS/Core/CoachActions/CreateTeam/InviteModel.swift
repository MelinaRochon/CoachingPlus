//
//  InviteModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation
import GameFrameIOSShared

/// **InviteModel** is responsible for handling invitation-related operations.
///
/// ## Responsibilities:
/// - Creating a new team or player invitation.
/// - Interacting with `InviteManager` to manage invitation storage.
///
/// This class ensures that all invitation operations are executed on the main actor
/// to prevent UI-related concurrency issues.
@MainActor
final class InviteModel: ObservableObject {
    
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

    /// Creates a new invitation and stores it in the database.
    ///
    /// - Parameter inviteDTO: An `InviteDTO` object containing the details of the invitation.
    /// - Returns: The unique identifier of the newly created invitation.
    /// - Throws: An error if the invitation could not be created.
    func addInvite(inviteDTO: InviteDTO) async throws -> String {
        guard let repo = dependencies?.inviteManager else {
            throw NSError(domain: "InviteModel", code: 1, userInfo: [NSLocalizedDescriptionKey : "Dependency not set"])
        }
        // Calls the `InviteManager` to create a new invitation and return its ID.
        return try await repo.createNewInvite(inviteDTO: inviteDTO)
    }
}
