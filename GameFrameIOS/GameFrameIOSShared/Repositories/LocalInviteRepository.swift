//
//  LocalInviteRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

public final class LocalInviteRepository: InviteRepository {
    
    private var invites: [DBInvite] = []
    private var teamInvites: [DBTeamInvite] = []
    
    public init(invites: [DBInvite]? = nil) {
        // If no teams provided, fallback to default JSON
        self.invites = invites ?? TestDataLoader.load("TestInvites", as: [DBInvite].self)
    }
    
    /// Creates a new invite document in the database.
    /// - Parameter inviteDTO: A data transfer object containing the invite details to be saved.
    /// - Returns: The Firestore document ID of the newly created invite.
    /// - Throws: An error if the creation fails.
    public func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
        // Generate a unique ID for the new invite
        let newId = UUID().uuidString
        
        let invite = DBInvite(id: newId, inviteDTO: inviteDTO)
        invites.append(invite)
        return newId
    }
    
    public func createNewTeamInvite(inviteDocId: String, teamInviteDTO: TeamInviteDTO) async throws -> String {
        // TODO: Add new team invite
        return ""
    }
    
    /// Retrieves an invite for a specific email and team combination.
    /// - Parameters:
    ///   - email: The email address of the invited player.
    ///   - teamId: The unique identifier of the team.
    /// - Returns: A `DBInvite` object if a matching invite exists, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    public func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> Invite? {
        guard let invite = invites.first(where: { $0.email == email }) else { return nil }
        guard let teamInvite = teamInvites.first(where: { $0.id == teamId }) else { return nil }
        
        // Search the invites array for a matching invite
        return Invite(invite: invite, teamInvite: teamInvite)
    }
    
    /// Retrieves an invite using the player’s document ID and the team document ID.
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamDocId: The Firestore document ID of the team.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    public func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> Invite? {
        // Search the invites array for a matching invite
        guard let invite = invites.first(where: { $0.playerDocId == playerDocId }) else { return nil }
        guard let teamInvite = teamInvites.first(where: { $0.id == teamDocId }) else { return nil }
        
        // Search the invites array for a matching invite
        return Invite(invite: invite, teamInvite: teamInvite)

    }
    
    /// Retrieves an invite by its document ID.
    /// - Parameter id: The Firestore document ID of the invite.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    public func getInvite(id: String) async throws -> DBInvite? {
        // Search the invites array for a matching document ID
        return invites.first { $0.id == id }
    }
    
    /// Updates the status of an existing invite.
    /// - Parameters:
    ///   - id: The Firestore document ID of the invite to update.
    ///   - newStatus: The new status string to set (e.g., "accepted", "declined").
    /// - Throws: An error if the update fails.
    public func updateInviteStatus(id: String, newStatus: UserAccountStatus) async throws {
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
    public func deleteInvite(id: String) async throws {
        // Find the index of the invite with the given ID
        guard let index = invites.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "InviteRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invite not found"])
        }
        
        // Remove the invite from the array
        invites.remove(at: index)
    }
    
    
    /// Finds an invite for a given user document ID and email.
    /// - Parameters:
    ///   - userDocId: The document ID of the user.
    ///   - email: The email address of the user.
    /// - Returns: The matching `DBInvite` if found, otherwise `nil`.
    public func findInviteWithUserDocIdAndEmail(userDocId: String, email: String) async throws -> DBInvite? {
        // Search the invites array for a matching invite
        return invites.first { $0.userDocId == userDocId && $0.email == email }
    }
    
    
    /// Checks if an invite exists for a given invite document ID and team ID.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team.
    /// - Returns: `true` if both the invite and the team invite exist, `false` otherwise.
    public func doesInviteByInviteDocIdAndTeamIdExist(inviteDocId: String, teamId: String) async throws -> Bool {
        let invite = try await getInvite(id: inviteDocId)
        let teamInvite = try await getTeamInvite(inviteDocId: inviteDocId, teamId: teamId)
        return invite != nil && teamInvite != nil
    }
    
    
    /// Retrieves the team-specific invite for a given invite document ID and team ID.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team.
    /// - Returns: The `DBTeamInvite` if found, otherwise `nil`.
    public func getTeamInvite(inviteDocId: String, teamId: String) async throws -> DBTeamInvite? {
        return teamInvites.first(where: { $0.id == teamId })
    }

    
    /// Checks if a team invite document exists for a given invite document ID and team ID.
    /// - Parameters:
    ///   - inviteDocId: The document ID of the invite.
    ///   - teamId: The ID of the team.
    /// - Returns: `true` if the team invite document exists, `false` otherwise.
    public func doesTeamInviteDocumentExist(inviteDocId: String, teamId: String) async throws -> Bool {
        guard let _ = teamInvites.first(where: { $0.id == teamId }) else {
            return false
        }
        return true
    }
    
    public func findInviteWithUserDocId(userDocId: String) async throws -> DBInvite? {
        return invites.first(where: { $0.userDocId == userDocId })

    }
        
    public func getAllTeamInvitesWithInviteDocId(inviteDocId: String) async throws -> [DBTeamInvite]? {
        return teamInvites.filter { $0.id == inviteDocId }
    }

    
    public func updateTeamInviteStatus(inviteDocId: String, teamId: String, status: InviteStatus) async throws {
        
        guard let index = teamInvites.firstIndex(where: { $0.id == teamId }) else {
            return
        }
        teamInvites[index].status = status
    }

    public func removeTeamInviteWithUserDocIdAndTeamId(inviteDocId: String, teamId: String) async throws {
        guard let index = teamInvites.firstIndex(where: { $0.id == teamId }) else {
            return
        }
        
        teamInvites.remove(at: index)
    }

    public func findInviteWithPlayerDocId(playerDocId: String) async throws -> DBInvite? {
        return invites.first(where: { $0.playerDocId == playerDocId })
    }
    
    public func getTeamInviteByPlayerDocIdAndTeamId(playerDocId: String, teamId: String) async throws -> DBTeamInvite? {
        return teamInvites.first(where: { $0.id == teamId })
    }
}
