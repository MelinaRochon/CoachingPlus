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
        
        // Add a coach
        let coach = try await createCoach(for: manager, coachId: coachId)
        
        XCTAssertNotNil(coach, "Coach should exist after being added")
        XCTAssertEqual(coach?.coachId, coachId)
    }
    
    /// Tests that getting a coach can be successfully performed.
    func testGetCoach() async throws {
        let coachId = "coach_123"
        
        // Add a new coach
        try await manager.addCoach(coachId: coachId)
        
        // Get the coach object
        if let coach = try await manager.getCoach(coachId: coachId) {
            XCTAssertEqual(coach.coachId, coachId, "Coach ID should match")
        } else {
            XCTFail("Coach should exist")
        }
    }
    
    /// Tests that adding a team to an existing coach correctly updates the coach’s record.
    func testAddTeamToCoach() async throws {
        let coachId = "coach123"
        let teamId = "team123"
                
        // Add a coach
        guard let coach = try await createCoach(for: manager, coachId: coachId) else {
            XCTFail("Coach should exist")
            return
        }
        
        // Add team to coach
        try await manager.addTeamToCoach(coachId: coach.coachId, teamId: teamId)
        let updatedCoach = try await manager.getCoach(coachId: coachId)
        XCTAssertTrue(updatedCoach?.teamsCoaching?.contains(teamId) ?? false, "A team should have been added under the coach.")
    }
    
    /// Tests that removing a team to an existing coach correctly updates the coach's record.
    func testRemoveTeamToCoach() async throws {
        let coachId = "coach123"
        let teamId = "team123"
        
        // Add a coach
        guard let coach = try await createCoach(for: manager, coachId: coachId) else {
            XCTFail("Coach should exist")
            return
        }
        
        // Add team to coach
        try await manager.addTeamToCoach(coachId: coach.coachId, teamId: teamId)
        var updatedCoach = try await manager.getCoach(coachId: coachId)
        XCTAssertTrue(updatedCoach?.teamsCoaching?.contains(teamId) ?? false, "A team should have been added under the coach.")
        
        // Remove team to coach
        try await manager.removeTeamToCoach(coachId: coach.coachId, teamId: teamId)
        updatedCoach = try await manager.getCoach(coachId: coach.coachId)
        XCTAssertFalse(updatedCoach?.teamsCoaching?.contains(teamId) ?? true, "The team should not exist under the coach.")
    }
    
    func testLoadTeamsCoaching() async throws {
        let coachId = "uid001" // UUID found in "TestTeams" JSON file
        guard let coach = try await createCoach(for: manager, coachId: coachId) else {
            XCTFail("Coach should exist")
            return
        }

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        
        
        // Add each team to the coach
        for team in sampleTeams {
            if team.coaches.contains(coach.coachId) {
                try await TeamManager().createNewTeam(
                    coachId: coachId,
                    teamDTO: TeamDTO(teamId: team.teamId, name: team.name, teamNickname: team.teamNickname, sport: team.sport, logoUrl: nil, colour: nil, gender: team.gender, ageGrp: team.ageGrp, accessCode: team.accessCode, coaches: team.coaches, players: team.players, invites: team.invites)
                )
                try await manager.addTeamToCoach(coachId: coach.coachId, teamId: team.teamId)
            }
        }
         
        let loadedTeams = try await manager.loadTeamsCoaching(coachId: coachId)
        
        XCTAssertNotNil(loadedTeams, "loadTeamsCoaching should return at least one team.")
        XCTAssertEqual(
            loadedTeams?.first?.teamId,
            sampleTeams.first(where: { $0.coaches.contains(coach.coachId) })?.teamId
        )
    }
    
    func testAllTeamsCoaching() async throws {
        let coachId = "uid001" // UUID found in "TestTeams" JSON file
        guard let coach = try await createCoach(for: manager, coachId: coachId) else {
            XCTFail("Coach should exist")
            return
        }

        // Load teams from JSON test file
        let sampleTeams: [DBTeam] = TestDataLoader.load("TestTeams", as: [DBTeam].self)
        
        
        // Add each team to the coach
        for team in sampleTeams {
            if team.coaches.contains(coach.coachId) {
                try await TeamManager().createNewTeam(
                    coachId: coachId,
                    teamDTO: TeamDTO(teamId: team.teamId, name: team.name, teamNickname: team.teamNickname, sport: team.sport, logoUrl: nil, colour: nil, gender: team.gender, ageGrp: team.ageGrp, accessCode: team.accessCode, coaches: team.coaches, players: team.players, invites: team.invites)
                )
                try await manager.addTeamToCoach(coachId: coach.coachId, teamId: team.teamId)
            }
        }
        
        let loadedTeams = try await manager.loadTeamsCoaching(coachId: coachId)
        
        XCTAssertNotNil(loadedTeams, "loadTeamsCoaching should return at least one team.")
        XCTAssertEqual(
            loadedTeams?.first?.teamId,
            sampleTeams.first(where: { $0.coaches.contains(coach.coachId) })?.teamId
        )
    }
}
