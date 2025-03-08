//
//  TeamManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-04.
//

import Foundation
import FirebaseFirestore

struct DBTeam: Codable {
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
    
    init(
        teamId: String,
        name: String,
        sport: String,
        logoUrl: String? = nil,
        colour: String? = nil,
        gender: String,
        ageGrp: String,
        accessCode: String? = nil,
        coaches: [String],
        players: [String]? = nil
    ) {
            
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
    }
    
    init(teamId:String) {
        self.teamId = teamId
        self.name = ""
        self.sport = ""
        self.logoUrl = nil
        self.colour = nil
        self.gender = ""
        self.ageGrp = ""
        self.accessCode = "abcd123" // a changer
        self.coaches = []
        self.players = nil
    }
    
    enum CodingKeys: String, CodingKey {
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
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
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
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
    }
    
}

final class TeamManager {
    
    static let shared = TeamManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    private let teamCollection = Firestore.firestore().collection("team") // team collection
    
    /** Returns a specific team document */
    private func teamDocument(teamId: String) -> DocumentReference {
        teamCollection.document(teamId)
    }
    
    /** Returns the team's information from the database */
    func getTeam(teamId: String) async throws -> DBTeam {
        try await teamDocument(teamId: teamId).getDocument(as: DBTeam.self)
    }

    func createNewTeam(auth: AuthDataResultModel, team: DBTeam) async throws {
        // verifie coach valide
        
        try teamDocument(teamId: team.teamId).setData(from: team, merge: false)
        
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
}
