//
//  FirestoreCoachRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreCoachRepository: CoachRepository {
    
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
    public func addCoach(coachId: String) async throws {
        let coachDoc = coachCollection.document()
        let documentId = coachDoc.documentID
        
        let coach = DBCoach(id: documentId, coachId: coachId)
        try coachDoc.setData(from: coach, merge: false)
    }
    
    
    /// GET - Fetch the coach document by their unique coach ID
    /// This function queries Firestore for a coach document using the coach's ID.
    /// - Parameter coachId: The unique coach ID to fetch the associated coach document.
    /// - Returns: The `QuerySnapshot` containing the coach document(s).
    public func getCoachDocumentWithCoachId(coachId: String) async throws -> QuerySnapshot {
        return try await coachCollection.whereField("coach_id", isEqualTo: coachId).getDocuments()
    }
    
    
    /// GET - Retrieve the coach's information from Firestore
    /// This function fetches a coach's data from the Firestore database and returns it as a `DBCoach` object.
    /// - Parameter coachId: The unique coach ID to fetch the associated coach data.
    /// - Returns: An optional `DBCoach` object containing the coach's data.
    public func getCoach(coachId: String) async throws -> DBCoach? {
        guard let doc = try await getCoachDocumentWithCoachId(coachId: coachId).documents.first else { return nil }
        return try doc.data(as: DBCoach.self)
    }
    
    
    /// PUT - Add a new team ID to the coach's `teamsCoaching` array
    /// This function updates the coach's `teamsCoaching` field to include a new team ID.
    /// - Parameter coachId: The unique coach ID to update.
    /// - Parameter teamId: The team ID to add to the `teamsCoaching` array.
    public func addTeamToCoach(coachId: String, teamId: String) async throws {
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
    public func removeTeamToCoach(coachId: String, teamId: String) async throws {
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
    public func loadTeamsCoaching(coachId: String) async throws -> [GetTeam]? {
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
    public func loadAllTeamsCoaching(coachId: String) async throws -> [DBTeam]? {
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
