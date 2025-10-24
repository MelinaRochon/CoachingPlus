//
//  LocalInviteRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
@testable import GameFrameIOS

final class LocalInviteRepository: InviteRepository {
    private var invites: [DBInvite] = []
    
    init(invites: [DBInvite]? = nil) {
        // If no teams provided, fallback to default JSON
        self.invites = invites ?? TestDataLoader.load("TestInvites", as: [DBInvite].self)
    }
    
    /// Creates a new invite document in the database.
    /// - Parameter inviteDTO: A data transfer object containing the invite details to be saved.
    /// - Returns: The Firestore document ID of the newly created invite.
    /// - Throws: An error if the creation fails.
    func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
        // Generate a unique ID for the new invite
        let newId = UUID().uuidString
        
        let invite = DBInvite(id: newId, inviteDTO: inviteDTO)
        invites.append(invite)
        return newId
    }
    
    /// Retrieves an invite for a specific email and team combination.
    /// - Parameters:
    ///   - email: The email address of the invited player.
    ///   - teamId: The unique identifier of the team.
    /// - Returns: A `DBInvite` object if a matching invite exists, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
        // Search the invites array for a matching invite
        return invites.first { $0.email == email && $0.teamId == teamId }
    }
    
    /// Retrieves an invite using the player’s document ID and the team document ID.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamDocId: The Firestore document ID of the team.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> DBInvite? {
        // Search the invites array for a matching invite
        return invites.first { $0.playerDocId == playerDocId }
    }
    
    /// Retrieves an invite by its document ID.
    /// - Parameter id: The Firestore document ID of the invite.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getInvite(id: String) async throws -> DBInvite? {
        // Search the invites array for a matching document ID
        return invites.first { $0.id == id }
    }
    
    /// Updates the status of an existing invite.
    /// - Parameters:
    ///   - id: The Firestore document ID of the invite to update.
    ///   - newStatus: The new status string to set (e.g., "accepted", "declined").
    /// - Throws: An error if the update fails.
    func updateInviteStatus(id: String, newStatus: String) async throws {
        // Find the index of the invite with the given ID
        guard let index = invites.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "InviteRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invite not found"])
        }
        
        // Update the status of the found invite
        invites[index].status = newStatus
    }
    
    /// Deletes an invite from the database.
    /// - Parameter id: The Firestore document ID of the invite to delete.
    /// - Throws: An error if deletion fails.
    func deleteInvite(id: String) async throws {
        // Find the index of the invite with the given ID
        guard let index = invites.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "InviteRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invite not found"])
        }
        
        // Remove the invite from the array
        invites.remove(at: index)
    }
}
