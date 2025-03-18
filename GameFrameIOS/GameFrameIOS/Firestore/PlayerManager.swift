//
//  PlayerManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import Foundation
import FirebaseFirestore

struct DBPlayer: Codable {
    let id: String
    let playerId: String?
    var jerseyNum: Int
    var nickName: String?
    let gender: String?
    let profilePicture: String?
    let teamsEnrolled: [String] // TO DO - Think about leaving it as it is or putting it as optional
    
    
    // Guardian information - optional
    
    var guardianName: String?
    var guardianEmail: String?
    var guardianPhone: String?
    
    init(
        id: String,
        playerId: String? = nil,
        jerseyNum: Int,
        nickName: String? = nil,
        gender: String? = nil,
        guardianName: String? = nil,
        guardianEmail: String? = nil,
        guardianPhone: String? = nil,
        profilePicture: String? = nil,
        teamsEnrolled: [String]
    ) {
        self.id = id
        self.playerId = playerId
        self.jerseyNum = jerseyNum
        self.nickName = nickName
        self.gender = gender
        self.guardianName = guardianName
        self.guardianEmail = guardianEmail
        self.guardianPhone = guardianPhone
        self.profilePicture = profilePicture
        self.teamsEnrolled = teamsEnrolled
    }
    
    init(id: String) {
        self.id = id
        self.playerId = nil
        self.jerseyNum = 0
        self.nickName = nil
        self.gender = nil
        self.guardianName = nil
        self.guardianEmail = nil
        self.guardianPhone = nil
        self.profilePicture = nil
        self.teamsEnrolled = []
    }
    
    init(id: String, playerDTO: PlayerDTO) {
        self.id = id
        self.playerId = playerDTO.playerId
        self.jerseyNum = playerDTO.jerseyNum
        self.nickName = playerDTO.nickName
        self.gender = playerDTO.gender
        self.guardianName = playerDTO.guardianName
        self.guardianEmail = playerDTO.guardianEmail
        self.guardianPhone = playerDTO.guardianPhone
        self.profilePicture = playerDTO.profilePicture
        self.teamsEnrolled = playerDTO.teamsEnrolled
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case playerId = "player_id"
        case jerseyNum = "jersey_num"
        case nickName = "nickname"
        case gender = "gender"
        case guardianName = "guardian_name"
        case guardianEmail = "guardian_email"
        case guardianPhone = "guardian_phone"
        case profilePicture = "profile_picture"
        case teamsEnrolled = "teams_enrolled"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.playerId = try container.decodeIfPresent(String.self, forKey: .playerId)
        self.jerseyNum = try container.decode(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.guardianName = try container.decodeIfPresent(String.self, forKey: .guardianName)
        self.guardianEmail = try container.decodeIfPresent(String.self, forKey: .guardianEmail)
        self.guardianPhone = try container.decodeIfPresent(String.self, forKey: .guardianPhone)
        self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        self.teamsEnrolled = try container.decode([String].self, forKey: .teamsEnrolled)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.playerId, forKey: .playerId)
        try container.encode(self.jerseyNum, forKey: .jerseyNum)
        try container.encodeIfPresent(self.nickName, forKey: .nickName)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.guardianName, forKey: .guardianName)
        try container.encodeIfPresent(self.guardianEmail, forKey: .guardianEmail)
        try container.encodeIfPresent(self.guardianPhone, forKey: .guardianPhone)
        try container.encodeIfPresent(self.profilePicture, forKey: .profilePicture)
        try container.encodeIfPresent(self.teamsEnrolled, forKey: .teamsEnrolled)
    }
    
//    mutating func updateGuardianName(name: String) {
//        guardianName = name
//    }
}

final class PlayerManager {
    
    static let shared = PlayerManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    
    private let playerCollection = Firestore.firestore().collection("players") // user collection
    
    /** Returns the player document */
    private func playerDocument(id: String) -> DocumentReference {
        playerCollection.document(id)
    }
    
    /** Creates a new player in the database */
    func createNewPlayer(playerDTO: PlayerDTO) async throws -> String {
        let playerDocument = playerCollection.document()
        let documentId = playerDocument.documentID // get the document id
        
        // create a player object
        let player = DBPlayer(id: documentId, playerDTO: playerDTO)
        try playerDocument.setData(from: player, merge: false)
        //try playerDocument(playerId: player.playerId).setData(from: player, merge: false)
        return documentId
    }
    
    /** Returns the player's information from the database by finding the user's document, with the userId */
    func getPlayer(playerId: String) async throws -> DBPlayer? {
        let query = try await playerCollection.whereField("player_id", isEqualTo: playerId).getDocuments()
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBPlayer.self)
        //try await playerDocument(playerId: userId).getDocument(as: DBPlayer.self)
    }
    
    func findPlayerWithId(id: String) async throws -> DBPlayer? {
        return try await playerDocument(id: id).getDocument(as: DBPlayer.self)
    }
    
    /** Encode the information */
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    /** Decode the information */
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    /** Updates the guardian name in the player's profile - NOT used? */
    func updateGuardianName(id: String, name: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.guardianName.rawValue: name
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
        //try await playerDocument(playerId: playerId).updateData(data)
    }
    
    /** Remove all the guardian information from the player's document */
    func removeGuardianInfo(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil,
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil,
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** PUT - Add to the 'teamsEnrolled' array the teamId */
    func addTeamToPlayer(id: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayUnion([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])

        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable : Any])
    }
    
    /** DELETE - Remove a team id in the  'teamsEnrolled' array */
    func removeTeamFromPlayer(id: String, teamId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayRemove([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])

        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable : Any])
    }
    
    /** Remove the guardian name from the player's document */
    func removeGuardianInfoName(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])

        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** Remove the guardian email address from the player's document */
    func removeGuardianInfoEmail(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])

        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** Remove the guardian phone number from the player's document */
    func removeGuardianInfoPhone(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])

        //try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** Updates the player's information on the 'player' collection */
    func updatePlayerInfo(player: DBPlayer) async throws {
        let data: [String:Any] = [
            DBPlayer.CodingKeys.jerseyNum.rawValue: player.jerseyNum,
            DBPlayer.CodingKeys.nickName.rawValue: player.nickName ?? "",
            DBPlayer.CodingKeys.guardianName.rawValue: player.guardianName ?? "",
            DBPlayer.CodingKeys.guardianEmail.rawValue: player.guardianEmail ?? "",
            DBPlayer.CodingKeys.guardianPhone.rawValue: player.guardianPhone ?? "",
        ]
        try await playerDocument(id: player.id).updateData(data as [AnyHashable: Any])
    }
    
    func updatePlayerId(id: String, playerId: String) async throws {
        let data: [String:Any] = [
            DBPlayer.CodingKeys.playerId.rawValue: playerId,
        ]
        try await playerDocument(id: id).updateData(data as [AnyHashable: Any])
    }
    
    func getTeamsEnrolled(playerId: String) async throws -> [GetTeam] {
        
        let player = try await getPlayer(playerId: playerId)!
        print("player info: \(player)")
        
        // Fetch the team documents with the IDs from the user's itemsArray
        let snapshot = try await TeamManager.shared.teamCollection.whereField("team_id", in: player.teamsEnrolled ?? []).getDocuments()

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
    
    func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
        let player = try await getPlayer(playerId: playerId)!
        print("player info: \(player)")
        // Check if the player exists
//            guard let player = player else {
//                throw NSError(domain: "PlayerManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found"])
//            }
//
        // Check if the player is enrolled in the specific team by matching teamId in teamsEnrolled
        return player.teamsEnrolled.contains(teamId)

    }
}
