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
        XCTAssertNotNil(game)
        XCTAssertEqual(game?.teamId, teamId, "Team ID should match")
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
    }
    
    func testGetGameWithDocId() async throws {
        let gameDocId = "G001"
        let teamDocId = "uidT001"
        let game = try await manager.getGameWithDocId(gameDocId: gameDocId, teamDocId: teamDocId)
        XCTAssertNotNil(game)
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
        
        // Make sure we have at least one game
        let tmpGames = try await manager.getAllGames(teamId: team.teamId)
        XCTAssertNotNil(tmpGames)
        XCTAssertEqual(tmpGames?.first?.teamId, team.teamId)
        XCTAssertGreaterThan(tmpGames?.count ?? 0, 1)
        
        // Delete all games for that team
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
        
        XCTAssertNotNil(game)
        XCTAssertEqual(game?.teamId, teamId, "Team ID should match")
        XCTAssertEqual(game?.gameId, gameId!, "Game ID should match")
    }
    
    func testUpdateGamedurationUsingTeamDocId() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let duration = 100
        
        // Make sure the new game duration does not match the game duration initially configured
        let tmpGame = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertNotNil(tmpGame)
        XCTAssertEqual(tmpGame?.gameId, gameId)
        XCTAssertNotEqual(tmpGame?.duration, duration)
        
        // Update the game duration
        try await manager.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: teamDocId, duration: duration)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        
        XCTAssertNotNil(game)
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
        XCTAssertEqual(game?.duration, duration, "Game duration should match")
    }
    
    func testUpdateGameTitle() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let tile = "Canada vs USA"
        
        // Make sure the new game title does not match the previous game title
        let tmpGame = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertNotNil(tmpGame)
        XCTAssertEqual(tmpGame?.gameId, gameId)
        XCTAssertNotEqual(tmpGame?.title, tile)
        
        // Update the game title
        try await manager.updateGameTitle(gameId: gameId, teamDocId: teamDocId, title: tile)
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        
        XCTAssertNotNil(tmpGame)
        XCTAssertEqual(game?.gameId, gameId, "Game ID should match")
        XCTAssertEqual(game?.title, tile, "Game title should match")
    }
    
    func testUpdateScheduledGameSettings() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        let title = "Canada vs USA"
        let startTime = Date()
        let duration = 120
        let timeBeforeFeedback = 0
        let timeAfterFeedback = 0
        let recordingReminder = false
        let location: String? = nil
        let scheduledTimeReminder = 0
        
        // Make sure the new settings don't match the previous game settings
        let gameBeforeUpdate = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertNotNil(gameBeforeUpdate)
        XCTAssertEqual(gameBeforeUpdate?.gameId, gameId)
        XCTAssertNotEqual(gameBeforeUpdate?.title, title)
        XCTAssertNotEqual(gameBeforeUpdate?.startTime, startTime)
        XCTAssertNotEqual(gameBeforeUpdate?.duration, duration)
        XCTAssertNotEqual(gameBeforeUpdate?.timeBeforeFeedback, timeBeforeFeedback)
        XCTAssertNotEqual(gameBeforeUpdate?.timeAfterFeedback, timeAfterFeedback)
        XCTAssertNotEqual(gameBeforeUpdate?.recordingReminder, recordingReminder)
        XCTAssertNotEqual(gameBeforeUpdate?.location, location)
        XCTAssertNotEqual(gameBeforeUpdate?.scheduledTimeReminder, scheduledTimeReminder)
        
        // Update the game settings
        try await manager.updateScheduledGameSettings(
            id: gameId,
            teamDocId: teamDocId,
            title: title,
            startTime: startTime,
            duration: duration,
            timeBeforeFeedback: timeBeforeFeedback,
            timeAfterFeedback: timeAfterFeedback,
            recordingReminder: recordingReminder,
            location: location,
            scheduledTimeReminder: scheduledTimeReminder
        )
        let game = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        
        XCTAssertNotNil(game)
        XCTAssertEqual(game?.gameId, gameId)
        XCTAssertEqual(game?.title, title)
        XCTAssertEqual(game?.startTime, startTime)
        XCTAssertEqual(game?.duration, duration)
        XCTAssertEqual(game?.timeBeforeFeedback, timeBeforeFeedback)
        XCTAssertEqual(game?.timeAfterFeedback, timeAfterFeedback)
        XCTAssertEqual(game?.recordingReminder, recordingReminder)
        XCTAssertEqual(game?.location, gameBeforeUpdate?.location)
        XCTAssertEqual(game?.scheduledTimeReminder, scheduledTimeReminder)
    }
    
    func testDeleteGame() async throws {
        let gameId = "G001"
        let teamDocId = "uidT001"
        
        // Make sure the game exist before deletion
        let gameBeforeDeletion = try await manager.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId)
        XCTAssertNotNil(gameBeforeDeletion)
        XCTAssertEqual(gameBeforeDeletion?.gameId, gameId)
        
        // Delete the game
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
