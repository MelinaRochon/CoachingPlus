//
//  PlayerManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import Foundation
import FirebaseFirestore

/**
 A struct representing a player in the database.
 This structure conforms to Codable to easily encode/decode data from Firestore.
 */
struct DBPlayer: Codable {
    let id: String
    let playerId: String?
    var jerseyNum: Int
    var nickName: String?
    var gender: String?
    let profilePicture: String?
    let teamsEnrolled: [String]? // TODO: Think about leaving it as it is or putting it as optional
    
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
        teamsEnrolled: [String]? = nil
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
}

final class PlayerManager {
    
    static let shared = PlayerManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    private let playerCollection = Firestore.firestore().collection("players") // user collection
    
    /**
     Returns a reference to a specific player document by ID.
     - Parameter id: The unique player document ID.
     - Returns: A `DocumentReference` to the player's Firestore document.
     */
    private func playerDocument(id: String) -> DocumentReference {
        playerCollection.document(id)
    }
    
    
    /**
     Creates a new player in the Firestore database.
     - Parameter playerDTO: A `PlayerDTO` object containing player information.
     - Returns: The newly created player's document ID.
     - Throws: An error if creating the player document fails.
     */
    func createNewPlayer(playerDTO: PlayerDTO) async throws -> String {
        let playerDocument = playerCollection.document()
        let documentId = playerDocument.documentID // get the document id
        
        // create a player object
        let player = DBPlayer(id: documentId, playerDTO: playerDTO)
        try playerDocument.setData(from: player, merge: false)
        return documentId
    }
    
    
     /**
      Fetches a player's information from the Firestore database by player ID.
      - Parameter playerId: The player's ID used to find the corresponding player document.
      - Returns: A `DBPlayer` object containing player data, or `nil` if not found.
      - Throws: An error if fetching the player document fails.
      */
    func getPlayer(playerId: String) async throws -> DBPlayer? {
        let query = try await playerCollection.whereField("player_id", isEqualTo: playerId).getDocuments()
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBPlayer.self)
    }
    
    
    /**
     Fetches a player by their document ID.
     
     - Parameter id: The unique player document ID.
     - Returns: A `DBPlayer` object containing player data, or `nil` if not found.
     - Throws: An error if fetching the player document fails.
     */
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
    
    
    /**
     Updates the guardian's name for a specific player.
     
     - Parameter id: The unique player document ID.
     - Parameter name: The new guardian's name to update in the player document.
     - Throws: An error if updating the document fails.
     */
    func updateGuardianName(id: String, name: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.guardianName.rawValue: name
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
   
    /**
     Removes all guardian information from a player's document.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    func removeGuardianInfo(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil,
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil,
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
     Adds a team to the list of teams the player is enrolled in.
     
     - Parameter id: The unique player document ID.
     - Parameter teamId: The team ID to add to the player's list of enrolled teams.
     - Throws: An error if updating the document fails.
     */
    func addTeamToPlayer(id: String, teamId: String) async throws {
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayUnion([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    /**
    DELETE - Removes a team ID from the 'teamsEnrolled' array in Firestore.
    - Parameter id: The unique player document ID.
    - Parameter teamId: The team ID to remove from the player's list of enrolled teams.
    - Throws: An error if updating the document fails.
    */
    func removeTeamFromPlayer(id: String, teamId: String) async throws {
        // find the team to remove
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayRemove([teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
    DELETE - Removes a team ID from the 'teamsEnrolled' array in Firestore.
    - Parameter id: The unique player document ID.
    - Parameter teamId: The team ID to remove from the player's list of enrolled teams.
    - Throws: An error if updating the document fails.
    */
    func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws {
        let teamManager = TeamManager()
        let team = try await teamManager.getTeamWithDocId(docId: teamDocId)
                
        // find the team to remove
        let data: [String: Any] = [
            DBPlayer.CodingKeys.teamsEnrolled.rawValue: FieldValue.arrayRemove([team.teamId])
        ]
        
        // Update the document asynchronously
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
     DELETE - Removes the guardian's name from the player's document in Firestore.
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    func removeGuardianInfoName(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianName.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
     DELETE - Removes the guardian's email address from the player's document in Firestore.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    func removeGuardianInfoEmail(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianEmail.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
     DELETE - Removes the guardian's phone number from the player's document in Firestore.
     
     - Parameter id: The unique player document ID.
     - Throws: An error if updating the document fails.
     */
    func removeGuardianInfoPhone(id: String) async throws {
        let data: [String:Any?] = [
            DBPlayer.CodingKeys.guardianPhone.rawValue: nil
        ]
        
        try await playerDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    /**
     PUT - Updates the player's information in Firestore.
     
     - Parameter player: A `DBPlayer` object containing updated player information.
     - Throws: An error if updating the document fails.
     */
    func updatePlayerInfo(player: DBPlayer) async throws {
        let data: [String:Any] = [
            DBPlayer.CodingKeys.jerseyNum.rawValue: player.jerseyNum,
            DBPlayer.CodingKeys.nickName.rawValue: player.nickName ?? "",
            DBPlayer.CodingKeys.guardianName.rawValue: player.guardianName ?? "",
            DBPlayer.CodingKeys.guardianEmail.rawValue: player.guardianEmail ?? "",
            DBPlayer.CodingKeys.guardianPhone.rawValue: player.guardianPhone ?? "",
            DBPlayer.CodingKeys.gender.rawValue: player.gender ?? ""
        ]
        try await playerDocument(id: player.id).updateData(data as [AnyHashable: Any])
    }
    
    
    /// Updates a player's settings in the database with any provided non-nil values.
    /// - Parameters:
    ///   - id: The unique identifier of the player document to update.
    ///   - jersey: Optional updated jersey number.
    ///   - nickname: Optional updated nickname.
    ///   - guardianName: Optional updated guardian's name.
    ///   - guardianEmail: Optional updated guardian's email address.
    ///   - guardianPhone: Optional updated guardian's phone number.
    ///   - gender: Optional updated gender.
    /// - Throws: Rethrows any errors that occur during the Firestore update operation.
    func updatePlayerSettings(id: String, jersey: Int?, nickname: String?, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) async throws {
        var data: [String: Any] = [:]
        if let jersey = jersey {
            data[DBPlayer.CodingKeys.jerseyNum.rawValue] = jersey
        }
        
        if let nickname = nickname {
            data[DBPlayer.CodingKeys.nickName.rawValue] = nickname
        }
        
        if let guardianName = guardianName {
            data[DBPlayer.CodingKeys.guardianName.rawValue] = guardianName
        }
        
        if let guardianEmail = guardianEmail {
            data[DBPlayer.CodingKeys.guardianEmail.rawValue] = guardianEmail
        }
        
        if let guardianPhone = guardianPhone {
            data[DBPlayer.CodingKeys.guardianPhone.rawValue] = guardianPhone
        }
        
        if let gender = gender {
            data[DBPlayer.CodingKeys.gender.rawValue] = gender
        }
        
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update in updatePlayerInfo")
            return
        }
        
        
        try await playerDocument(id: id).updateData(data as [AnyHashable: Any])
    }
    
    
    /**
     PUT - Updates the player's jersey number and nickname in Firestore.
     
     - Parameter playerDocId: The unique player document ID.
     - Parameter jersey: The new jersey number for the player.
     - Parameter nickname: The new nickname for the player.
     - Throws: An error if updating the document fails.
     */
    func updatePlayerJerseyAndNickname(playerDocId: String, jersey: Int, nickname: String) async throws {
        let data: [String:Any] = [
            DBPlayer.CodingKeys.jerseyNum.rawValue: jersey,
            DBPlayer.CodingKeys.nickName.rawValue: nickname,
        ]
        
        // update data in the database
        try await playerDocument(id: playerDocId).updateData(data as [AnyHashable: Any])
    }
    
    
    /**
     PUT - Updates the player's unique ID in Firestore.
     
     - Parameter id: The unique player document ID.
     - Parameter playerId: The new player ID.
     - Throws: An error if updating the document fails.
     */
    func updatePlayerId(id: String, playerId: String) async throws {
        let data: [String:Any] = [
            DBPlayer.CodingKeys.playerId.rawValue: playerId,
        ]
        try await playerDocument(id: id).updateData(data as [AnyHashable: Any])
    }
    
    
    /**
     PUT - Updates the player's unique ID in Firestore.
     
     - Parameter id: The unique player document ID.
     - Parameter playerId: The new player ID.
     - Throws: An error if updating the document fails.
     */
    func getTeamsEnrolled(playerId: String) async throws -> [GetTeam] {
        let teamRepo = FirestoreTeamRepository()
        guard let player = try await getPlayer(playerId: playerId),
                  let teamIds = player.teamsEnrolled,
              !teamIds.isEmpty else {
            return [] // no teams enrolled
        }
        
        let snapshot = try await teamRepo.teamCollection()
               .whereField("team_id", in: teamIds)
               .getDocuments()

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
    
    
    /**
     GET - Fetches all teams that the player is enrolled in as full `DBTeam` objects.
     
     - Parameter playerId: The player's ID used to retrieve enrolled teams.
     - Returns: An array of `DBTeam` objects representing the full team data.
     - Throws: An error if fetching the player's document or teams fails.
     */
    func getAllTeamsEnrolled(playerId: String) async throws -> [DBTeam]? {
        let teamRepo = FirestoreTeamRepository()
        guard let player = try await getPlayer(playerId: playerId),
                  let teamIds = player.teamsEnrolled,
              !teamIds.isEmpty else {
            return [] // no teams enrolled
        }
        
        let snapshot = try await teamRepo.teamCollection()
               .whereField("team_id", in: teamIds)
               .getDocuments()

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
    
    
    /**
     GET - Checks if the player is enrolled in a specific team.
     
     - Parameter playerId: The player's ID used to check enrollment.
     - Parameter teamId: The team ID to check for enrollment.
     - Returns: A boolean indicating whether the player is enrolled in the team.
     - Throws: An error if fetching the player's document fails.
     */
    func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
        let player = try await getPlayer(playerId: playerId)!
        print("player info: \(player)")
        if let teamsEnrolled = player.teamsEnrolled {
            // Check if the player is enrolled in the specific team by matching teamId in teamsEnrolled
            return teamsEnrolled.contains(teamId)

        }
        
        return false
    }
}

struct PlayerName {
    let playerId: String
    let firstName: String
    let lastName: String
}
