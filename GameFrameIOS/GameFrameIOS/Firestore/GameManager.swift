//
//  GameManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import Foundation
import FirebaseFirestore

struct DBGame: Codable {
    let id: String
    let title: String
    let duration: Date?
    let location: String?
    let scheduledTime: Date?
    let startTime: Date?
    let timeBeforeFeedback: Date
    let timeAfterFeedback: Date
    let recordingReminder: Bool
    let teamId: String
    
    init(id: String, title: String, duration: Date? = nil, location: String? = nil, scheduledTime: Date? = nil, startTime: Date? = nil, timeBeforeFeedback: Date, timeAfterFeedback: Date, recordingReminder: Bool, teamId: String) {
        self.id = id
        self.title = title
        self.duration = duration
        self.location = location
        self.scheduledTime = scheduledTime
        self.startTime = startTime
        self.timeBeforeFeedback = timeBeforeFeedback
        self.timeAfterFeedback = timeAfterFeedback
        self.recordingReminder = recordingReminder
        self.teamId = teamId
    }
    
    init(id: String, teamId: String) {
        self.id = id
        self.title = ""
        self.duration = nil
        self.location = nil
        self.scheduledTime = nil
        self.startTime = nil
        self.timeBeforeFeedback = Date()
        self.timeAfterFeedback = Date()
        self.recordingReminder = false
        self.teamId = teamId
    }
}

final class GameManager {
    static let shared = GameManager()
    
    private init() {} // TO DO - Will need to use something else than singleton
    
    private let gameCollection = Firestore.firestore().collection("games") // games collection
    
    /** Returns a specific game document */
    private func gameDocument(gameId: String) -> DocumentReference {
        gameCollection.document(gameId)
    }
    
    /** Add a new game in the database */
    func addNewGame(game: DBGame) async throws {
        
    }
}
