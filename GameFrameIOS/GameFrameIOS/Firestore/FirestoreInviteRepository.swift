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
    
    
    /**
     Retrieves an invite from Firestore by email and team ID.
     - Parameters:
        - email: The email of the invited player.
        - teamId: The ID of the team the invite is for.
     - Returns:
        An optional `DBInvite` object if found, otherwise `nil`.
     - Throws: An error if the retrieval process fails.
     */
    public func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
        let query = try await inviteCollection.whereField("email", isEqualTo: email).whereField("team_id", isEqualTo: teamId).getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)
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
    public func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> DBInvite? {
        let query = try await inviteCollection
            .whereField("player_doc_id", isEqualTo: playerDocId)
            .whereField("team_id", isEqualTo: teamDocId)
            .getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)
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
    

    /**
     Updates the status of an invite in Firestore.
     - Parameters:
        - id: The ID of the invite to update.
        - newStatus: The new status to set for the invite.
     - Throws: An error if the update process fails.
     */
    public func updateInviteStatus(id: String, newStatus: String) async throws {
        let data: [String: Any] = [
            DBInvite.CodingKeys.status.rawValue: newStatus
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
}
