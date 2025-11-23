//
//  PlayerManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-21.
//

import XCTest
@testable import GameFrameIOSShared

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
        
        do {
            // Make sure the new player to be added does not exist
            _ = try await manager.getPlayer(playerId: playerId)
        } catch PlayerError.playerNotFound {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Add a new player
        let playerDTO = PlayerDTO(
            playerId: playerId,
            gender: "Male",
            profilePicture: nil,
            teamsEnrolled: ["team_123"],
            guardianName: nil,
            guardianEmail: nil,
            guardianPhone: nil
        )
        try await manager.createNewPlayer(playerDTO: playerDTO)
        let player = try await manager.getPlayer(playerId: playerId)
        
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId, "Player ID should match")
        XCTAssertEqual(player?.gender, playerDTO.gender)
        XCTAssertEqual(player?.profilePicture, playerDTO.profilePicture)
        XCTAssertEqual(player?.teamsEnrolled, playerDTO.teamsEnrolled)
        XCTAssertEqual(player?.guardianName, playerDTO.guardianName)
        XCTAssertEqual(player?.guardianEmail, playerDTO.guardianEmail)
        XCTAssertEqual(player?.guardianPhone, playerDTO.guardianPhone)
    }
    
    func testGetPlayer() async throws {
        let playerId = "uid002"
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId, "Player ID should match")
    }
    
    func testFindPlayerWithId() async throws {
        let playerDocId = "uidP001"
        
        let player = try await manager.findPlayerWithId(id: playerDocId)
        
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.id, playerDocId, "Player ID should match")
    }
    
    func testUpdateGuardianName() async throws {
        let playerDocId = "uidP001"
        let updatedGuardianName = "Johnny Doe"
        
        // Make sure the player has a different guardian name setup
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player?.guardianName, updatedGuardianName)
        XCTAssertNotNil(player?.playerId)

        // Update the guardian name
        try await manager.updateGuardianName(id: playerDocId, name: updatedGuardianName)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)
        
        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Guardian Name should match")
    }
    
    func testRemoveGuardianInfo() async throws {
        let playerDocId = "uidP001"
        
        // Make sure guardian info is not set to nil initially
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotEqual(player?.guardianName, nil)
        XCTAssertNotEqual(player?.guardianEmail, nil)
        XCTAssertNotEqual(player?.guardianPhone, nil)
        
        // Remove guardian info
        try await manager.removeGuardianInfo(id: playerDocId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)
        
        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, nil)
        XCTAssertEqual(updatedPlayer?.guardianEmail, nil)
        XCTAssertEqual(updatedPlayer?.guardianPhone, nil)
    }
    
    func testAddTeamToPlayer() async throws {
        let teamId = "team_123"
        let playerDocId = "uidP001"
        
        // Make sure team adding to player does not exist
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotNil(player?.playerId)

        let isPlayerEnrolledtoTeam = try await manager.isPlayerEnrolledToTeam(playerId: player!.playerId!, teamId: teamId)
        XCTAssertFalse(isPlayerEnrolledtoTeam)
        
        // Adding a team to the player
        try await manager.addTeamToPlayer(id: playerDocId, teamId: teamId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)
        
        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId, "Player ID should match")
        XCTAssertTrue(
            updatedPlayer?.teamsEnrolled?.contains(teamId) ?? false,
            "A team should have been added under the player"
        )
    }
    
    func testRemoveTeamFromPlayer() async throws {
        let teamId = "team1"
        let playerDocId = "uidP001"
        
        // Make sure the team we are removing is under teams enrolled
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotNil(player?.playerId)

        let isPlayerEnrolledToTeam = try await manager.isPlayerEnrolledToTeam(playerId: player!.playerId!, teamId: teamId)
        XCTAssertTrue(isPlayerEnrolledToTeam)

        // Remove team from player
        try await manager.removeTeamFromPlayer(id: playerDocId, teamId: teamId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer, "Updated Player should not be nil")
        XCTAssertEqual(updatedPlayer?.id, playerDocId, "Player ID should match")
        XCTAssertFalse(
            updatedPlayer?.teamsEnrolled?.contains(teamId) ?? true,
            "A team should have been removed under the player"
        )
    }
    
    func testRemoveTeamFromPlayerWithTeamDocId() async throws {
        let playerId = "uid002"
        
        // Make sure the player exist
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first(where: { $0.teamId == player?.teamsEnrolled?.first }) else { return }
        guard let jsonTeam = try await createTeamForJSON(for: TeamManager(repo: LocalTeamRepository()), team: sampleTeam) else {
            XCTFail("Team should exist")
            return
        }
                
        // Remove team from player with document id
        try await manager.removeTeamFromPlayerWithTeamDocId(id: player!.id, teamDocId: jsonTeam.id)
        let updatedPlayer = try await manager.getPlayer(playerId: playerId)
        
        XCTAssertEqual(updatedPlayer?.playerId, playerId, "Player ID should match")
        XCTAssertTrue(updatedPlayer?.teamsEnrolled?.count == 0)
        XCTAssertFalse(
            updatedPlayer?.teamsEnrolled?.contains(sampleTeam.teamId) ?? true,
            "A team should have been removed under the player"
        )
    }
    
    func testRemoveGuardianInfoName() async throws {
        let playerDocId = "uidP001"
        
        // Make sure the guardian info name is not nil initially
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player?.guardianName, nil)
        XCTAssertNotNil(player?.playerId)

        // Remove guardian name info
        try await manager.removeGuardianInfoName(id: playerDocId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, nil, "Guardian Name should be set to nil")
        XCTAssertEqual(updatedPlayer?.playerId, player?.playerId)
    }
    
    func testRemoveGuardianInfoEmail() async throws {
        let playerDocId = "uidP001"
        
        // Make sure the guardian info email is not nil initially
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player?.guardianEmail, nil)
        XCTAssertNotNil(player?.playerId)

        // Remove guardian email info
        try await manager.removeGuardianInfoEmail(id: playerDocId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId)
        XCTAssertEqual(updatedPlayer?.playerId, player?.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianEmail, nil, "Guardian Email should be set to nil")
    }
    
    func testRemoveGuardianInfoPhone() async throws {
        let playerDocId = "uidP001"
        
        // Make sure the guardian info phone is not nil initially
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player?.guardianPhone, nil)
        XCTAssertNotNil(player?.playerId)

        // Remove guardian phone info
        try await manager.removeGuardianInfoPhone(id: playerDocId)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId)
        XCTAssertEqual(updatedPlayer?.playerId, player?.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianPhone, nil, "Guardian Phone should be set to nil")
    }
    
    func testUpdatePlayerInfo() async throws {
        let playerDocId = "uidP001"
        let updatedGuardianName = "Hugo Loris"
        let updatedGender = "Female"
        let updatedJersey = 24
        
        // Make sure the updated player's info does not match the player's info initially
        guard var player = try await manager.findPlayerWithId(id: playerDocId) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player.guardianName, updatedGuardianName)
        XCTAssertNotEqual(player.gender, updatedGender)
        XCTAssertNotNil(player.playerId)
        
        // Update the player's info
        player.guardianName = updatedGuardianName
        player.gender = updatedGender

        try await manager.updatePlayerInfo(player: player)
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId)
        XCTAssertEqual(updatedPlayer?.playerId, player.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Player's Guardian Name should match")
        XCTAssertEqual(updatedPlayer?.gender, updatedGender, "Player Gender should match")
    }
    
    func testUpdatePlayerSetting() async throws {
        let playerDocId = "uidP001"
        let updatedJersey = 34
        let updatedNickname = "Cyn"
        let updatedGuardianName = "Ronn Bronco"
        let updatedGuardianEmail = "ronn@gmail.com"
        let updatedGuardianPhone = "7180986789"
        let updatedGender = "Female"

        // Make sure the updated player's info does not match the player's info initially
        guard var player = try await manager.findPlayerWithId(id: playerDocId) else {
            XCTFail()
            return
        }
        XCTAssertNotNil(player)
        XCTAssertNotEqual(player.gender, updatedGender)
        XCTAssertNotEqual(player.guardianName, updatedGuardianName)
        XCTAssertNotEqual(player.guardianEmail, updatedGuardianEmail)
        XCTAssertNotEqual(player.guardianPhone, updatedGuardianPhone)
        XCTAssertNotNil(player.playerId)

        // Update the player info
        try await manager.updatePlayerSettings(
            id: playerDocId,
            guardianName: updatedGuardianName,
            guardianEmail: updatedGuardianEmail,
            guardianPhone: updatedGuardianPhone,
            gender: updatedGender
        )
        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId)
        XCTAssertEqual(updatedPlayer?.playerId, player.playerId, "Player ID should match")
        XCTAssertEqual(updatedPlayer?.gender, updatedGender, "Updated Player Gender should match")
        XCTAssertEqual(updatedPlayer?.guardianName, updatedGuardianName, "Updated Guardian Name should match")
        XCTAssertEqual(updatedPlayer?.guardianEmail, updatedGuardianEmail, "Updated Guardian Email should match")
        XCTAssertEqual(updatedPlayer?.guardianPhone, updatedGuardianPhone, "Updated Guardian Phone should match")
    }
    
//    func testUpdatePlayerJerseyAndNickname() async throws {
//        let playerDocId = "uidP001"
//        let updatedJersey = 34
//        let updatedNickname = "Cyn"
//        
//        // Make sure the player's jersey and nickname are different
//        let player = try await manager.findPlayerWithId(id: playerDocId)
//        XCTAssertNotNil(player)
////        XCTAssertNotEqual(player?.jerseyNum, updatedJersey)
////        XCTAssertNotEqual(player?.nickName, updatedNickname)
//        XCTAssertNotNil(player?.playerId)
//
//        // Update the player's jersey number and nickname
//        try await manager.updatePlayerJerseyAndNickname(
//            playerDocId: playerDocId,
//            jersey: updatedJersey,
//            nickname: updatedNickname
//        )
//        let updatedPlayer = try await manager.findPlayerWithId(id: playerDocId)
//        
//        XCTAssertNotNil(updatedPlayer)
//        XCTAssertEqual(updatedPlayer?.id, playerDocId)
//        XCTAssertEqual(updatedPlayer?.playerId, player?.playerId, "Player ID should match")
//    }
    
    func testUpdatedPlayerId() async throws {
        let playerDocId = "uidP001"
        
        // Make sure the player exist before changing the player_id
        let player = try await manager.findPlayerWithId(id: playerDocId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.id, playerDocId)

        // Update the player's id
        let updatedPlayerId = "player_456"
        try await manager.updatePlayerId(id: playerDocId, playerId: updatedPlayerId)
        let updatedPlayer = try await manager.getPlayer(playerId: updatedPlayerId)
        
        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.id, playerDocId)
        XCTAssertEqual(updatedPlayer?.playerId, updatedPlayerId, "Updated Player ID should match")
    }
    
    func testGetTeamsEnrolled() async throws {
        let playerId = "uid002"
        
        // Make sure the player exist
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)
        XCTAssertTrue(player?.teamsEnrolled?.count == 1)

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        guard let sampleTeam = sampleTeams.first(where: { $0.teamId == player?.teamsEnrolled?.first }) else { return }
        guard try await createTeamForJSON(for: TeamManager(repo: LocalTeamRepository()), team: sampleTeam) != nil else {
            XCTFail("Team should exist")
            return
        }
        
        // Get the teams enrolled
        let teamsEnrolled = try await manager.getTeamsEnrolled(playerId: playerId)
        
        XCTAssertEqual(teamsEnrolled.count, 1)
        XCTAssertEqual(teamsEnrolled.count, player?.teamsEnrolled?.count)
        XCTAssertEqual(teamsEnrolled[0].teamId, sampleTeam.teamId, "Team ID of the enrolled team should match")
    }
    
    func testGetAllTeamsEnrolled() async throws {
        let playerId = "uid005"
        
        // Make sure the player exist
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)
        XCTAssertTrue(player?.teamsEnrolled?.count == 2)

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        let enrolledTeams = sampleTeams.filter { $0.players!.contains(playerId) }
        
        let teamManager = TeamManager(repo: LocalTeamRepository())
        for team in enrolledTeams {
            try await createTeamForJSON(for: teamManager, team: team)
        }
        
        // Get all teams enrolled
        let teamsEnrolled = try await manager.getAllTeamsEnrolled(playerId: playerId)
        
        XCTAssertTrue(
            teamsEnrolled?.first?.players?.contains(playerId) ?? false,
            "Team enrolled should contain the player ID"
        )
        XCTAssertEqual(teamsEnrolled?.count, 2)
        XCTAssertEqual(teamsEnrolled?.count, player?.teamsEnrolled?.count)
    }
        
    func testPlayerIsEnrolledToTeam() async throws {
        let playerId = "uid005"
        
        // Make sure the player exist
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)
        XCTAssertTrue(player?.teamsEnrolled?.count == 2)

        // Check if the player is enrolled to a team or not
        let isPlayerEnrolledToTeam = try await manager.isPlayerEnrolledToTeam(playerId: playerId, teamId: player!.teamsEnrolled!.first!)
        XCTAssertTrue(isPlayerEnrolledToTeam, "Player should be enrolled to a team")
    }

    // MARK: Negative Testing
    
    func testFindPlayerWithInvalidId() async throws {
        let invalidPlayerId = "player_123"
        
        do {
            // Make sure the new player to be added does not exist
            _ = try await manager.findPlayerWithId(id: invalidPlayerId)
        } catch PlayerError.playerNotFound {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetPlayerWithInvalidPlayerId() async {
        let invalidPlayerId = "player123"
        
        do {
            // Make sure the new player to be added does not exist
            _ = try await manager.getPlayer(playerId: invalidPlayerId)
        } catch PlayerError.playerNotFound {
            // Error catched
            print("AuthError.noAuthenticatedUser error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
            
    func testRemoveInvalidTeamFromPlayer() async throws {
        let playerId = "uid005"

        // Make sure the player can be found
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)
        XCTAssertTrue(player?.teamsEnrolled?.count == 2)

        // Remove an invalid team from player
        let invalidTeamId = "team_123"
        try await manager.removeTeamFromPlayer(id: player!.id, teamId: invalidTeamId)
        let updatedPlayer = try await manager.getPlayer(playerId: playerId)

        XCTAssertNotNil(updatedPlayer)
        XCTAssertEqual(updatedPlayer?.playerId, playerId)
        XCTAssertEqual(updatedPlayer?.teamsEnrolled?.count, player?.teamsEnrolled?.count)
        XCTAssertFalse(updatedPlayer?.teamsEnrolled?.contains(invalidTeamId) ?? true)
    }
                    
    func testPlayerNotEnrolledToTeam() async throws {
        let playerId = "uid011"
        
        // Double check that the player exist
        let player = try await manager.getPlayer(playerId: playerId)
        XCTAssertNotNil(player)
        XCTAssertEqual(player?.playerId, playerId)
        XCTAssertNotNil(player?.playerId)
        XCTAssertTrue(player?.teamsEnrolled?.count == 1)

        // Check if the player is enrolled to a team or not
        let teamIdNotEnrolled = "team2"
        let isPlayerEnrolledToTeam = try await manager.isPlayerEnrolledToTeam(playerId: playerId, teamId: teamIdNotEnrolled)
        XCTAssertFalse(isPlayerEnrolledToTeam, "Player should not be enrolled to a team")
    }
}
