//
//  CoachManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation
import FirebaseFirestore


struct DBCoach: Codable {
    let id: String
    let coachId: String
    let teamsCoaching: [String]?
    
    init(id: String, coachId: String, teamsCoaching: [String]? = nil) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = teamsCoaching
    }
    
    init(id: String, coachId: String) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = []
    }
    
    init(id: String, coachDTO: CoachDTO) {
        self.id = id
        self.coachId = coachDTO.coachId
        self.teamsCoaching = coachDTO.teamsCoaching
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.coachId = try container.decode(String.self, forKey: .coachId)
        self.teamsCoaching = try container.decodeIfPresent([String].self, forKey: .teamsCoaching)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case coachId = "coach_id"
        case teamsCoaching = "teams_coaching"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.coachId, forKey: .coachId)
        try container.encodeIfPresent(self.teamsCoaching, forKey: .teamsCoaching)
    }
}

final class CoachManager {
    static let shared = CoachManager()
    
    private init() {} // TO DO - Will need to use something else than singleton
    
    /** Returns the coach collection */
    private let coachCollection = Firestore.firestore().collection("coaches")
    
    /** Returns a specific coach document */
    private func coachDocument(coachId: String) -> DocumentReference {
        coachCollection.document(coachId)
    }
    
    /** POST - Add a new coach in the database */
    func addCoach(coachId: String) async throws {
        let coachDoc = coachCollection.document()
        let documentId = coachDoc.documentID
        
        let coach = DBCoach(id: documentId, coachId: coachId)
        try coachDoc.setData(from: coach, merge: false)
    }
    
    /** GET - Returns the coach document from the database using the coach id */
    func getCoachDocumentWithCoachId(coachId: String) async throws -> QuerySnapshot {
        return try await coachCollection.whereField("coach_id", isEqualTo: coachId).getDocuments()
    }
    
    /** GET - Returns the coach's information from the database */
    func getCoach(coachId: String) async throws -> DBCoach? {
        guard let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first else { return nil }
        return try doc.data(as: DBCoach.self)
    }
    
    /** PUT - Add a new team id in the teamsCoaching array */
    func addTeamToCoach(coachId: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBCoach.CodingKeys.teamsCoaching.rawValue: FieldValue.arrayUnion([teamId])
        ]
        // TO DO - Make sure the teamId that we are adding isn't already in the database
        
        // Update the document asynchronously
        if let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first {
            try await doc.reference.updateData(data as [AnyHashable : Any])// Assuming you have a `Coach` model
        } else {
            print("No coach found with that ID.")
        }
    }
    
    /** DELETE - Remove a team id in the teamsCoaching array */
    func removeTeamToCoach(coachId: String, teamId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBCoach.CodingKeys.teamsCoaching.rawValue: FieldValue.arrayRemove([teamId])
        ]
        
        // Update the document asynchronously
        if let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first {
            try await doc.reference.updateData(data as [AnyHashable : Any])// Assuming you have a `Coach` model
        } else {
            print("No coach found with that ID.")
        }
    }
    
    /** GET - Returns all the teams that the coach is coaching from the database */
    func loadTeamsCoaching(coachId: String) async throws -> [GetTeam] {
        
        let coach = try await getCoach(coachId: coachId)!
        
        // Fetch the team documents with the IDs from the user's itemsArray
        let snapshot = try await TeamManager.shared.teamCollection.whereField("team_id", in: coach.teamsCoaching ?? []).getDocuments()
        // Map the documents to Team objects and get their names
        var teams: [GetTeam] = []
        for document in snapshot.documents {
            if let team = try? document.data(as: DBTeam.self) {
                // Add a Team object with the teamId and team name
                let teamObject = GetTeam(teamId: team.teamId, name: team.name, nickname: team.teamNickname)
                teams.append(teamObject)
            }
        }
            
        return teams
    }
}
