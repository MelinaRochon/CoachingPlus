//
//  GameManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-23.
//

import XCTest
@testable import GameFrameIOS

final class GameManagerTests: XCTestCase {
    var manager: GameManager!
    var localRepo: LocalGameRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalGameRepository()
        manager = GameManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }

    func testGetGame() async throws {
        let gameId = "G001"
        let teamId = "team1"
        
        let game = try await manager.getGame(gameId: gameId, teamId: teamId)
        XCTAssertNotNil(game, "Game should exist")
        XCTAssertEqual(game?.teamId, teamId, "Team ID should match")
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
    }
    
    func testGetGameWithDocId() async throws {
        let gameDocId = "G001"
        let teamDocId = "uidT001"
        let game = try await manager.getGameWithDocId(gameDocId: gameDocId, teamDocId: teamDocId)
        XCTAssertNotNil(game, "Game should exist")
        XCTAssertEqual(game?.gameId, gameDocId, "Game ID should match")
    }
    
    func testDeleteAllGames() async throws {
        // Load teams from JSON file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first else { return }
        guard let team = try await createTeamForJSON(for: TeamManager(), team: sampleTeam) else {
            XCTFail("Team should exist")
            return
        }
        try await manager.deleteAllGames(teamDocId: team.id)
        let games = try await manager.getAllGames(teamId: team.teamId)
        XCTAssertTrue(games?.isEmpty ?? false, "All games should be deleted")
    }
    
    func testGetAllGames() async throws {
        let teamId = "team1"
        let games = try await manager.getAllGames(teamId: teamId)
        XCTAssertEqual(games?.first?.teamId, teamId, "Team ID should match")
        XCTAssertEqual(games?.count, 3, "Number of games should be 3")
    }
    
    func testAddNewUnknownGame() async throws {
        let teamId = "team_123"
        let gameId = try await manager.addNewUnkownGame(teamId: teamId)
        let game = try await manager.getGame(gameId: gameId!, teamId: teamId)
        XCTAssertNotNil(game, "Game should exist")
        XCTAssertEqual(game?.teamId, teamId, "Team ID should match")
        XCTAssertEqual(game?.gameId, gameId!, "Game ID should match")
    }
    
    func testUpdateGamedurationUsingTeamDocId() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let duration = 100
        try await manager.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: teamDocId, duration: duration)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
        XCTAssertEqual(game?.duration, duration, "Game duration should match")
    }
    
    func testUpdateGameTitle() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let tile = "Canada vs USA"
        try await manager.updateGameTitle(gameId: gameId, teamDocId: teamDocId, title: tile)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
        XCTAssertEqual(game?.title, tile, "Game title should match")
    }
    
    func testUpdateScheduledGameSettings() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let title = "Canada vs USA"
        let startTime = Date()
        let duration = 3600
        let timeBeforeFeedback = 10
        let timeAfterFeedback = 10
        let recordingReminder = false
        let location: String? = nil
        let scheduledTimeReminder = 0
        
        let gameBeforeUpdate = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        try await manager.updateScheduledGameSettings(id: gameId, teamDocId: teamDocId, title: title, startTime: startTime, duration: duration, timeBeforeFeedback: timeBeforeFeedback, timeAfterFeedback: timeAfterFeedback, recordingReminder: recordingReminder, location: location, scheduledTimeReminder: scheduledTimeReminder)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
        XCTAssertEqual(game?.title, title, "Game title should match")
        XCTAssertEqual(game?.startTime, startTime, "Game start time should match")
        XCTAssertEqual(game?.duration, duration, "Game duration should match")
        XCTAssertEqual(game?.timeBeforeFeedback, timeBeforeFeedback, "Game time before feedback should match")
        XCTAssertEqual(game?.timeAfterFeedback, timeAfterFeedback, "Game time after feedback should match")
        XCTAssertEqual(game?.recordingReminder, recordingReminder, "Game recording reminder should match")
        XCTAssertEqual(game?.location, gameBeforeUpdate?.location, "Game location should not have changed and should match")
        XCTAssertEqual(game?.scheduledTimeReminder, scheduledTimeReminder, "Game scheduled time reminder should match")
    }
    
    func testDeleteGame() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        try await manager.deleteGame(gameId: gameId, teamDocId: teamDocId)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertNil(game, "Game should not exist")
    }
    
    // MARK: Negative Testing
    
    func testGetInvalidGame() async throws {
        let gameId = "G040"
        let teamId = "team1"
        
        let game = try await manager.getGame(gameId: gameId, teamId: teamId)
        XCTAssertNil(game, "Game should not exist")
    }
    
    func testGetGameWithInvalidDocId() async throws {
        let gameDocId = "G040"
        let teamDocId = "team1"
        let game = try await manager.getGameWithDocId(gameDocId: gameDocId, teamDocId: teamDocId)
        XCTAssertNil(game, "Game should not exist")
    }
}
