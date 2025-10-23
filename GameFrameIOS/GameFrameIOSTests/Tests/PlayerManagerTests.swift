//
//  PlayerManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-21.
//

import XCTest
@testable import GameFrameIOS

final class PlayerManagerTests: XCTestCase {
    var manager: PlayerManager!
    var localRepo: LocalPlayerRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalPlayerRepository()
        manager = PlayerManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
    
    func testAddPlayer() async throws {
        let playerId = "player_123"
        
        // Add a player
        let playerDTO = PlayerDTO(playerId: playerId, jerseyNum: 12, nickName: "Nick", gender: "Male", profilePicture: nil, teamsEnrolled: ["team_123"], guardianName: nil, guardianEmail: nil, guardianPhone: nil)
        let player = try await createPlayer(for: manager, playerDTO: playerDTO, playerId: playerId)
        
        XCTAssertNotNil(player, "Player should exist after being added")
        XCTAssertEqual(player?.playerId, playerId, "Player ID should match")
    }
    
    func testGetPlayer() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let player = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        XCTAssertEqual(player.playerId, samplePlayer.playerId, "Player ID should match")
    }
    
    func testFindPlayerWithId() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        let player = try await manager.findPlayerWithId(id: jsonPlayer.id)
        
        XCTAssertNotNil(player, "Player added should not be nil")
        XCTAssertEqual(player?.playerId, jsonPlayer.playerId, "Player ID should match")
    }
    
    func testUpdateGuardianName() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        let updatedGuardianName = "Johnny Doe"
        try await manager.updateGuardianName(id: jsonPlayer.id, name: updatedGuardianName)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Guardian Name should match")
    }
    
    func testRemoveGuardianInfo() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        try await manager.removeGuardianInfo(id: jsonPlayer.id)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, nil, "Guardian Name should be set to nil")
        XCTAssertEqual(updatedPlayer?.guardianEmail, nil, "Guardian Email should be set to nil")
        XCTAssertEqual(updatedPlayer?.guardianPhone, nil, "Guardian Phone should be set to nil")
    }
    
    func testAddTeamToPlayer() async throws {
        let teamId = "team_123"
        
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        // Adding a team to the player
        try await manager.addTeamToPlayer(id: jsonPlayer.id, teamId: teamId)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertTrue(updatedPlayer?.teamsEnrolled?.contains(teamId) ?? false, "A team should have been added under the player")
    }
    
    func testRemoveTeamFromPlayer() async throws {
        let teamId = "team1"
        
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.teamsEnrolled!.contains(teamId) }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Remove team from player
        try await manager.removeTeamFromPlayer(id: jsonPlayer.id, teamId: teamId)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)

        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertFalse(updatedPlayer?.teamsEnrolled?.contains(teamId) ?? true, "A team should have been removed under the player")
    }
    
    func testRemoveTeamFromPlayerWithTeamDocId() async throws {
        // Load player & Team from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first(where: { $0.teamId == jsonPlayer.teamsEnrolled?.first }) else { return }
        guard let jsonTeam = try await createTeamForJSON(for: TeamManager(), team: sampleTeam) else {
            XCTFail("Team should exist")
            return
        }
                
        // Remove team from player with document id
        try await manager.removeTeamFromPlayerWithTeamDocId(id: jsonPlayer.id, teamDocId: jsonTeam.id)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertFalse(updatedPlayer?.teamsEnrolled?.contains(sampleTeam.teamId) ?? true, "A team should have been removed under the player")
    }
    
    func testRemoveGuardianInfoName() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.guardianName != nil }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        // Remove guardian name info
        try await manager.removeGuardianInfoName(id: jsonPlayer.id)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, nil, "Guardian Name should be set to nil")
    }
    
    func testRemoveGuardianInfoEmail() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.guardianEmail != nil }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Remove guardian phone info
        try await manager.removeGuardianInfoEmail(id: jsonPlayer.id)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianEmail, nil, "Guardian Email should be set to nil")
    }
    
    func testRemoveGuardianInfoPhone() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.guardianPhone != nil }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Remove guardian phone info
        try await manager.removeGuardianInfoPhone(id: jsonPlayer.id)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianPhone, nil, "Guardian Phone should be set to nil")
    }
    
    func testUpdatePlayerInfo() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard var jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Update player info
        let updatedGuardianName = "Hugo Loris"
        let updatedGender = "Female"
        let updatedJersey = 24
        
        jsonPlayer.guardianName = updatedGuardianName
        jsonPlayer.gender = updatedGender
        jsonPlayer.jerseyNum = updatedJersey

        try await manager.updatePlayerInfo(player: jsonPlayer)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Player's Guardian Name should match")
        XCTAssertEqual(updatedPlayer?.gender, updatedGender, "Player Gender should match")
        XCTAssertEqual(updatedPlayer?.jerseyNum, updatedJersey, "Player Jersey number should match")
    }
    
    func testUpdatePlayerSetting() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Update player info
        let updatedJersey = 34
        let updatedNickname = "Cyn"
        let updatedGuardianName = "Ronn Bronco"
        let updatedGuardianEmail = "ronn@gmail.com"
        let updatedGuardianPhone = "7180986789"
        let updatedGender = "Female"
        
        try await manager.updatePlayerSettings(id: jsonPlayer.id, jersey: updatedJersey, nickname: updatedNickname, guardianName: updatedGuardianName, guardianEmail: updatedGuardianEmail, guardianPhone: updatedGuardianPhone, gender: updatedGender)
        
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Updated Player ID should match")
        XCTAssertEqual(updatedPlayer?.jerseyNum, updatedJersey, "Updated Jersey number should match")
        XCTAssertEqual(updatedPlayer?.nickName, updatedNickname, "Updated Player Nickname should match")
        XCTAssertEqual(updatedPlayer?.gender, updatedGender, "Updated Player Gender should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Updated Guardian Name should match")
        XCTAssertEqual(updatedPlayer?.guardianEmail, updatedGuardianEmail, "Updated Guardian Email should match")
        XCTAssertEqual(updatedPlayer?.guardianPhone, updatedGuardianPhone, "Updated Guardian Phone should match")
    }
    
    func testUpdatePlayerJerseyAndNickname() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Update player info
        let updatedJersey = 34
        let updatedNickname = "Cyn"
        
        try await manager.updatePlayerJerseyAndNickname(playerDocId: jsonPlayer.id, jersey: updatedJersey, nickname: updatedNickname)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId!, "Updated Player ID should match")
        XCTAssertEqual(updatedPlayer?.jerseyNum, updatedJersey, "Updated Jersey number should match")
        XCTAssertEqual(updatedPlayer?.nickName, updatedNickname, "Updated Player Nickname should match")
    }
    
    func testUpdatedPlayerId() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Update player info
        let updatedPlayerId = "player_456"
        try await manager.updatePlayerId(id: jsonPlayer.id, playerId: updatedPlayerId)
        let updatedPlayer = try await manager.getPlayer(playerId: updatedPlayerId)
        
        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, updatedPlayerId, "Updated Player ID should match")
    }
    
    func testGetTeamsEnrolled() async throws {
        // Load player & Team from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first(where: { $0.teamId == jsonPlayer.teamsEnrolled?.first }) else { return }
        guard let jsonTeam = try await createTeamForJSON(for: TeamManager(), team: sampleTeam) else {
            XCTFail("Team should exist")
            return
        }

        let teamsEnrolled = try await manager.getTeamsEnrolled(playerId: jsonPlayer.playerId!)
        
        XCTAssertEqual(teamsEnrolled.count, 1)
        XCTAssertEqual(teamsEnrolled[0].teamId, sampleTeam.teamId, "Team ID of the enrolled team should match")
    }
    
    func testGetAllTeamsEnrolled() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        let enrolledTeams = sampleTeams.filter { $0.players!.contains(jsonPlayer.playerId!) }
        
        let teamManager = TeamManager()
        for team in enrolledTeams {
            try await createTeamForJSON(for: teamManager, team: team)
        }
        
        let teamsEnrolled = try await manager.getAllTeamsEnrolled(playerId: jsonPlayer.playerId!)
        
        XCTAssertTrue(teamsEnrolled?.first?.players?.contains(samplePlayer.playerId!) ?? false, "Team enrolled should contain the player ID")
    }
        
    func testPlayerIsEnrolledToTeam() async throws {
        let teamId = "team1"
        
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.teamsEnrolled!.contains(teamId) }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
                
        let isPlayerEnrolledToTeam = try await manager.isPlayerEnrolledToTeam(playerId: jsonPlayer.playerId!, teamId: teamId)
        XCTAssertTrue(isPlayerEnrolledToTeam, "Player should be enrolled to a team")
    }

    // MARK: Negative Testing
    
    func testFindPlayerWithInvalidId() async throws {
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        let invalidPlayerId = "player_123"
        let player = try await manager.findPlayerWithId(id: invalidPlayerId)
        
        XCTAssertNil(player, "Player added should be nil")
    }
            
    func testRemoveInvalidTeamFromPlayer() async throws {
        let teamId = "team1"
        
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.teamsEnrolled!.contains(teamId) }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        // Remove team from player
        let invalidTeamId = "team_123"
        try await manager.removeTeamFromPlayer(id: jsonPlayer.id, teamId: invalidTeamId)
        let updatedPlayer = try await manager.getPlayer(playerId: jsonPlayer.playerId!)

        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.playerId, samplePlayer.playerId, "Player ID should match")
        XCTAssertTrue(updatedPlayer?.teamsEnrolled?.contains(teamId) ?? false, "A team could not be removed under the player")
    }
            
    func testGetInvalidTeamsEnrolled() async throws {
        // Load player & Team from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }
        
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first(where: { $0.teamId == jsonPlayer.teamsEnrolled?.first }) else { return }
        guard let jsonTeam = try await createTeamForJSON(for: TeamManager(), team: sampleTeam) else {
            XCTFail("Team should exist")
            return
        }
        
        // Get teams enrolled with an invalid player id
        let teamsEnrolled = try await manager.getTeamsEnrolled(playerId: "player_123")
        XCTAssertEqual(teamsEnrolled, [], "Team enrolled should be empty")
    }
        
    func testPlayerNotEnrolledToTeam() async throws {
        let teamId = "team_123"
        
        // Load players from JSON test file
        let samplePlayers: [DBPlayer] = TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
        guard let samplePlayer = samplePlayers.first(where: { $0.teamsEnrolled!.contains(teamId) }) else { return }
        guard let jsonPlayer = try await createPlayerForJSON(for: manager, player: samplePlayer) else {
            XCTFail("User should exist")
            return
        }

        let isPlayerEnrolledToTeam = try await manager.isPlayerEnrolledToTeam(playerId: jsonPlayer.playerId!, teamId: teamId)
        XCTAssertFalse(isPlayerEnrolledToTeam, "Player should not be enrolled to a team")
    }
}
