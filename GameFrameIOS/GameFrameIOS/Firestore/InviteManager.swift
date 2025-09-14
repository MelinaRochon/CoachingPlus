//
//  InvitesPlayersManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation
import FirebaseFirestore

/**
 A struct representing an invitation to join a team. Used for both storing and retrieving invite data from Firestore.

 - Properties:
    - `id`: The unique identifier of the invite.
    - `userDocId`: The ID of the user who sent the invite.
    - `playerDocId`: The ID of the player being invited.
    - `email`: The email of the invited player.
    - `status`: The current status of the invite (e.g., "pending", "accepted").
    - `dateInviteSent`: The date when the invite was sent.
    - `dateAccepted`: The date when the invite was accepted, or `nil` if not accepted.
    - `teamId`: The ID of the team to which the invite pertains.

 */
struct DBInvite: Codable {
    let id: String
    let userDocId: String
    let playerDocId: String
    let email: String
    let status: String
    let dateInviteSent: Date
    let dateAccepted: Date?
    let teamId: String
    
    init(id: String, userDocId: String, playerDocId: String, email: String, status: String, dateInviteSent: Date, dateAccepted: Date? = nil, teamId: String) {
        self.id = id
        self.userDocId = userDocId
        self.playerDocId = playerDocId
        self.email = email
        self.status = status
        self.dateInviteSent = dateInviteSent
        self.dateAccepted = dateAccepted
        self.teamId = teamId
    }
    
    init(id: String, inviteDTO: InviteDTO) {
        self.id = id
        self.userDocId = inviteDTO.userDocId
        self.playerDocId = inviteDTO.playerDocId
        self.email = inviteDTO.email
        self.status = inviteDTO.status
        self.dateInviteSent = Date()
        self.dateAccepted = inviteDTO.dateAccepted
        self.teamId = inviteDTO.teamId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userDocId = "user_doc_id"
        case playerDocId = "player_doc_id"
        case email = "email"
        case status = "status"
        case dateInviteSent = "date_invite_sent"
        case dateAccepted = "date_accepted"
        case teamId = "team_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userDocId = try container.decode(String.self, forKey: .userDocId)
        self.playerDocId = try container.decode(String.self, forKey: .playerDocId)
        self.email = try container.decode(String.self, forKey: .email)
        self.status = try container.decode(String.self, forKey: .status)
        self.dateInviteSent = try container.decode(Date.self, forKey: .dateInviteSent)
        self.dateAccepted = try container.decodeIfPresent(Date.self, forKey: .dateAccepted)
        self.teamId = try container.decode(String.self, forKey: .teamId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userDocId, forKey: .userDocId)
        try container.encode(self.playerDocId, forKey: .playerDocId)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.status, forKey: .status)
        try container.encode(self.dateInviteSent, forKey: .dateInviteSent)
        try container.encodeIfPresent(self.dateAccepted, forKey: .dateAccepted)
        try container.encode(self.teamId, forKey: .teamId)
    }
}


/**
 A manager class responsible for handling operations related to invites.
 This class provides functionality to create, retrieve, and update invites in the Firestore database.
 - Singleton pattern: The `InviteManager` is a singleton to ensure only one instance is used throughout the app.
 */
final class InviteManager {
    static let shared = InviteManager()
    private init() {} // TO DO - Will need to use something else than singleton
    
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
    func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
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
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
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
    func getInviteByPlayerDocIdAndTeamId(playerDocId: String, teamDocId: String) async throws -> DBInvite? {
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
    func getInvite(id: String) async throws -> DBInvite? {
        return try await inviteDocument(id: id).getDocument(as: DBInvite.self);
    }
    

    /**
     Updates the status of an invite in Firestore.
     - Parameters:
        - id: The ID of the invite to update.
        - newStatus: The new status to set for the invite.
     - Throws: An error if the update process fails.
     */
    func updateInviteStatus(id: String, newStatus: String) async throws {
        let data: [String: Any] = [
            DBInvite.CodingKeys.status.rawValue: newStatus
        ]
        
        try await inviteDocument(id: id).updateData(data as [AnyHashable : Any])
        
    }
}
