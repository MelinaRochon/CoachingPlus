//
//  InviteModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

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
    
    /// Creates a new invitation and stores it in the database.
    ///
    /// - Parameter inviteDTO: An `InviteDTO` object containing the details of the invitation.
    /// - Returns: The unique identifier of the newly created invitation.
    /// - Throws: An error if the invitation could not be created.
    func addInvite(inviteDTO: InviteDTO) async throws -> String {
        // Calls the `InviteManager` to create a new invitation and return its ID.
        return try await InviteManager.shared.createNewInvite(inviteDTO: inviteDTO)
    }
}
