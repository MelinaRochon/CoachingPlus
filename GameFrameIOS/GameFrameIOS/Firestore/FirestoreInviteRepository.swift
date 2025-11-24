//
//  FirestoreInviteRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreInviteRepository: InviteRepository {
    
    /** The Firestore collection that stores invite documents */
    private let inviteCollection = Firestore.firestore().collection("invites") // invites collection
    
    private func teamInviteCollection(inviteDocId: String) -> CollectionReference {
        inviteDocument(id: inviteDocId).collection("teamInvites")
    }
    
    private func teamInviteDocument(inviteDocId: String, teamId: String) -> DocumentReference {
        teamInviteCollection(inviteDocId: inviteDocId).document(teamId)
    }
    
    public func doesTeamInviteDocumentExist(inviteDocId: String, teamId: String) async throws -> Bool {
        let ref = teamInviteCollection(inviteDocId: inviteDocId).document(teamId)
        let snapshot = try await ref.getDocument()
        return snapshot.exists
    }
        
    /**
    Returns a reference to a specific invite document in Firestore.
    - Parameters:
       - id: The ID of the invite document.
    - Returns:
       A `DocumentReference` pointing to the specified invite document.
    */
    private func inviteDocument(id: String) -> DocumentReference {
        inviteCollection.document(id)
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
        let inviteDocument = inviteCollection.document()
        let documentId = inviteDocument.documentID // get the document id
        
        // create an invite object
        let invite = DBInvite(id: documentId, inviteDTO: inviteDTO)
        try inviteDocument.setData(from: invite, merge: false)
        
        return documentId
    }
    
    public func createNewTeamInvite(inviteDocId: String, teamInviteDTO: TeamInviteDTO) async throws -> String {
//        let ref = teamInviteCollection(inviteDocId: inviteDocId).document(teamInviteDTO.teamId)
        let ref = teamInviteDocument(inviteDocId: inviteDocId, teamId: teamInviteDTO.teamId)
        let snap = try await ref.getDocument()
        
        let teamInvite = DBTeamInvite(teamInviteDTO: teamInviteDTO)
        try ref.setData(from: teamInvite, merge: true)
        print("creating a new team invite is working")
        return teamInviteDTO.teamId
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
//    public func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
//        let query = try await inviteCollection.whereField("email", isEqualTo: email).whereField("team_id", isEqualTo: teamId).getDocuments()
//       
//        guard let doc = query.documents.first else { return nil }
//        return try doc.data(as: DBInvite.self)
//    }
    
    public func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> Invite? {
        let query = try await inviteCollection.whereField("email", isEqualTo: email).getDocuments()
        guard let doc = query.documents.first else { return nil }
        let invite = try doc.data(as: DBInvite.self)
        
        let inviteDocId = doc.documentID
        let teamInvite = teamInviteDocument(inviteDocId: inviteDocId, teamId: teamId)
        
        let document = try await teamInvite.getDocument(as: DBTeamInvite.self)

        return Invite(invite: invite,teamInvite: document)
    }
    
    /// Checks whether a team invite exists for the given invite document and team.
    /// - Returns: `true` if the invite document exists for this team, otherwise `false`.
    public func doesInviteByInviteDocIdAndTeamIdExist(inviteDocId: String, teamId: String) async throws -> Bool {
        guard let _ = try await getTeamInvite(inviteDocId: inviteDocId, teamId: teamId) else {
            // No invite exists for this team
            return false
        }
        return true
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
        let query = try await inviteCollection.whereField("player_doc_id", isEqualTo: playerDocId).getDocuments()
        guard let doc = query.documents.first else { return nil }
        let invite = try doc.data(as: DBInvite.self)
        
        let inviteDocId = doc.documentID
        let teamInvite = teamInviteDocument(inviteDocId: inviteDocId, teamId: teamDocId)
        
        let document = try await teamInvite.getDocument(as: DBTeamInvite.self)

        return Invite(invite: invite,teamInvite: document)
    }
    
    
    /// Retrieves a team invite for a specific player and team.
    ///
    /// - Parameters:
    ///   - playerDocId: The Firestore document ID of the player.
    ///   - teamId: The Firestore document ID of the team.
    /// - Returns: A `DBTeamInvite` object if found, otherwise `nil`.
    /// - Throws: Errors from Firestore operations or data decoding.
    public func getTeamInviteByPlayerDocIdAndTeamId(playerDocId: String, teamId: String) async throws -> DBTeamInvite? {
        let query = try await inviteCollection.whereField("player_doc_id", isEqualTo: playerDocId).getDocuments()
        guard let doc = query.documents.first else { return nil }
        
        let inviteDocId = doc.documentID
        let teamInvite = teamInviteDocument(inviteDocId: inviteDocId, teamId: teamId)
        
        let document = try await teamInvite.getDocument(as: DBTeamInvite.self)

        return document
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
        return try await inviteDocument(id: id).getDocument(as: DBInvite.self);
    }
    
    public func getTeamInvite(inviteDocId: String, teamId: String) async throws -> DBTeamInvite? {
        let teamInvite = teamInviteDocument(inviteDocId: inviteDocId, teamId: teamId)
        print("team invire doc: \(teamInvite.description)")
        return try await teamInvite.getDocument(as: DBTeamInvite.self)
    }
    

    /**
     Updates the status of an invite in Firestore.
     - Parameters:
        - id: The ID of the invite to update.
        - newStatus: The new status to set for the invite.
     - Throws: An error if the update process fails.
     */
    public func updateInviteStatus(id: String, newStatus: UserAccountStatus) async throws {
        let data: [String: Any] = [
            DBInvite.CodingKeys.status.rawValue: newStatus.rawValue
        ]
        
        try await inviteDocument(id: id).updateData(data as [AnyHashable : Any])
        
    }
    
    
    /// Deletes an invite in Firestore
    ///
    /// - Parameters:
    ///    - id: The ID of the invite to delete
    ///  - Throws: An error if the delete process fails
    public func deleteInvite(id: String) async throws {
        try await inviteDocument(id: id).delete()
    }
    
    
    public func findInviteWithUserDocIdAndEmail(userDocId: String, email: String) async throws -> DBInvite? {
        let query = try await inviteCollection
            .whereField("email", isEqualTo: email)
            .whereField("user_doc_id", isEqualTo: userDocId)
            .getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)
    }
    
    public func findInviteWithUserDocId(userDocId: String) async throws -> DBInvite? {
        let query = try await inviteCollection
            .whereField("user_doc_id", isEqualTo: userDocId)
            .getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)
    }
    
    
    /// Fetches all pending team invites for a given invite document.
    ///
    /// - Parameter inviteDocId: The ID of the invite document.
    /// - Returns: An array of `DBTeamInvite` objects with status "Pending", or `nil` if none found.
    /// - Throws: Errors from Firestore operations or data decoding.
    public func getAllTeamInvitesWithInviteDocId(inviteDocId: String) async throws -> [DBTeamInvite]? {
        let snapshot = try await teamInviteCollection(inviteDocId: inviteDocId).whereField("status", isEqualTo: "Pending").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBTeamInvite.self)
        }
    }
    
    
    /// Retrieves the main invite document for a specific player.
    ///
    /// - Parameter playerDocId: The Firestore document ID of the player.
    /// - Returns: A `DBInvite` object if found, otherwise `nil`.
    /// - Throws: Errors from Firestore operations or data decoding.
    public func findInviteWithPlayerDocId(playerDocId: String) async throws -> DBInvite? {
        let query = try await inviteCollection
            .whereField("player_doc_id", isEqualTo: playerDocId)
            .getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)

    }

    
    /// Updates the status of a team invite.
    ///
    /// - Parameters:
    ///   - inviteDocId: The ID of the invite document.
    ///   - teamId: The ID of the team document.
    ///   - status: The new `InviteStatus` to set.
    /// - Throws: Errors from Firestore update operations.
    public func updateTeamInviteStatus(inviteDocId: String, teamId: String, status: InviteStatus) async throws {
        
        let data: [String: Any] = [
            DBTeamInvite.CodingKeys.status.rawValue: status.rawValue
        ]
        
        try await teamInviteDocument(inviteDocId: inviteDocId, teamId: teamId).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Deletes a team invite for a specific user and team.
    ///
    /// - Parameters:
    ///   - inviteDocId: The ID of the invite document.
    ///   - teamId: The ID of the team document.
    /// - Throws: Errors from Firestore delete operations.
    public func removeTeamInviteWithUserDocIdAndTeamId(inviteDocId: String, teamId: String) async throws {
        try await teamInviteDocument(inviteDocId: inviteDocId, teamId: teamId).delete()
    }
}
