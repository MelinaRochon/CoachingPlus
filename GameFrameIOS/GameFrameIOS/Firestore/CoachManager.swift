//
//  CoachManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation
import FirebaseFirestore


struct DBCoach: Codable {
    let coachId: String
    let teamsCoaching: [String]?
    
    init(coachId: String, teamsCoaching: [String]? = nil) {
        self.coachId = coachId
        self.teamsCoaching = teamsCoaching
    }
    
    init(coachId: String) {
        self.coachId = coachId
        self.teamsCoaching = []
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coachId = try container.decode(String.self, forKey: .coachId)
        self.teamsCoaching = try container.decodeIfPresent([String].self, forKey: .teamsCoaching)
    }
    
    enum CodingKeys: String, CodingKey {
        case coachId = "coach_id"
        case teamsCoaching = "teams_coaching"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coachId, forKey: .coachId)
        try container.encodeIfPresent(self.teamsCoaching, forKey: .teamsCoaching)
    }
}

final class CoachManager {
    static let shared = CoachManager()
    
    private init() {} // TO DO - Will need to use something else than singleton
    
    private let coachCollection = Firestore.firestore().collection("coaches")
    
    /** Returns a specific coach document */
    private func coachDocument(coachId: String) -> DocumentReference {
        coachCollection.document(coachId)
    }
    
    /** POST - Add a new coach in the database */
    func addCoach(coach: DBCoach) async throws {
        try coachDocument(coachId: coach.coachId).setData(from: coach, merge: false)
    }
    
    /** GET - Returns the coach's information from the database */
    func getCoach(coachId: String) async throws -> DBCoach {
        try await coachDocument(coachId: coachId).getDocument(as: DBCoach.self)
    }
    
    /** PUT - Add a new team id in the teamsCoaching array */
    func addTeamToCoach(coachId: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBCoach.CodingKeys.teamsCoaching.rawValue: FieldValue.arrayUnion([teamId])
        ]
        // TO DO - Make sure the teamId that we are adding isn't already in the database
        
        // Update the document asynchronously
        try await coachDocument(coachId: coachId).updateData(data as [AnyHashable : Any])
    }
    
    /** DELETE - Remove a team id in the teamsCoaching array */
    func removeTeamToCoach(coachId: String, teamId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBCoach.CodingKeys.teamsCoaching.rawValue: FieldValue.arrayRemove([teamId])
        ]
        
        // Update the document asynchronously
        try await coachDocument(coachId: coachId).updateData(data as [AnyHashable : Any])
    }
    
    func loadTeamsCoaching(coachId: String) async throws -> [GetTeam] {
        
        let coach = try await getCoach(coachId: coachId)
        print("coach: \(coach)")
        
        // Fetch the team documents with the IDs from the user's itemsArray
        let snapshot = try await TeamManager.shared.teamCollection.whereField("team_id", in: coach.teamsCoaching ?? []).getDocuments()
        
        // Map the documents to Team objects and get their names
            var teams: [GetTeam] = []
            for document in snapshot.documents {
                if let team = try? document.data(as: DBTeam.self) {
                    // Add a Team object with the teamId and team name
                    let teamObject = GetTeam(teamId: team.teamId, name: team.name)
                    teams.append(teamObject)
                    print("Loaded team: \(team.name) with ID: \(team.teamId)")
                }
            }
            
            return teams
    }
}
