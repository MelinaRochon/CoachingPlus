//
//  TeamManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-04.
//

import Foundation
import FirebaseFirestore

struct DBTeam: Codable {
    let id: String
    let teamId: String
    let name: String
    let sport: String
    let logoUrl: String?
    let colour: String?
    let gender: String
    let ageGrp: String
    let accessCode: String?
    let coaches: [String]
    let players: [String]?
    let invites: [String]?
    
    init(
        id: String,
        teamId: String,
        name: String,
        sport: String,
        logoUrl: String? = nil,
        colour: String? = nil,
        gender: String,
        ageGrp: String,
        accessCode: String? = nil,
        coaches: [String],
        players: [String]? = nil,
        invites: [String]? = nil
    ) {
        self.id = id
        self.teamId = teamId
        self.name = name
        self.sport = sport
        self.logoUrl = logoUrl
        self.colour = colour
        self.gender = gender
        self.ageGrp = ageGrp
        self.accessCode = accessCode
        self.coaches = coaches
        self.players = players
        self.invites = invites
    }
    
    init(id: String, teamDTO:TeamDTO) {
        self.id = id
        self.teamId = teamDTO.teamId
        self.name = teamDTO.name
        self.sport = teamDTO.sport
        self.logoUrl = teamDTO.logoUrl
        self.colour = teamDTO.colour
        self.gender = teamDTO.gender
        self.ageGrp = teamDTO.ageGrp
        self.accessCode = "abcd123" // a changer
        self.coaches = teamDTO.coaches
        self.players = teamDTO.players
        self.invites = teamDTO.invites
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case teamId = "team_id"
        case name = "name"
        case sport = "sport"
        case logoUrl = "logo_url"
        case colour = "colour"
        case gender = "gender"
        case ageGrp = "age_grp"
        case accessCode = "access_code"
        case coaches = "coaches"
        case players = "players"
        case invites = "invites"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.teamId = try container.decode(String.self, forKey: .teamId)
        self.name = try container.decode(String.self, forKey: .name)
        self.sport = try container.decode(String.self, forKey: .sport)
        self.logoUrl = try container.decode(String.self, forKey: .logoUrl)
        self.colour = try container.decode(String.self, forKey: .colour)
        self.gender = try container.decode(String.self, forKey: .gender)
        self.ageGrp = try container.decode(String.self, forKey: .ageGrp)
        self.accessCode = try container.decode(String.self, forKey: .accessCode)
        self.coaches = try container.decode([String].self, forKey: .coaches)
        self.players = try container.decodeIfPresent([String].self, forKey: .players)
        self.invites = try container.decodeIfPresent([String].self, forKey: .invites)

    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.teamId, forKey: .teamId)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.sport, forKey: .sport)
        try container.encodeIfPresent(self.logoUrl, forKey: .logoUrl)
        try container.encodeIfPresent(self.colour, forKey: .colour)
        try container.encode(self.gender, forKey: .gender)
        try container.encode(self.ageGrp, forKey: .ageGrp)
        try container.encodeIfPresent(self.accessCode, forKey: .accessCode)
        try container.encode(self.coaches, forKey: .coaches)
        try container.encodeIfPresent(self.players, forKey: .players)
        try container.encodeIfPresent(self.invites, forKey: .invites)
    }
}

final class TeamManager {
    
    static let shared = TeamManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    let teamCollection = Firestore.firestore().collection("teams") // team collection


    /** Returns a specific team document */
    private func teamDocument(id: String) -> DocumentReference {
        teamCollection.document(id)
    }
    
    /** Returns the team's information from the database */
    func getTeam(teamId: String) async throws -> DBTeam? {
        let snapshot = try await teamCollection.whereField("team_id", isEqualTo: teamId).getDocuments()

        //try await teamDocument(teamId: teamId).getDocument(as: DBTeam.self)
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBTeam.self)

    }
    
    func getTeamWithAccessCode(accessCode: String) async throws -> DBTeam? {
        let snapshot = try await teamCollection.whereField("access_code", isEqualTo: accessCode).getDocuments()

        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBTeam.self)
    }
    
    /** Returns the team name's information from the database */
    func getTeamName(teamId: String) async throws -> String {
        let team = try await getTeam(teamId: teamId)!
        return team.name
    }
        
    /** PUT - Add a player id to the 'players' array !NEEDS to be tested! */
    func addPlayerToTeam(id: String, playerId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.players.rawValue: FieldValue.arrayUnion([playerId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /** DELETE - Remove a player from the team */
    func removePlayerFromTeam(id: String, playerId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.players.rawValue: FieldValue.arrayRemove([playerId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /** PUT - Add a coach id to the 'coaches' array !NEEDS to be tested! */
    func addCoachToTeam(id: String, coachId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.coaches.rawValue: FieldValue.arrayUnion([coachId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /** PUT - Add an invite doc id to the 'invites' array !NEEDS to be tested! */
    func addInviteToTeam(id: String, inviteDocId: String) async throws {
        let data: [String: Any] = [
            DBTeam.CodingKeys.invites.rawValue: FieldValue.arrayUnion([inviteDocId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
        
        print("Updated the team doc: \(id) by adding a new invite: \(inviteDocId)")
    }
    
    /** DELETE - Remove an invite from the team */
    func removeInviteFromTeam(id: String, inviteDocId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.invites.rawValue: FieldValue.arrayRemove([inviteDocId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /** DELETE - Remove a coach from the team */
    func removeCoachFromTeam(id: String, coachId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBTeam.CodingKeys.coaches.rawValue: FieldValue.arrayRemove([coachId])
        ]
        
        // Update the document asynchronously
        try await teamDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    

    func createNewTeam(coachId: String, teamDTO: TeamDTO) async throws {
//        let coachID = auth.uid
        do {
            print("Sending team to Firestore: \(teamDTO)")
            // verifie coach valide
            let coach = try await UserManager.shared.getUser(userId: coachId)
            let teamDocument = teamCollection.document()
            let documentId = teamDocument.documentID // get the document id
            
            // create a new team
            let team = DBTeam(id: documentId, teamDTO: teamDTO)
            try teamDocument.setData(from: team, merge: false)
            
            // Add the team in the coach's document
            try await CoachManager.shared.addTeamToCoach(coachId: coachId, teamId: teamDTO.teamId)
//            let coachRef = Firestore.firestore().collection("users").document(coachId)
//                    try await coachRef.updateData([
//                        "teams_coaching": FieldValue.arrayUnion([team.teamId])
//                    ])
            print("Team created!")
        } catch let error as NSError {
            print("Error creating team: \(error.localizedDescription)")
            throw error
        }
        
        
        // ajouter dans collection coach valeur teamId (dans array)
        
        // chercher coachId et inserer dans attribut coaches
        
//        var userData: [String:Any] = [
//            "user_id": auth.uid,
//            "date_created": Timestamp(),
//            "user_type": userType
//        ]
//        
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
        
        // Create a new user, with the document id set as the user id
//        try await Firestore.firestore().collection("teams").document(auth.uid).setData(userData, merge: false)
    }
    
    func doesTeamExist(teamId: String) async throws -> Bool {
        let snapshot = try await teamCollection.whereField("team_id", isEqualTo: teamId)
            .limit(to: 1) // Limit to 1 for efficiency
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
}
