//
//  GameManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import Foundation
import FirebaseFirestore


/**
 This struct represents a game in the Firestore database. It includes details such as the game's title, duration,
 location, time-related settings (such as scheduled time reminder and feedback times), and other metadata like the
 team ID associated with the game. The struct is `Codable`, making it easy to serialize and deserialize between
 Firestore documents and the application's data model.

 Properties:
 - `gameId`: A unique identifier for the game document in Firestore.
 - `title`: The title or name of the game.
 - `duration`: The duration of the game in seconds.
 - `location`: The location where the game is scheduled to take place. This is optional.
 - `scheduledTimeReminder`: A reminder time for the game in minutes. This indicates how far in advance the reminder
   should trigger before the game starts.
 - `startTime`: The scheduled start time of the game. This is optional and may be nil if not set.
 - `timeBeforeFeedback`: The time, in seconds, before feedback can be provided during the game.
 - `timeAfterFeedback`: The time, in seconds, after feedback can be provided.
 - `recordingReminder`: A boolean indicating whether a reminder for recording is enabled for the game.
 - `teamId`: The ID of the team associated with this game.

 The struct has several initializers:
 - A default initializer that takes in all the necessary game properties.
 - A convenience initializer that creates a game with default values if the data is unavailable.
 - An initializer that maps data from a `GameDTO` (Data Transfer Object), which is commonly used when receiving
   game data from an external source like an API.

 The struct is also `Codable` to work with Firestore's data serialization and deserialization features. It includes
 custom `init(from:)` and `encode(to:)` methods for decoding and encoding the game data.

 This model is used to store and retrieve game data from the Firestore database.
 */
struct DBGame: Codable {
    let gameId: String
    let title: String
    let duration: Int
    let location: String?
    let scheduledTimeReminder: Int // in minutes
    let startTime: Date?
    let timeBeforeFeedback: Int // in seconds
    let timeAfterFeedback: Int // in seconds
    let recordingReminder: Bool
    let teamId: String
    
    init(gameId: String, title: String, duration: Int, location: String? = nil, scheduledTimeReminder: Int, startTime: Date? = nil, timeBeforeFeedback: Int, timeAfterFeedback: Int, recordingReminder: Bool, teamId: String) {
        self.gameId = gameId
        self.title = title
        self.duration = duration
        self.location = location
        self.scheduledTimeReminder = scheduledTimeReminder
        self.startTime = startTime
        self.timeBeforeFeedback = timeBeforeFeedback
        self.timeAfterFeedback = timeAfterFeedback
        self.recordingReminder = recordingReminder
        self.teamId = teamId
    }
    
    init(gameId: String, teamId: String) {
        self.gameId = gameId
        self.title = "Unknown Game"
        self.duration = 0 // by default, 0 seconds
        self.location = nil
        self.scheduledTimeReminder = 0 // by default, 0 minutes
        self.startTime = Date()
        self.timeBeforeFeedback = 10 // by default, 10 seconds
        self.timeAfterFeedback = 10 // by default, 10 seconds
        self.recordingReminder = false
        self.teamId = teamId
    }
    
    init(gameId: String, gameDTO: GameDTO) {
        self.gameId = gameId
        self.title = gameDTO.title
        self.duration = gameDTO.duration // by default, 0 seconds
        self.location = gameDTO.location
        self.scheduledTimeReminder = gameDTO.scheduledTimeReminder // by default, 0 minutes
        self.startTime = gameDTO.startTime
        self.timeBeforeFeedback = gameDTO.timeBeforeFeedback // by default, 10 seconds
        self.timeAfterFeedback = gameDTO.timeAfterFeedback // by default, 10 seconds
        self.recordingReminder = gameDTO.recordingReminder
        self.teamId = gameDTO.teamId
    }
    
    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case title = "title"
        case duration = "duration"
        case location = "location"
        case scheduledTimeReminder = "scheduled_time"
        case startTime = "start_time"
        case timeBeforeFeedback = "time_before_feedback"
        case timeAfterFeedback = "time_after_feedback"
        case recordingReminder = "recording_reminder"
        case teamId = "team_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.scheduledTimeReminder = try container.decode(Int.self, forKey: .scheduledTimeReminder)
        self.startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        self.timeBeforeFeedback = try container.decode(Int.self, forKey: .timeBeforeFeedback)
        self.timeAfterFeedback = try container.decode(Int.self, forKey: .timeAfterFeedback)
        self.recordingReminder = try container.decode(Bool.self, forKey: .recordingReminder)
        self.teamId = try container.decode(String.self, forKey: .teamId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.duration, forKey: .duration)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encode(self.scheduledTimeReminder, forKey: .scheduledTimeReminder)
        try container.encodeIfPresent(self.startTime, forKey: .startTime)
        try container.encode(self.timeBeforeFeedback, forKey: .timeBeforeFeedback)
        try container.encode(self.timeAfterFeedback, forKey: .timeAfterFeedback)
        try container.encode(self.recordingReminder, forKey: .recordingReminder)
        try container.encode(self.teamId, forKey: .teamId)
    }
}


/**
 The `GameManager` class is responsible for managing game-related operations in the Firestore database. It provides
 methods to add, update, retrieve, and manage games for a specific team. This class uses Firestore's `DocumentReference`
 and `CollectionReference` to interact with the database.

 Key responsibilities of the `GameManager` class include:
 - Retrieving specific game documents and collections.
 - Fetching all games for a specific team.
 - Adding new games to the Firestore database.
 - Updating existing games (e.g., updating game duration).
 
 The class follows the Singleton design pattern, which means there is only one instance of this class in the application.
 The singleton instance can be accessed via the `shared` static property.

 This class acts as a centralized manager for game-related database operations, ensuring that the app can seamlessly
 retrieve and modify game data for specific teams.
 */
final class GameManager {
    static let shared = GameManager()
    
    private init() {} // TO DO - Will need to use something else than singleton
    
    /**
     Returns a specific game document reference from Firestore.
     - Parameters:
        - teamDocId: The ID of the team document to which the game belongs.
        - gameId: The unique ID of the game document.
     - Returns:
        A `DocumentReference` pointing to the specific game document in Firestore.
        This reference can be used to perform CRUD operations on the game document.
     */
    func gameDocument(teamDocId: String, gameId: String) -> DocumentReference {
        return gameCollection(teamDocId: teamDocId).document(gameId)
    }
      
    
    /**
     Returns the game collection reference for a specific team.
     - Parameters:
        - teamDocId: The ID of the team document that contains the games collection.
     - Returns:
        A `CollectionReference` that refers to the "games" collection in Firestore for the given team.
        This reference allows for querying and adding games to the collection.
     */
    func gameCollection(teamDocId: String) -> CollectionReference {
        return TeamManager.shared.teamCollection.document(teamDocId).collection("games")
    }
    
    
    /**
     Retrieves a specific game document from Firestore based on the game ID and team ID.
     - Parameters:
        - gameId: The unique identifier of the game document.
        - teamId: The unique identifier of the team to which the game belongs.
     - Returns:
        An optional `DBGame` object representing the game retrieved from Firestore, or `nil` if the game cannot be found.
        The function throws an error if there's an issue retrieving the document.
     */
    func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        return try await gameDocument(teamDocId: teamDocId, gameId: gameId).getDocument(as: DBGame.self)
    }
    
    
    /**
     Retrieves a specific game document from Firestore using its document ID and the team document ID.
     - Parameters:
        - gameDocId: The unique document ID of the game to retrieve.
        - teamDocId: The unique ID of the team document containing the game document.
     - Returns:
        An optional `DBGame` object representing the game retrieved from Firestore, or `nil` if the game cannot be found.
        The function throws an error if there's an issue retrieving the document.
     */
    func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame? {
        return try await gameDocument(teamDocId: teamDocId, gameId: gameDocId).getDocument(as: DBGame.self)
    }
    
    
    /**
     Retrieves all games for a specific team from Firestore.
     - Parameters:
        - teamId: The unique identifier of the team whose games are to be retrieved.
     - Returns:
        An optional array of `DBGame` objects representing all the games found for the given team, or `nil` if no games are found.
        The function throws an error if the retrieval process encounters an issue.
     */
    func getAllGames(teamId: String) async throws -> [DBGame]? {
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        let snapshot = try await gameCollection(teamDocId: teamDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBGame.self)
        }

    }
                
    
    /**
     Adds a new game to Firestore based on the provided `GameDTO`.
     - Parameters:
        - gameDTO: The data transfer object (`GameDTO`) containing the details of the game to be added.
     - Returns:
        This function does not return a value. It performs an asynchronous operation that adds the new game to Firestore.
        The function throws an error if there is an issue while adding the game.
     */
    func addNewGame(gameDTO: GameDTO) async throws {
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: gameDTO.teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }
        let gameDocument = gameCollection(teamDocId: teamDocId).document()
        let documentId = gameDocument.documentID // get the document id
        
        // Create a new game object
        let game = DBGame(gameId: documentId, gameDTO: gameDTO)

        // Create a new game
        try gameDocument.setData(from: game, merge: false)
    }
    
    
    /**
     Adds a new "Unknown Game" (a game with default values) to Firestore for a given team.
     - Parameters:
        - teamId: The unique identifier of the team for which the unknown game is to be created.
     - Returns:
        A string representing the `gameId` of the newly created "Unknown Game" if successful, or `nil` if the creation failed.
        This function throws an error if there's an issue during the process.
     */
    func addNewUnkownGame(teamId: String) async throws -> String? {
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team doc id. Aborting")
            return nil
        }
        
        let gameDocument = gameCollection(teamDocId: teamDocId).document()
        let documentId = gameDocument.documentID // get the document id
        
        // Create a new default game object
        let game = DBGame(gameId: documentId, teamId: teamId)
        
        // Create a new game
        try gameDocument.setData(from: game, merge: false)
        print("Successfully created new game, gameId: \(documentId)")
        
        return documentId // return the game_id
    }
    
    
    /**
     Updates the duration of a specific game in Firestore.
     - Parameters:
        - gameId: The unique identifier of the game whose duration needs to be updated.
        - teamDocId: The ID of the team document that owns the game.
        - duration: The new duration (in seconds) to set for the game.
     - Returns:
        This function does not return a value. It performs an asynchronous operation that updates the game’s duration in Firestore.
        It throws an error if the update operation fails.
     */
    func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws {
        let data: [String:Any] = [
            DBGame.CodingKeys.duration.rawValue: duration
        ]
        
        try await gameDocument(teamDocId: teamDocId, gameId: gameId).updateData(data as [AnyHashable: Any])
    }
}
