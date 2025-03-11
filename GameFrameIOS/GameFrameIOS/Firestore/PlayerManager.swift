//
//  PlayerManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import Foundation
import FirebaseFirestore

struct DBPlayer: Codable {
    let playerId: String
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
        playerId: String,
        jerseyNum: Int,
        nickName: String? = nil,
        gender: String? = nil,
        guardianName: String? = nil,
        guardianEmail: String? = nil,
        guardianPhone: String? = nil,
        profilePicture: String? = nil,
        teamsEnrolled: [String]? = nil
    ) {
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
    
    init(playerId: String) {
        self.playerId = playerId
        self.jerseyNum = 0
        self.nickName = nil
        self.gender = nil
        self.guardianName = nil
        self.guardianEmail = nil
        self.guardianPhone = nil
        self.profilePicture = nil
        self.teamsEnrolled = []
    }
    
    enum CodingKeys: String, CodingKey {
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
        self.playerId = try container.decode(String.self, forKey: .playerId)
        self.jerseyNum = try container.decode(Int.self, forKey: .jerseyNum)
        self.nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.guardianName = try container.decodeIfPresent(String.self, forKey: .guardianName)
        self.guardianEmail = try container.decodeIfPresent(String.self, forKey: .guardianEmail)
        self.guardianPhone = try container.decodeIfPresent(String.self, forKey: .guardianPhone)
        self.profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)
        self.teamsEnrolled = try container.decodeIfPresent([String].self, forKey: .teamsEnrolled)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
    private func playerDocument(playerId: String) -> DocumentReference {
        playerCollection.document(playerId)
    }
    
    /** Creates a new player in the database */
    func createNewPlayer(player: DBPlayer) async throws {
        try playerDocument(playerId: player.playerId).setData(from: player, merge: false)
    }
    
    /** Returns the player's information from the database by finding the user's document, with the userId */
    func getPlayer(userId: String) async throws -> DBPlayer {
        try await playerDocument(playerId: userId).getDocument(as: DBPlayer.self)
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
    func updateGuardianName(playerId: String, name: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.guardianName.rawValue: name
        ]
        try await playerDocument(playerId: playerId).updateData(data)
    }
    
    /** Remove all the guardian information from the player's document */
    func removeGuardianInfo(playerId: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil,
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil,
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** PUT - Add to the 'teamsEnrolled' array the teamId */
    func addTeamToPlayer(playerId: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayUnion([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable : Any])
    }
    
    /** DELETE - Remove a team id in the  'teamsEnrolled' array */
    func removeTeamFromPlayer(playerId: String, teamId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayRemove([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable : Any])
    }
    
    /** Remove the guardian name from the player's document */
    func removeGuardianInfoName(playerId: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil
        ]
        
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** Remove the guardian email address from the player's document */
    func removeGuardianInfoEmail(playerId: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil
        ]
        
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
    }
    
    /** Remove the guardian phone number from the player's document */
    func removeGuardianInfoPhone(playerId: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(playerId: playerId).updateData(data as [AnyHashable: Any])
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
        try await playerDocument(playerId: player.playerId).updateData(data as [AnyHashable: Any])
    }
}
