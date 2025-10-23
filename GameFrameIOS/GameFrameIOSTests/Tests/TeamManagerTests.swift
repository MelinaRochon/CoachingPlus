//
//  TeamManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-22.
//

import XCTest
@testable import GameFrameIOS

final class TeamManagerTests: XCTestCase {
    var manager: TeamManager!
    var localRepo: LocalTeamRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalTeamRepository()
        manager = TeamManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }

    func testGetTeam() async throws {
        let teamId = "team1"
        let team = try await manager.getTeam(teamId: teamId)
        XCTAssertNotNil(team, "Team should exist")
        XCTAssertEqual(team?.teamId, teamId, "Team ID should match")
    }
    
    func testGetAllTeams() async throws {
        let teamIds = ["team1", "team2", "team3"]
        let getTeams = try await manager.getAllTeams(teamIds: teamIds)
        XCTAssertEqual(getTeams.first?.teamId, teamIds.first, "Team ID should match")
        XCTAssertEqual(getTeams.count, teamIds.count)
    }
    
    func testGetTeamWithDocId() async throws {
        let teamDocId = "uidT001"
        let team = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertNotNil(team, "Team should not be nil")
        XCTAssertEqual(team.id, teamDocId, "Team doc ID should match")
    }
    
    func testGetTeamsWithCoach() async throws {
        let coachId = "uid001"
        let teamsWithCoach = try await manager.getTeamsWithCoach(coachId: coachId)
        XCTAssertEqual(teamsWithCoach.count, 2, "Team coaching should be equal to 2")
        XCTAssertEqual(teamsWithCoach.first?.coaches.first, coachId, "Coach ID should match")
    }
    
    func testGetTeamWithAccessCode() async throws {
        let accessCode = "123456"
        let teamWithAccessCode = try await manager.getTeamWithAccessCode(accessCode: accessCode)
        XCTAssertEqual(teamWithAccessCode?.teamId, "team2", "Team id should match")
        XCTAssertEqual(teamWithAccessCode?.accessCode, accessCode, "Access code should match")
    }
    
    func testGetTeamName() async throws {
        let teamId = "team1"
        let teamName = try await manager.getTeamName(teamId: teamId)
        XCTAssertEqual(teamName, "Blue Comets")
    }
    
    func testAddPlayerToTeam() async throws {
        let teamId = "team1"
        let playerIdToAdd = "uid005"
        try await manager.addPlayerToTeam(id: teamId, playerId: playerIdToAdd)
        let updatedTeam = try await manager.getTeam(teamId: teamId)
        XCTAssertEqual(updatedTeam?.players?.count, 3, "Player count should be equal to 3")
        XCTAssertTrue(updatedTeam?.players?.contains(playerIdToAdd) ?? false, "Player ID should have been added to the team roster")
    }
    
    func testIsPlayerOnTeam_true() async throws {
        let teamId = "team1"
        let playerId = "uid002"
        let isPlayerOnTeam = try await manager.isPlayerOnTeam(id: teamId, playerId: playerId)
        XCTAssertTrue(isPlayerOnTeam, "Player should be on the team")
    }
    
    func testIsPlayerOnTeam_false() async throws {
        let teamId = "team1"
        let playerId = "uid005"
        let isPlayerOnTeam = try await manager.isPlayerOnTeam(id: teamId, playerId: playerId)
        XCTAssertFalse(isPlayerOnTeam, "Player should not be on the team")
    }
    
    func testGetTeamRosterLength() async throws {
        let teamId = "team1"
        let rosterLength = try await manager.getTeamRosterLength(teamId: teamId)
        XCTAssertEqual(rosterLength, 2, "Roster length should be equal to 2")
    }
    
    func testRemovePlayerFromTeam() async throws {
        let teamDocId = "uidT001"
        let playerId = "uid002"
        try await manager.removePlayerFromTeam(id: teamDocId, playerId: playerId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.players?.count, 1, "Player count should be equal to 1")
        XCTAssertFalse(updatedTeam.players?.contains(playerId) ?? false, "Player ID should not be present in the team roster")
    }
    
    func testAddCoachToTeam() async throws {
        let teamDocId = "uidT001"
        let coachId = "uid004"
        try await manager.addCoachToTeam(id: teamDocId, coachId: coachId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.coaches.count, 2, "Coach count should be equal to 2")
        XCTAssertTrue(updatedTeam.coaches.contains(coachId), "Coach ID should be present in the team roster")
    }
    
    func testAddInviteToTeam() async throws {
        let teamDocId = "uidT001"
        let inviteDocId = "inviteUid_1"
        try await manager.addInviteToTeam(id: teamDocId, inviteDocId: inviteDocId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.invites?.count, 1, "Invite count should be equal to 1")
        XCTAssertTrue(updatedTeam.invites?.contains(inviteDocId) ?? false, "Invite ID should be present in the team roster")
    }
    
    func testGetInviteDocIdOfPlayerAndTeam() async throws {
        let teamDocId = "uidT003"
        let playerId = "uidI001"
        
        let inviteDocId = try await manager.getInviteDocIdOfPlayerAndTeam(teamDocId: teamDocId, playerDocId: playerId)
        XCTAssertNotNil(inviteDocId, "Invite should not be nil")
        XCTAssertEqual(inviteDocId, playerId)
    }
    
    func testRemoveInviteFromTeam() async throws {
        let teamDocId = "uidT003"
        let inviteId = "uidI001"
        try await manager.removeInviteFromTeam(id: teamDocId, inviteDocId: inviteId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.invites?.count, 1, "Invite count should be equal to 1")
        XCTAssertFalse(updatedTeam.invites?.contains(inviteId) ?? true, "Invite ID should not be present in the team roster")
    }
    
    func testRemoveCoachFromTeam() async throws {
        let teamDocId = "uidT001"
        let coachId = "uid001"
        try await manager.removeCoachFromTeam(id: teamDocId, coachId: coachId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.coaches.count, 0, "Coach count should be equal to 0")
        XCTAssertFalse(updatedTeam.coaches.contains(coachId), "Coach ID should not be present in the team roster")
    }
    
    func testAddNewTeam() async throws {
        let coachId = "uid001"
        let teamId = "team_1"
        let teamDTO = TeamDTO(
            teamId: teamId,
            name: "Real Madrid CF",
            teamNickname: "RMA",
            sport: "soccer",
            logoUrl: nil,
            colour: nil,
            gender: "Male",
            ageGrp: "U18+",
            accessCode: "r3ealIsTheB3st",
            coaches: ["uid001"],
            players: ["uid005"],
            invites: []
        )
        
        try await manager.createNewTeam(coachId: coachId, teamDTO: teamDTO)
        let team = try await manager.getTeam(teamId: teamId)
        XCTAssertNotNil(team, "Team should exist")
        XCTAssertEqual(team?.teamId, teamId, "Team ID should match")
    }
    
    func testTeamExists() async throws {
        let teamId = "team1"
        let exists = try await manager.doesTeamExist(teamId: teamId)
        XCTAssertTrue(exists, "Team should exist")
    }
    
    func testTeamDoesNotExists() async throws {
        let teamId = "team_1"
        let exists = try await manager.doesTeamExist(teamId: teamId)
        XCTAssertFalse(exists, "Team should exist")
    }
    
    func testUpdateTeamSettings() async throws {
        let teamDocId = "uidT001"
        let name = "Real Madrid CF"
        let nickname = "RMA"
        try await manager.updateTeamSettings(id: teamDocId, name: name, nickname: nickname, ageGrp: "U18+", gender: "Male")
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.name, name, "Team name should match")
        XCTAssertEqual(updatedTeam.teamNickname, nickname, "Team nickname should match")
    }
    
    func testDeleteTeam() async throws {
        let teamDocId = "uidT001"
        let teamId = "team1"
        try await manager.deleteTeam(id: teamDocId)
        let team = try await manager.getTeam(teamId: teamId)
        XCTAssertNil(team, "Team should not exist")
    }

    // MARK: Negative Testing
    
    func testGetInvalidTeam() async throws {
        let teamId = "team_123"
        let team = try await manager.getTeam(teamId: teamId)
        XCTAssertNil(team, "Team should not exist")
    }
    
    func testGetAllTeamsWithInvalidTeam() async throws {
        let teamIds = ["team1", "team_2", "team3"]
        let getTeams = try await manager.getAllTeams(teamIds: teamIds)
        XCTAssertNotEqual(getTeams.count, teamIds.count, "Team count should not match as there's an invalid team ID")
    }
    
    func testGetTeamsWithInvalidCoach() async throws {
        let coachId = "id_coach1"
        let teamsWithCoach = try await manager.getTeamsWithCoach(coachId: coachId)
        XCTAssertEqual(teamsWithCoach.count, 0, "Team coaching should be equal to 0")
    }

    func testGetTeamWithInvalidAccessCode() async throws {
        let accessCode = "accesscode_123"
        let teamWithAccessCode = try await manager.getTeamWithAccessCode(accessCode: accessCode)
        XCTAssertNil(teamWithAccessCode, "Team should be nil")
    }
    
    func testRemoveInvalidPlayerFromTeam() async throws {
        let teamDocId = "uidT001"
        let playerId = "uid019"
        try await manager.removePlayerFromTeam(id: teamDocId, playerId: playerId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.players?.count, 2, "Player count should be equal to 2")
        XCTAssertFalse(updatedTeam.players?.contains(playerId) ?? false, "Player ID should not be present in the team roster")
    }
    
    func negTestAddSameCoachToTeam() async throws {
        let teamDocId = "uidT001"
        let coachId = "uid001"
        try await manager.addCoachToTeam(id: teamDocId, coachId: coachId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.coaches.count, 1, "Coach count should be equal to 1")
    }
    
    func negtestAddSameInviteToTeam() async throws {
        let teamDocId = "uidT003"
        let inviteDocId = "uidI001"
        let team = try await manager.getTeamWithDocId(docId: teamDocId)
        try await manager.addInviteToTeam(id: teamDocId, inviteDocId: inviteDocId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.invites?.count, team.invites?.count, "Invite count should be equal to 2")
        XCTAssertTrue(updatedTeam.invites?.contains(inviteDocId) ?? false, "Invite ID should be present in the team roster")
    }

    func testGetInviteDocIdOfInvalidPlayerAndTeam() async throws {
        let teamDocId = "uidT003"
        let playerId = "uidI009"
        
        let inviteDocId = try await manager.getInviteDocIdOfPlayerAndTeam(teamDocId: teamDocId, playerDocId: playerId)
        XCTAssertNil(inviteDocId, "Invite for this player should not exist")
    }
    
    func testRemoveInvalidInviteFromTeam() async throws {
        let teamDocId = "uidT003"
        let inviteId = "uidI009"
        try await manager.removeInviteFromTeam(id: teamDocId, inviteDocId: inviteId)
        let updatedTeam = try await manager.getTeamWithDocId(docId: teamDocId)
        XCTAssertEqual(updatedTeam.invites?.count, 2, "Invite count should be equal to 1")
        XCTAssertFalse(updatedTeam.invites?.contains(inviteId) ?? true, "Invite ID should not be present in the team roster")
    }
}
