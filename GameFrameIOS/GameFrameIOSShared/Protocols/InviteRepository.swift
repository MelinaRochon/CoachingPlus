//
//  InviteRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

public protocol InviteRepository {
    
    /// Creates a new invite document in the database.
    /// - Parameter inviteDTO: A data transfer object containing the invite details to be saved.
    /// - Returns: The Firestore document ID of the newly created invite.
    /// - Throws: An error if the creation fails.
    func createNewInvite(inviteDTO: InviteDTO) async throws -> String
    
    /// Retrieves an invite for a specific email and team combination.
    /// - Parameters:
    ///   - email: The email address of the invited player.
    ///   - teamId: The unique identifier of the team.
    /// - Returns: A `DBInvite` object if a matching invite exists, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite?
    
    /// Retrieves an invite using the player’s document ID and the team document ID.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamDocId: The Firestore document ID of the team.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> DBInvite?
    
    /// Retrieves an invite by its document ID.
    /// - Parameter id: The Firestore document ID of the invite.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInvite(id: String) async throws -> DBInvite?
    
    /// Updates the status of an existing invite.
    /// - Parameters:
    ///   - id: The Firestore document ID of the invite to update.
    ///   - newStatus: The new status string to set (e.g., "accepted", "declined").
    /// - Throws: An error if the update fails.
    func updateInviteStatus(id: String, newStatus: String) async throws
    
    /// Deletes an invite from the database.
    /// - Parameter id: The Firestore document ID of the invite to delete.
    /// - Throws: An error if deletion fails.
    func deleteInvite(id: String) async throws
}
