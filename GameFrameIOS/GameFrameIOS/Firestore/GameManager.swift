//
//  GameManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import Foundation
import FirebaseFirestore

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
        self.title = ""
        self.duration = 0 // by default, 0 seconds
        self.location = nil
        self.scheduledTimeReminder = 0 // by default, 0 minutes
        self.startTime = nil
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

final class GameManager {
    static let shared = GameManager()
    
    private init() {} // TO DO - Will need to use something else than singleton
        
    /** Returns a specific game document */
    func gameDocument(teamDocId: String, gameId: String) -> DocumentReference {
        return gameCollection(teamDocId: teamDocId).document(gameId)
    }
        
    func gameCollection(teamDocId: String) -> CollectionReference {
        return TeamManager.shared.teamCollection.document(teamDocId).collection("games")
    }
    
    /** GET - Returns the game information from the database */
    func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        return try await gameDocument(teamDocId: teamDocId, gameId: gameId).getDocument(as: DBGame.self)
    }
    
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
            
    private func getTeamID(teamName: String) async throws -> String {
        // TO DO - Fetch the team ID from the database
        return "zzlZyozdFYaQeUR5gsr7"
    }
    
    /** Add a new game in the database */
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
}
