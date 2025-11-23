//
//  InvitesPlayersManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation


/**
 A manager class responsible for handling operations related to invites.
 This class provides functionality to create, retrieve, and update invites in the Firestore database.
 - Singleton pattern: The `InviteManager` is a singleton to ensure only one instance is used throughout the app.
 */
public final class InviteManager {
    
    private let repo: InviteRepository
    
    public init(repo: InviteRepository) {
        self.repo = repo
    }
    
    /**
     Creates a new invite in the Firestore database.
     - Parameters:
        - inviteDTO: The `InviteDTO` containing the invite data.
     - Returns:
        A string representing the document ID of the newly created invite.
     - Throws: An error if the invite creation fails.
     */
    public func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
        return try await repo.createNewInvite(inviteDTO: inviteDTO)
    }
    
    public func createNewTeamInvite(inviteDocId: String, teamInviteDTO: TeamInviteDTO) async throws -> String {
        return try await repo.createNewTeamInvite(inviteDocId: inviteDocId, teamInviteDTO: teamInviteDTO)
    }
    
    
    /**
     Retrieves an invite from Firestore by email and team ID.
     - Parameters:
        - email: The email of the invited player.
        - teamId: The ID of the team the invite is for.
     - Returns:
        An optional `DBInvite` object if found, otherwise `nil`.
     - Throws: An error if the retrieval process fails.
     */
    public func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> Invite? {
        return try await repo.getInviteByEmailAndTeamId(email: email, teamId: teamId)
    }
    
    
    /**
     Retrieves an invite from Firestore by email and team ID.
     - Parameters:
        - email: The email of the invited player.
        - teamId: The ID of the team the invite is for.
     - Returns:
        An optional `DBInvite` object if found, otherwise `nil`.
     - Throws: An error if the retrieval process fails.
     */
    public func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> Invite? {
        return try await repo.getInviteByPlayerDocIdAndTeamId(playerDocId: playerDocId, teamDocId: teamDocId)
    }
    
    
    /**
     Retrieves an invite document from Firestore by invite ID.
     - Parameters:
        - id: The ID of the invite to retrieve.
     - Returns:
        An optional `DBInvite` object if found, otherwise `nil`.
     - Throws: An error if the retrieval process fails.
     */
    public func getInvite(id: String) async throws -> DBInvite? {
        return try await repo.getInvite(id: id)
    }
    

    /**
     Updates the status of an invite in Firestore.
     - Parameters:
        - id: The ID of the invite to update.
        - newStatus: The new status to set for the invite.
     - Throws: An error if the update process fails.
     */
    public func updateInviteStatus(id: String, newStatus: UserAccountStatus) async throws {
        try await repo.updateInviteStatus(id: id, newStatus: newStatus)
    }
    
    
    /// Deletes an invite in Firestore
    ///
    /// - Parameters:
    ///    - id: The ID of the invite to delete
    ///  - Throws: An error if the delete process fails
    public func deleteInvite(id: String) async throws {
        try await repo.deleteInvite(id: id)
    }
    
    
    /// Finds an invite using the user's document ID and email address.
    /// - Parameters:
    ///   - userDocId: The Firestore document ID of the user.
    ///   - email: The email address associated with the invite.
    /// - Returns: A `DBInvite` if found, otherwise `nil`.
    public func findInviteWithUserDocIdAndEmail(userDocId: String, email: String) async throws -> DBInvite? {
        return try await repo.findInviteWithUserDocIdAndEmail(userDocId: userDocId, email: email)
    }

    
    /// Checks if a specific invite exists for a team.
    /// - Parameters:
    ///   - inviteDocId: The invite document ID.
    ///   - teamId: The ID of the team to check against.
    /// - Returns: `true` if the invite exists, otherwise `false`.
    public func doesInviteByInviteDocIdAndTeamIdExist(inviteDocId: String, teamId: String) async throws -> Bool {
        return try await repo.doesInviteByInviteDocIdAndTeamIdExist(inviteDocId: inviteDocId, teamId: teamId)
    }
    
    
    /// Retrieves a team invite document if it exists.
    /// - Parameters:
    ///   - inviteDocId: The invite document ID.
    ///   - teamId: The ID of the team associated with the invite.
    /// - Returns: A `DBTeamInvite` object if found, otherwise `nil`.
    public func getTeamInvite(inviteDocId: String, teamId: String) async throws -> DBTeamInvite? {
        return try await repo.getTeamInvite(inviteDocId: inviteDocId, teamId: teamId)
    }
    
    
    /// Checks if a team invite document exists.
    /// - Parameters:
    ///   - inviteDocId: The invite document ID.
    ///   - teamId: The ID of the team to verify.
    /// - Returns: `true` if the team invite document exists, otherwise `false`.
    public func doesTeamInviteDocumentExist(inviteDocId: String, teamId: String) async throws -> Bool {
        return try await repo.doesTeamInviteDocumentExist(inviteDocId: inviteDocId, teamId: teamId)
    }
}
