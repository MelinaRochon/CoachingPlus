//
//  FirestoreTeamRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
import FirebaseFirestore

final class FirestoreTeamRepository: TeamRepository {
    
//    var teamCollection = Firestore.firestore().collection("teams") // team collection
    func teamCollection() -> CollectionReference {
        return Firestore.firestore().collection("teams")
    }

    /// Returns a reference to a specific team document in Firestore.
    /// - Parameter id: Firestore document ID of the team.
    /// - Returns: A `DocumentReference` pointing to the team document.
    private func teamDocument(id: String) -> DocumentReference {
        teamCollection().document(id)
    }
    
    
    /// Retrieves a team by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getTeam(teamId: String) async throws -> DBTeam? {
        let snapshot = try await teamCollection().whereField("team_id", isEqualTo: teamId).getDocuments()

        //try await teamDocument(teamId: teamId).getDocument(as: DBTeam.self)
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBTeam.self)

    }
    
    /// Retrieves all teams by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getAllTeams(teamIds: [String]) async throws -> [DBTeam] {
        guard !teamIds.isEmpty else { return [] }
        let snapshot = try await teamCollection().whereField("team_id", isEqualTo: teamIds).getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DBTeam.self) }

    }
    
    
    /// Retrieves a team by its Firestore document ID.
    /// - Parameter docId: Firestore document ID of the team.
    /// - Returns: A `DBTeam` instance.
    func getTeamWithDocId(docId: String) async throws -> DBTeam {
        try await teamDocument(id: docId).getDocument(as: DBTeam.self)
    }
    
    
    /// Retrieves a team using the access code.
    /// - Parameters:
    ///   - accessCpde: Team access code.
    ///   - Returns: A `DBTeam` instance, if found, otherwise `nil`
    func getTeamWithAccessCode(accessCode: String) async throws -> DBTeam? {
        print("acees_code givenn is: [\(accessCode)]")
        
        let snapshot = try await teamCollection().whereField("access_code", isEqualTo: accessCode).getDocuments()
        print("passe bien ici")
        print("snapshot of access code is: \(snapshot)")
        guard let doc = snapshot.documents.first else { return nil }
        print("doc of access code is: \(doc)")
        return try doc.data(as: DBTeam.self)
    }
    
    
    /// Retrieves a team name by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `String` with the team name,.
    func getTeamName(teamId: String) async throws -> String {
        let team = try await getTeam(teamId: teamId)!
        return team.name
    }
        
    /// Adds a player to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - playerId: ID of the player to be added.
    func addPlayerToTeam(id: String, playerId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.players.rawValue: FieldValue.arrayUnion([playerId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Checks whether a player belongs to a specific team.
    ///
    /// - Parameters:
    ///   - id: The document ID of the team in the database.
    ///   - playerId: The unique identifier of the player to check.
    /// - Returns: `true` if the player is on the team, otherwise `false`.
    /// - Throws: An error if the team could not be fetched from the database.
    func isPlayerOnTeam(id: String, playerId: String) async throws -> Bool {
        let team = try await getTeamWithDocId(docId: id)
        if let players = team.players {
            return players.contains(playerId)
        }
        
        return false
    }
    
    
    /// Retrieves the roster size (number of players) for a given team.
    ///
    /// - Parameter teamId: The unique identifier of the team to fetch.
    ///
    /// - Throws: An error if the Firestore request or data decoding fails.
    ///
    /// - Returns: The number of players in the team's roster, or:
    ///   - `nil` if no team with the given ID exists,
    ///   - `0` if the team exists but has no roster.
    func getTeamRosterLength(teamId: String) async throws -> Int? {
        guard let team = try await getTeam(teamId: teamId) else {
            print("No team found with this team id")
            return nil
        }
        
        if let roster = team.players {
            return roster.count
        }
        
        return 0
    }
 
    
    /// Removes a player from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - playerId: ID of the player to be removed.
    func removePlayerFromTeam(id: String, playerId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.players.rawValue: FieldValue.arrayRemove([playerId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /// Adds a coach to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - coachId: ID of the coach to be added.
    func addCoachToTeam(id: String, coachId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.coaches.rawValue: FieldValue.arrayUnion([coachId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Adds an invite to the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - inviteDocId: Firestore document ID of the invite.
    func addInviteToTeam(id: String, inviteDocId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.invites.rawValue: FieldValue.arrayUnion([inviteDocId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
        
        print("Updated the team doc: \(id) by adding a new invite: \(inviteDocId)")
    }
    
    func getInviteDocIdOfPlayerAndTeam(teamDocId: String, playerDocId: String) async throws -> String? {
        guard let invite = try await InviteManager.shared.getInviteByPlayerDocIdAndTeamId(playerDocId: playerDocId, teamDocId: teamDocId) else {
            print("Invite does not exists")
            return nil
        }
        
        return invite.id
    }
    
    
    /// Removes an invite from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - inviteDocId: Firestore document ID of the invite.
    func removeInviteFromTeam(id: String, inviteDocId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.invites.rawValue: FieldValue.arrayRemove([inviteDocId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Removes a coach from the team.
    /// - Parameters:
    ///   - id: Firestore document ID of the team.
    ///   - coachId: ID of the coach to be removed.
    func removeCoachFromTeam(id: String, coachId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.coaches.rawValue: FieldValue.arrayRemove([coachId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    

    /// Creates a new team in Firestore and associates it with a coach.
    /// - Parameters:
    ///   - coachId: The ID of the coach creating the team.
    ///   - teamDTO: The data transfer object containing team details.
    func createNewTeam(coachId: String, teamDTO: TeamDTO) async throws {
        do {
            print("Sending team to Firestore: \(teamDTO)")
            // verifie coach valide
            let userManager = UserManager()
            let coach = try await userManager.getUser(userId: coachId)
            let teamDocument = teamCollection().document()
            let documentId = teamDocument.documentID // get the document id
            
            // create a new team
            let team = DBTeam(id: documentId, teamDTO: teamDTO)
            try teamDocument.setData(from: team, merge: false)
            
            // Add the team in the coach's document
            try await CoachManager.shared.addTeamToCoach(coachId: coachId, teamId: teamDTO.teamId)
        } catch let error as NSError {
            print("Error creating team: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    /// Checks whether a team exists in the database.
    /// - Parameter teamId: The team ID to check.
    /// - Returns: `true` if the team exists, otherwise `false`.
    func doesTeamExist(teamId: String) async throws -> Bool {
        let snapshot = try await teamCollection().whereField("team_id", isEqualTo: teamId)
            .limit(to: 1) // Limit to 1 for efficiency
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    
    /// Generates a unique 8-character access code for a team.
    /// - Returns: A unique alphanumeric access code.
    func generateUniqueTeamAccessCode() async throws -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

        func generateCode() -> String {
            return String((0..<8).map { _ in characters.randomElement()! })
        }

        while true {
            let newCode = generateCode()

            let snapshot = try await teamCollection()
                .whereField("access_code", isEqualTo: newCode)
                .getDocuments()

            if snapshot.documents.isEmpty {
                return newCode // return when unique code found
            }

            // If code exists, loop to generate another
        }
    }
    
    
    /// Updates the fields of a team document in Firestore (or another data source).
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the team document to update.
    ///   - name: Optional new name for the team. If `nil`, the name field will not be updated.
    ///   - nickname: Optional new nickname for the team. If `nil`, the nickname field will not be updated.
    ///   - ageGrp: Optional new age group for the team. If `nil`, the age group field will not be updated.
    ///   - gender: Optional new gender value for the team. If `nil`, the gender field will not be updated.
    ///
    /// - Throws: Rethrows any errors from Firestore’s `updateData` call.
    func updateTeamSettings(id: String, name: String?, nickname: String?, ageGrp: String?, gender: String?) async throws {
        var data: [String: Any] = [:]
        if let name = name {
            data[DBTeam.CodingKeys.name.rawValue] = name
        }
        
        if let nickname = nickname {
            data[DBTeam.CodingKeys.teamNickname.rawValue] = nickname
        }
        
        if let ageGrp = ageGrp {
            data[DBTeam.CodingKeys.ageGrp.rawValue] = ageGrp
        }
        
        if let gender = gender {
            data[DBTeam.CodingKeys.gender.rawValue] = gender
        }
        
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update")
            return
        }
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Deletes a team in Firestore
    ///
    /// - Parameters:
    ///    - id: The ID of the team to delete
    ///  - Throws: An error if the delete process fails
    func deleteTeam(id: String) async throws {
        try await teamDocument(id: id).delete()
    }

}
