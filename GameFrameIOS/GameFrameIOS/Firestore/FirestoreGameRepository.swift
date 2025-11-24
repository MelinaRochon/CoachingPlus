//
//  FirestoreGameRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreGameRepository: GameRepository {
    
    /// Returns a reference to a specific game document within a team’s "games" collection.
    public func gameDocument(teamDocId: String, gameId: String) -> DocumentReference {
        return gameCollection(teamDocId: teamDocId).document(gameId)
    }
      
    /// Returns a reference to the "games" collection for the specified team.
    public func gameCollection(teamDocId: String) -> CollectionReference {
        let teamRepo = FirestoreTeamRepository()
        return teamRepo.teamCollection().document(teamDocId).collection("games")
    }
    
    
    public func getGame(gameId: String, teamId: String) async throws -> DBGame? {
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        return try await gameDocument(teamDocId: teamDocId, gameId: gameId).getDocument(as: DBGame.self)
    }
    
    
    public func getGameWithDocId(gameDocId: String, teamDocId: String) async throws -> DBGame? {
        return try await gameDocument(teamDocId: teamDocId, gameId: gameDocId).getDocument(as: DBGame.self)
    }
    

    public func deleteAllGames(teamDocId: String) async throws {
        let keyMomentManager = LocalKeyMomentRepository()
        let transcriptManager = LocalTranscriptRepository()
        
        let collectionRef = gameCollection(teamDocId: teamDocId)
        let snapshot = try await collectionRef.getDocuments()
        
        for document in snapshot.documents {
            // Delete all key moments
            try await keyMomentManager.deleteAllKeyMoments(teamDocId: teamDocId, gameId: document.documentID)
            
            // Delete all transcripts
            try await transcriptManager.deleteAllTranscripts(teamDocId: teamDocId, gameId: document.documentID)

            try await collectionRef.document(document.documentID).delete()
        }
    }
    

    public func getAllGames(teamId: String) async throws -> [DBGame]? {
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        let snapshot = try await gameCollection(teamDocId: teamDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBGame.self)
        }

    }
                
    
    public func addNewGame(gameDTO: GameDTO) async throws {
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: gameDTO.teamId)?.id else {
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
    
    
    public func addNewUnkownGame(teamId: String) async throws -> String? {
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
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
    
    
    public func updateGameDurationUsingTeamDocId(gameId: String, teamDocId: String, duration: Int) async throws {
        let data: [String:Any] = [
            DBGame.CodingKeys.duration.rawValue: duration
        ]
        
        try await gameDocument(teamDocId: teamDocId, gameId: gameId).updateData(data as [AnyHashable: Any])
    }
    
    
    public func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws {
        let data: [String:Any] = [
            DBGame.CodingKeys.title.rawValue: title
        ]
        try await gameDocument(teamDocId: teamDocId, gameId: gameId).updateData(data as [AnyHashable: Any])
    }
    
    
    public func updateScheduledGameSettings(
        id: String,
        teamDocId: String,
        title: String?,
        startTime: Date?,
        duration: Int?,
        timeBeforeFeedback: Int?,
        timeAfterFeedback: Int?,
        recordingReminder: Bool?,
        location: String?,
        scheduledTimeReminder: Int?
    ) async throws {
        
        // Find game
        guard let game = try await getGameWithDocId(gameDocId: id, teamDocId: teamDocId) else {
            print("Unable to get the game details")
            return
        }
        
        var data: [String: Any] = [:]
        if let title = title {
            data[DBGame.CodingKeys.title.rawValue] = title
        }
        if let startTime = startTime {
            data[DBGame.CodingKeys.startTime.rawValue] = startTime
        }
        if let duration = duration {
            data[DBGame.CodingKeys.duration.rawValue] = duration
        }
        if let timeBeforeFeedback = timeBeforeFeedback {
            data[DBGame.CodingKeys.timeBeforeFeedback.rawValue] = timeBeforeFeedback
        }
        if let timeAfterFeedback = timeAfterFeedback {
            data[DBGame.CodingKeys.timeAfterFeedback.rawValue] = timeAfterFeedback
        }
        if let recordingReminder = recordingReminder {
            data[DBGame.CodingKeys.recordingReminder.rawValue] = recordingReminder
        }
        if let location = location {
            data[DBGame.CodingKeys.location.rawValue] = location
        }
        if let scheduledTimeReminder = scheduledTimeReminder {
            data[DBGame.CodingKeys.scheduledTimeReminder.rawValue] = scheduledTimeReminder
        }
                
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update")
            return
        }
        
        // Update the scheduled game document
        try await gameDocument(teamDocId: teamDocId, gameId: id).updateData(data as [AnyHashable : Any])
    }
    
    
    public func deleteGame(gameId: String, teamDocId: String) async throws {
        try await gameDocument(teamDocId: teamDocId, gameId: gameId).delete()
    }
    
    
    public func updateGameStartTimeUsingTeamDocId(gameId: String, teamDocId: String, startTime: Date) async throws {
        let data: [String:Any] = [
            DBGame.CodingKeys.startTime.rawValue: startTime
        ]
        // Update the scheduled game document
        try await gameDocument(teamDocId: teamDocId, gameId: gameId).updateData(data as [AnyHashable : Any])
    }
    
    func getRecentGames(teamDocId: String, limit: Int = 10) async throws -> [DBGame] {
        let query = gameCollection(teamDocId: teamDocId)
            .order(by: "start_time", descending: true)
            .limit(to: limit)

        let snapshot = try await query.getDocuments()
        
        let games = snapshot.documents.compactMap { try? $0.data(as: DBGame.self) }

        return games
    }

    
    func fetchRecentGames(teamDocId: String, limit: Int = 20) async throws -> ([DBGame], DocumentSnapshot?) {
        let query = gameCollection(teamDocId: teamDocId)
            .order(by: "start_time", descending: true)
            .limit(to: limit)

        let snapshot = try await query.getDocuments()
        
        let games = snapshot.documents.compactMap { try? $0.data(as: DBGame.self) }
        let lastDoc = snapshot.documents.last      // Save this for pagination

        return (games, lastDoc)
    }
    
    func fetchMoreGames(after lastDoc: DocumentSnapshot, teamDocId: String, limit: Int = 20) async throws -> ([DBGame], DocumentSnapshot?) {
        let db = Firestore.firestore()

        let query = gameCollection(teamDocId: teamDocId)
            .order(by: "start_time", descending: true)
            .start(afterDocument: lastDoc)
            .limit(to: limit)

        let snapshot = try await query.getDocuments()

        let games = snapshot.documents.compactMap { try? $0.data(as: DBGame.self) }
        let newLastDoc = snapshot.documents.last

        return (games, newLastDoc)
    }
}
