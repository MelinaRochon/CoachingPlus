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
    
    /// Creates a new team invite document in Firestore.
    ///
    /// This function forwards the request to `inviteManager.createNewTeamInvite`.
    /// If the invite cannot be created, it throws `InviteError.errorWhenCreatingTeamInvite`.
    ///
    /// - Parameters:
    ///   - inviteDocId: The Firestore document ID used to identify the invite.
    ///   - teamInviteDTO: The data needed to build the team invite document.
    /// - Returns: The document ID of the newly created team invite.
    /// - Throws: `InviteError.errorWhenCreatingTeamInvite` if the invite could not be created.
    func addTeamInvite(inviteDocId: String, teamInviteDTO: TeamInviteDTO) async throws -> String {
        guard let documentId = try await dependencies?.inviteManager.createNewTeamInvite(inviteDocId: inviteDocId, teamInviteDTO: teamInviteDTO) else {
            print("Error when creating team invite")
            throw InviteError.errorWhenCreatingTeamInvite
        }
        
        return documentId
    }
    
    /// Retrieves the current status of an invite for a given user.
    ///
    /// This function checks if an invite exists for the specified user document ID
    /// and email. If found, it returns the invite's `UserAccountStatus`.
    /// If no invite exists, it throws `.inviteNotFound`. If the invite has an
    /// invalid or `.unknown` status, it throws `.invalidStatus`.
    ///
    /// - Parameters:
    ///   - userDocId: The Firestore document ID of the user.
    ///   - email: The email address associated with the invite.
    /// - Returns: The `UserAccountStatus` of the invite.
    /// - Throws:
    ///   - `InviteError.inviteNotFound` if no invite exists for this user.
    ///   - `InviteError.invalidStatus` if the invite has an unknown status.
    func findInviteStatusUsingUserDocIdAndUserEmailAddress(userDocId: String, email: String) async throws -> UserAccountStatus {
        guard let inviteExist = try await dependencies?.inviteManager.findInviteWithUserDocIdAndEmail(userDocId: userDocId, email: email) else {
            // Invite was not found, meaning there's an error. Throw error to let the user know
            throw InviteError.inviteNotFound
        }
        
        guard inviteExist.status != .unknown else {
            throw InviteError.invalidStatus
        }
        
        return inviteExist.status
    }
    
    /// Checks whether a specific team invite document already exists for a player.
    ///
    /// This function verifies if the invite identified by `inviteDocId` is already
    /// associated with the given team. Useful for preventing duplicate invites.
    ///
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite to check.
    ///   - email: The email address associated with the invite (not used in this check but kept for context).
    ///   - teamId: The Firestore team ID to check against.
    /// - Returns: `true` if an invite document exists for this team; otherwise, `false`.
    /// - Throws: `InviteError.errorWhenCreatingTeamInvite` if dependencies are missing.
    func doesPlayerHaveInviteForThisTeam(inviteDocId: String, email: String, teamId: String) async throws -> Bool {
        guard let repo = dependencies else {
            print("dependencies do not work")
            // TODO: Throw error
            throw InviteError.errorWhenCreatingTeamInvite
        }
        let doesExist = try await repo.inviteManager.doesTeamInviteDocumentExist(inviteDocId: inviteDocId, teamId: teamId)
        return doesExist 
    }
    
    /// Finds an invite document associated with a specific user and email address.
    ///
    /// This method queries Firestore for an invite matching both the user's
    /// document ID and email. If the invite does not exist, it throws `.inviteNotFound`.
    ///
    /// - Parameters:
    ///   - userDocId: The Firestore document ID of the user.
    ///   - email: The email address associated with the invite.
    /// - Returns: The `DBInvite` model representing the invite.
    /// - Throws: `InviteError.inviteNotFound` if no invite matches the parameters.
    func findInviteUsingUserDocIdAndUserEmailAddress(userDocId: String, email: String) async throws -> DBInvite {
        guard let invite = try await dependencies?.inviteManager.findInviteWithUserDocIdAndEmail(userDocId: userDocId, email: email) else {
            // Invite was not found, meaning there's an error. Throw error to let the user know
            throw InviteError.inviteNotFound
        }
                        
        return invite
    }
}
