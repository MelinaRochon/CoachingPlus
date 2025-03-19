//
//  InvitesPlayersManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation
import FirebaseFirestore

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

struct InviteDTO {
    let userDocId: String
    let playerDocId: String
    let email: String
    let status: String
    let dateAccepted: Date?
    let teamId: String
}

final class InviteManager {
    static let shared = InviteManager()
    private init() {} // TO DO - Will need to use something else than singleton
    
    private let inviteCollection = Firestore.firestore().collection("invites") // invites collection
    
    private func inviteDocument(id: String) -> DocumentReference {
        inviteCollection.document(id)
    }
    /** Create a new invite in the database */
    func createNewInvite(inviteDTO: InviteDTO) async throws -> String {
        let inviteDocument = inviteCollection.document()
        let documentId = inviteDocument.documentID // get the document id
        
        // create an invite object
        let invite = DBInvite(id: documentId, inviteDTO: inviteDTO)
        try inviteDocument.setData(from: invite, merge: false)
        
        return documentId
    }
    
    /** GET - Returns the invite from the database with the email and the teamId */
    func getInviteByEmailAndTeamId(email: String, teamId: String) async throws -> DBInvite? {
        let query = try await inviteCollection.whereField("email", isEqualTo: email).whereField("team_id", isEqualTo: teamId).getDocuments()
       
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBInvite.self)
    }
    
    func getInvite(id: String) async throws -> DBInvite? {
        return try await inviteDocument(id: id).getDocument(as: DBInvite.self);
    }
    
    /** PUT - Update the invite status */
    func updateInviteStatus(id: String, newStatus: String) async throws {
        let data: [String: Any] = [
            DBInvite.CodingKeys.status.rawValue: newStatus
        ]
        
        try await inviteDocument(id: id).updateData(data as [AnyHashable : Any])
        
    }
}
