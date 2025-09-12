//
//  TeamManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-04.
//

import Foundation
import FirebaseFirestore

/// Represents a team in the database with all necessary properties.
/// This structure conforms to `Codable` to support encoding and decoding
/// between Swift objects and Firestore documents.
struct DBTeam: Codable {
    let id: String
    let teamId: String
    var name: String
    var teamNickname: String
    let sport: String
    let logoUrl: String?
    let colour: String?
    var gender: String
    var ageGrp: String
    let accessCode: String?
    let coaches: [String]
    let players: [String]?
    let invites: [String]?
    
    init(
        id: String,
        teamId: String,
        name: String,
        teamNickname: String,
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
        self.teamNickname = teamNickname
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
        self.teamNickname = teamDTO.teamNickname
        self.sport = teamDTO.sport
        self.logoUrl = teamDTO.logoUrl
        self.colour = teamDTO.colour
        self.gender = teamDTO.gender
        self.ageGrp = teamDTO.ageGrp
        self.accessCode = teamDTO.accessCode //
        self.coaches = teamDTO.coaches
        self.players = teamDTO.players
        self.invites = teamDTO.invites
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case teamId = "team_id"
        case name = "name"
        case teamNickname = "team_nickname"
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
        self.teamNickname = try container.decode(String.self, forKey: .teamNickname)
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
        try container.encode(self.teamNickname, forKey: .teamNickname)
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


/// Manages operations related to teams, such as fetching, updating, and creating teams in Firestore.
/// This class follows a singleton pattern to ensure a single instance is used throughout the app.
final class TeamManager {
    
    static let shared = TeamManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    let teamCollection = Firestore.firestore().collection("teams") // team collection


    /// Returns a reference to a specific team document in Firestore.
    /// - Parameter id: Firestore document ID of the team.
    /// - Returns: A `DocumentReference` pointing to the team document.
    private func teamDocument(id: String) -> DocumentReference {
        teamCollection.document(id)
    }
    
    
    /// Retrieves a team by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getTeam(teamId: String) async throws -> DBTeam? {
        let snapshot = try await teamCollection.whereField("team_id", isEqualTo: teamId).getDocuments()

        //try await teamDocument(teamId: teamId).getDocument(as: DBTeam.self)
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBTeam.self)

    }
    
    /// Retrieves all teams by its team ID.
    /// - Parameter teamId: The system-assigned team ID.
    /// - Returns: A `DBTeam` instance if found, otherwise `nil`.
    func getAllTeams(teamIds: [String]) async throws -> [DBTeam] {
        guard !teamIds.isEmpty else { return [] }
        let snapshot = try await teamCollection.whereField("team_id", isEqualTo: teamIds).getDocuments()

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
        let snapshot = try await teamCollection.whereField("access_code", isEqualTo: accessCode).getDocuments()
        print("passe bien ici")
        guard let doc = snapshot.documents.first else { return nil }
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
            let coach = try await UserManager.shared.getUser(userId: coachId)
            let teamDocument = teamCollection.document()
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
        let snapshot = try await teamCollection.whereField("team_id", isEqualTo: teamId)
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

            let snapshot = try await teamCollection
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
}
