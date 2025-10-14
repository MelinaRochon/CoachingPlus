//
//  InvitesPlayersManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation
import FirebaseFirestore


/**
 A manager class responsible for handling operations related to invites.
 This class provides functionality to create, retrieve, and update invites in the Firestore database.
 - Singleton pattern: The `InviteManager` is a singleton to ensure only one instance is used throughout the app.
 */
final class InviteManager {
    private let repo: InviteRepository
    
    init(repo: InviteRepository = FirestoreInviteRepository()) {
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
    func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
        return try await repo.createNewInvite(inviteDTO: inviteDTO)
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
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
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
    func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> DBInvite? {
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
    func getInvite(id: String) async throws -> DBInvite? {
        return try await repo.getInvite(id: id)
    }
    

    /**
     Updates the status of an invite in Firestore.
     - Parameters:
        - id: The ID of the invite to update.
        - newStatus: The new status to set for the invite.
     - Throws: An error if the update process fails.
     */
    func updateInviteStatus(id: String, newStatus: String) async throws {
        try await repo.updateInviteStatus(id: id, newStatus: newStatus)
    }
    
    
    /// Deletes an invite in Firestore
    ///
    /// - Parameters:
    ///    - id: The ID of the invite to delete
    ///  - Throws: An error if the delete process fails
    func deleteInvite(id: String) async throws {
        try await repo.deleteInvite(id: id)
    }
}
