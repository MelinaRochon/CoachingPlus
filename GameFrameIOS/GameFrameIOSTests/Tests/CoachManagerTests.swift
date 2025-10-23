//
//  CoachManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-21.
//

import XCTest
@testable import GameFrameIOS

final class CoachManagerTests: XCTestCase {
    var manager: CoachManager! // system under test
    var localRepo: LocalCoachRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalCoachRepository()
        manager = CoachManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
        
    /// Tests that adding a new coach successfully stores it in the local repository.
    func testAddNewCoach() async throws {
        let coachId = "coach_123"
        
        // Make sure the new coach to be added does not exist
        let tmpCoach = try await manager.getCoach(coachId: coachId)
        XCTAssertNil(tmpCoach, "Coach should not exist before being added")
        
        // Add a new coach
        let coach = try await createCoach(for: manager, coachId: coachId)
        XCTAssertNotNil(coach)
        XCTAssertEqual(coach?.coachId, coachId)
    }
    
    /// Tests that getting a coach can be successfully performed.
    func testGetCoach() async throws {
        let coachId = "uid001"
        
        // Get the coach object
        if let coach = try await manager.getCoach(coachId: coachId) {
            XCTAssertEqual(coach.coachId, coachId, "Coach ID should match")
        } else {
            XCTFail("Coach should exist")
        }
    }
    
    /// Tests that adding a team to an existing coach correctly updates the coach’s record.
    func testAddTeamToCoach() async throws {
        let coachId = "uid001"
        let teamId = "team123"
        
        // Make sure the coach exists and the team was not added already
        let coach = try await manager.getCoach(coachId: coachId)
        XCTAssertNotNil(coach)
        XCTAssertEqual(coach?.coachId, coachId)
        XCTAssertFalse(
            coach?.teamsCoaching?.contains(teamId) ?? true,
            "The team should not exist under the coach."
        )

        // Add team to the teams coaching
        try await manager.addTeamToCoach(coachId: coachId, teamId: teamId)
        let updatedCoach = try await manager.getCoach(coachId: coachId)
        
        XCTAssertNotNil(updatedCoach)
        XCTAssertEqual(updatedCoach?.coachId, coachId)
        XCTAssertTrue(
            updatedCoach?.teamsCoaching?.contains(teamId) ?? false,
            "A team should have been added under the coach."
        )
        XCTAssertTrue(updatedCoach?.teamsCoaching?.count == 3)
    }
    
    /// Tests that removing a team to an existing coach correctly updates the coach's record.
    func testRemoveTeamToCoach() async throws {
        let coachId = "uid001"
        let teamId = "team1"
        
        // Make sure the team to be removed is there
        let coach = try await manager.getCoach(coachId: coachId)
        XCTAssertNotNil(coach)
        XCTAssertEqual(coach?.coachId, coachId)
        XCTAssertTrue(coach?.teamsCoaching?.contains(teamId) ?? false)

        // Remove team to the teams coaching
        try await manager.removeTeamToCoach(coachId: coachId, teamId: teamId)
        let updatedCoach = try await manager.getCoach(coachId: coachId)
        
        XCTAssertNotNil(updatedCoach)
        XCTAssertEqual(updatedCoach?.coachId, coachId)
        XCTAssertFalse(
            updatedCoach?.teamsCoaching?.contains(teamId) ?? true,
            "The team should not exist under the coach."
        )
        XCTAssertTrue(updatedCoach?.teamsCoaching?.count == 1)
    }
    
    func testLoadTeamsCoaching() async throws {
        let coachId = "uid001" // UUID found in "TestTeams" JSON file
        
        // Make sure the coach is actively coaching at least one team
        let coach = try await manager.getCoach(coachId: coachId)
        XCTAssertNotNil(coach)
        XCTAssertEqual(coach?.coachId, coachId)
        XCTAssertGreaterThanOrEqual(coach?.teamsCoaching?.count ?? 0, 1)
        
        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        XCTAssertNotNil(sampleTeams)
        XCTAssertTrue(sampleTeams.count == 3)

        // Add each team to the coach
        for team in sampleTeams {
            if team.coaches.contains(coachId) {
                try await TeamManager().createNewTeam(
                    coachId: coachId,
                    teamDTO: TeamDTO(
                        teamId: team.teamId,
                        name: team.name,
                        teamNickname: team.teamNickname,
                        sport: team.sport,
                        logoUrl: nil,
                        colour: nil,
                        gender: team.gender,
                        ageGrp: team.ageGrp,
                        accessCode: team.accessCode,
                        coaches: team.coaches,
                        players: team.players,
                        invites: team.invites
                    )
                )
                try await manager.addTeamToCoach(coachId: coachId, teamId: team.teamId)
            }
        }
         
        // Load the teams coaching
        let loadedTeams = try await manager.loadTeamsCoaching(coachId: coachId)
        
        XCTAssertNotNil(loadedTeams)
        XCTAssertEqual(
            loadedTeams?.first?.teamId,
            sampleTeams.first(where: { $0.coaches.contains(coachId) })?.teamId
        )
    }
    
    func testAllTeamsCoaching() async throws {
        let coachId = "uid001" // UUID found in "TestTeams" JSON file
        
        // Make sure the coach is actively coaching at least one team
        let coach = try await manager.getCoach(coachId: coachId)
        XCTAssertNotNil(coach)
        XCTAssertEqual(coach?.coachId, coachId)
        XCTAssertGreaterThanOrEqual(coach?.teamsCoaching?.count ?? 0, 1)

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        XCTAssertNotNil(sampleTeams)
        XCTAssertTrue(sampleTeams.count == 3)

        // Add each team to the coach
        let teamManager = TeamManager()
        for team in sampleTeams {
            if team.coaches.contains(coachId) {
                try await teamManager.createNewTeam(
                    coachId: coachId,
                    teamDTO: TeamDTO(
                        teamId: team.teamId,
                        name: team.name,
                        teamNickname: team.teamNickname,
                        sport: team.sport,
                        logoUrl: nil,
                        colour: nil,
                        gender: team.gender,
                        ageGrp: team.ageGrp,
                        accessCode: team.accessCode,
                        coaches: team.coaches,
                        players: team.players,
                        invites: team.invites
                    )
                )
                try await manager.addTeamToCoach(coachId: coachId, teamId: team.teamId)
            }
        }
        
        // Load the teams coaching
        let loadedTeams = try await manager.loadTeamsCoaching(coachId: coachId)
        
        XCTAssertNotNil(loadedTeams)
        XCTAssertEqual(
            loadedTeams?.first?.teamId,
            sampleTeams.first(where: { $0.coaches.contains(coachId) })?.teamId
        )
    }
    
    // MARK: Negative Testing
    
    /// Tests that getting a coach can be successfully performed.
    func testGetInvalidCoach() async throws {
        // Get the coach object
        let invalidCoachId = "invalid_coach_id"
        let coach = try await manager.getCoach(coachId: invalidCoachId)
        XCTAssertNil(coach, "Coach should not exist because of the invalid coach ID")
    }
}
