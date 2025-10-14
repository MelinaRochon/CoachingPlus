//
//  CoachManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object (DTO) for representing a coach in the database.
/// This struct models the data for a coach, including their unique identifier, coach ID, and the list of teams they are coaching.
/// It conforms to the `Codable` protocol to allow easy encoding and decoding from and to Firestore documents.
struct DBCoach: Codable {
    let id: String
    let coachId: String
    let teamsCoaching: [String]?
    
    // Initializer to create a DBCoach with optional teamsCoaching
    init(id: String, coachId: String, teamsCoaching: [String]? = nil) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = teamsCoaching
    }

    // Initializer for creating a DBCoach with no teamsCoaching
    init(id: String, coachId: String) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = []
    }

    // Initializer to create a DBCoach using a `CoachDTO`
    init(id: String, coachDTO: CoachDTO) {
        self.id = id
        self.coachId = coachDTO.coachId
        self.teamsCoaching = coachDTO.teamsCoaching
    }
    
    // Custom initializer to decode DBCoach from Firestore document
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.coachId = try container.decode(String.self, forKey: .coachId)
        self.teamsCoaching = try container.decodeIfPresent([String].self, forKey: .teamsCoaching)
    }
    
    // Enum for the Firestore keys used to encode and decode DBCoach
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case coachId = "coach_id"
        case teamsCoaching = "teams_coaching"
    }
    
    // Custom method to encode DBCoach into Firestore document
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.coachId, forKey: .coachId)
        try container.encodeIfPresent(self.teamsCoaching, forKey: .teamsCoaching)
    }
}


/// `CoachManager` class is responsible for managing coach-related operations in the Firestore database.
/// It includes methods to add, update, retrieve, and delete coach data, as well as manage the teams a coach is associated with.
final class CoachManager {
    
    /// Singleton instance for managing coach data
    static let shared = CoachManager()
    
    private init() {}  // Private initializer to enforce singleton usage

    /// Firestore collection reference for "coaches" collection
    private let coachCollection = Firestore.firestore().collection("coaches")

    /// Private helper function to get a document reference for a specific coach by their ID
    private func coachDocument(coachId: String) -> DocumentReference {
        return coachCollection.document(coachId)
    }

    
    // MARK: - CRUD Operations
        
    /// POST - Add a new coach to the Firestore database
    /// This function creates a new coach document in the "coaches" collection.
    /// - Parameter coachId: The unique coach ID to associate with the new coach.
    func addCoach(coachId: String) async throws {
        let coachDoc = coachCollection.document()
        let documentId = coachDoc.documentID
        
        let coach = DBCoach(id: documentId, coachId: coachId)
        try coachDoc.setData(from: coach, merge: false)
    }
    
    
    /// GET - Fetch the coach document by their unique coach ID
    /// This function queries Firestore for a coach document using the coach's ID.
    /// - Parameter coachId: The unique coach ID to fetch the associated coach document.
    /// - Returns: The `QuerySnapshot` containing the coach document(s).
    func getCoachDocumentWithCoachId(coachId: String) async throws -> QuerySnapshot {
        return try await coachCollection.whereField("coach_id", isEqualTo: coachId).getDocuments()
    }
    
    
    /// GET - Retrieve the coach's information from Firestore
    /// This function fetches a coach's data from the Firestore database and returns it as a `DBCoach` object.
    /// - Parameter coachId: The unique coach ID to fetch the associated coach data.
    /// - Returns: An optional `DBCoach` object containing the coach's data.
    func getCoach(coachId: String) async throws -> DBCoach? {
        guard let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first else { return nil }
        return try doc.data(as: DBCoach.self)
    }
    
    
    /// PUT - Add a new team ID to the coach's `teamsCoaching` array
    /// This function updates the coach's `teamsCoaching` field to include a new team ID.
    /// - Parameter coachId: The unique coach ID to update.
    /// - Parameter teamId: The team ID to add to the `teamsCoaching` array.
    func addTeamToCoach(coachId: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBCoach.CodingKeys.teamsCoaching.rawValue: FieldValue.arrayUnion([teamId])
        ]
        // TODO: - Make sure the teamId that we are adding isn't already in the database
        
        // Update the document asynchronously
        if let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first {
            try await doc.reference.updateData(data as [AnyHashable : Any])// Assuming you have a `Coach` model
        } else {
            print("No coach found with that ID.")
        }
    }
    
    
    /// DELETE - Remove a team ID from the coach's `teamsCoaching` array
    /// This function removes a team ID from the coach's `teamsCoaching` field.
    /// - Parameter coachId: The unique coach ID to update.
    /// - Parameter teamId: The team ID to remove from the `teamsCoaching` array.
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
    
    
    /// GET - Fetch all teams that a coach is associated with
    /// This function retrieves the teams a coach is coaching by using their `teamsCoaching` array, which stores the team IDs.
    /// - Parameter coachId: The unique coach ID to retrieve their teams.
    /// - Returns: An optional array of `GetTeam` objects containing the team information.
    func loadTeamsCoaching(coachId: String) async throws -> [GetTeam]? {
        let teamRepo = FirestoreTeamRepository()
        let coach = try await getCoach(coachId: coachId)!
        if let teamsCoaching = coach.teamsCoaching {
            if teamsCoaching != [] {
                // Fetch the team documents with the IDs from the user's itemsArray
                let snapshot = try await teamRepo.teamCollection().whereField("team_id", in: teamsCoaching).getDocuments()
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
        
        return nil
        
    }
    

    /// GET - Fetch all teams that a coach is associated with and return them as `DBTeam` objects
    /// This function fetches the full `DBTeam` objects for all teams the coach is coaching.
    /// - Parameter coachId: The unique coach ID to retrieve their teams.
    /// - Returns: An optional array of `DBTeam` objects.
    func loadAllTeamsCoaching(coachId: String) async throws -> [DBTeam]? {
        let teamRepo = FirestoreTeamRepository()
        let coach = try await getCoach(coachId: coachId)!
        if let teamsCoaching = coach.teamsCoaching {
            if teamsCoaching != [] {
                // Fetch the team documents with the IDs from the user's itemsArray
                let snapshot = try await teamRepo.teamCollection().whereField("team_id", in: teamsCoaching).getDocuments()
                // Map the documents to Team objects and get their names
                var teams: [DBTeam] = []
                for document in snapshot.documents {
                    if let team = try? document.data(as: DBTeam.self) {
                        // Add a Team object with the teamId and team name
                        teams.append(team)
                    }
                }
                
                return teams
            }
        }
        
        return nil
        
    }
}
