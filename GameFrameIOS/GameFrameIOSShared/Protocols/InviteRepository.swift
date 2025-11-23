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
    
    func createNewTeamInvite(inviteDocId: String, teamInviteDTO: TeamInviteDTO) async throws -> String
    
    /// Retrieves an invite for a specific email and team combination.
    /// - Parameters:
    ///   - email: The email address of the invited player.
    ///   - teamId: The unique identifier of the team.
    /// - Returns: A `DBInvite` object if a matching invite exists, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> Invite?
    
    /// Retrieves an invite using the player’s document ID and the team document ID.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamDocId: The Firestore document ID of the team.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> Invite?
    
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
    func updateInviteStatus(id: String, newStatus: UserAccountStatus) async throws
    
    /// Deletes an invite from the database.
    /// - Parameter id: The Firestore document ID of the invite to delete.
    /// - Throws: An error if deletion fails.
    func deleteInvite(id: String) async throws
    
    /// Retrieves an invite using the userDocId and the user's email address
    /// - Parameters:
    ///   - userDocId: The ID of the user's document.
    ///   - email: The email address of the invited player.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func findInviteWithUserDocIdAndEmail(userDocId: String, email: String) async throws -> DBInvite?
    
    
    /// Checks if an invite exists for a specific team using the invite document ID.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team to check for.
    /// - Returns: `true` if an invite exists for the team, otherwise `false`.
    func doesInviteByInviteDocIdAndTeamIdExist(inviteDocId: String, teamId: String) async throws -> Bool
    
    
    /// Retrieves a specific team invite using the invite document ID and team ID.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team associated with the invite.
    /// - Returns: A `DBTeamInvite` object if found, otherwise `nil`.
    func getTeamInvite(inviteDocId: String, teamId: String) async throws -> DBTeamInvite?

    
    /// Checks if a team invite document exists in the database for a given invite and team.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team to check for.
    /// - Returns: `true` if the team invite document exists, otherwise `false`.
    func doesTeamInviteDocumentExist(inviteDocId: String, teamId: String) async throws -> Bool
}
