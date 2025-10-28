//
//  TeamMembershipPlanTests.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-23.
//

import XCTest
@testable import GameFrameIOSShared

final class LocalTeamMembershipPlanRepositoryTests: XCTestCase {

    var manager: TeamMembershipPlanManager!
    var localRepo: LocalTeamMembershipPlanRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalTeamMembershipPlanRepository()
        manager = TeamMembershipPlanManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
    
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure @escaping () async throws -> T,
        _ message: @autoclosure () -> String = "",
        _ errorHandler: (_ error: Error) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }


    func testAddAndGetMembershipPlan() async throws {
        
        // Load one sample plan from JSON
        let samplePlans: [DBTeamMembershipPlan] = TestDataLoader.load("TestTeamMembershipPlans", as: [DBTeamMembershipPlan].self)
        guard let samplePlan = samplePlans.first else { return }
        
        // Add using the JSON fields (repo will generate a new planId)
        try await manager.addMembershipPlan(teamId: samplePlan.teamId,
                                              name: samplePlan.name,
                                              price: samplePlan.price,
                                              benefits: samplePlan.benefits,
                                              durationInMonths: samplePlan.durationInMonths)
        // Fetch all for that team
        let all = try await manager.getAllMembershipPlans(teamId: samplePlan.teamId)
        XCTAssertEqual(all.count, 1)

        // Verify fields
        let plan = try XCTUnwrap(all.first)
        XCTAssertEqual(plan.name, samplePlan.name)
        XCTAssertEqual(plan.price, samplePlan.price, accuracy: 0.0001)
        XCTAssertEqual(plan.benefits, samplePlan.benefits)
        XCTAssertEqual(plan.durationInMonths, samplePlan.durationInMonths)

        // Fetch by (teamId, planId) — use the ID that was created by the repo
        let createdPlanId = plan.planId
        let fetched = try await manager.getMembershipPlan(teamId: samplePlan.teamId, planId: createdPlanId)
        XCTAssertEqual(fetched?.planId, createdPlanId)
    }

    func testGetAllMembershipPlansFiltersByTeam() async throws {
        // Load sample plans from JSON
        let samplePlans: [DBTeamMembershipPlan] = TestDataLoader.load(
            "TestTeamMembershipPlans",
            as: [DBTeamMembershipPlan].self
        )
        XCTAssertFalse(samplePlans.isEmpty, "Expected TestTeamMembershipPlans.json to have items")

        // Pick two teams to test filtering (either fixed ids or derive from the JSON)
        // If your JSON contains "team-A" / "team-B", keep as-is; otherwise pick two distinct teamIds from JSON:
        let uniqueTeams = Array(Set(samplePlans.map { $0.teamId }))
        XCTAssertGreaterThanOrEqual(uniqueTeams.count, 2, "Need at least two teams in JSON to test filtering")

        let teamA = uniqueTeams[0]
        let teamB = uniqueTeams[1]

        // Seed: add only plans belonging to teamA or teamB
        for plan in samplePlans where plan.teamId == teamA || plan.teamId == teamB {
            try await manager.addMembershipPlan(
                teamId: plan.teamId,
                name: plan.name,
                price: plan.price,
                benefits: plan.benefits,
                durationInMonths: plan.durationInMonths
            )
        }

        // Act
        let plansA = try await manager.getAllMembershipPlans(teamId: teamA)
        let plansB = try await manager.getAllMembershipPlans(teamId: teamB)

        // Expected names for each team from the JSON
        let expectedA = samplePlans
            .filter { $0.teamId == teamA }
            .map(\.name)
            .sorted()

        let expectedB = samplePlans
            .filter { $0.teamId == teamB }
            .map(\.name)
            .sorted()

        // Assert: repo returns only plans for the requested team
        XCTAssertEqual(plansA.map(\.name).sorted(), expectedA)
        XCTAssertEqual(plansB.map(\.name).sorted(), expectedB)
    }


    func testUpdateMembershipPlanPersistsChanges() async throws {
        // Load a sample plan from JSON and use its values as the baseline
        let samplePlans: [DBTeamMembershipPlan] = TestDataLoader.load("TestTeamMembershipPlans",
                                                                      as: [DBTeamMembershipPlan].self)
        let sample = try XCTUnwrap(samplePlans.first, "Expected at least one sample plan")

        // Seed repo with one plan using JSON fields (repo will generate a new planId)
        try await manager.addMembershipPlan(teamId: sample.teamId,
                                              name: sample.name,
                                              price: sample.price,
                                              benefits: sample.benefits,
                                              durationInMonths: sample.durationInMonths)

        // Grab the created plan id
        var all = try await manager.getAllMembershipPlans(teamId: sample.teamId)
        XCTAssertEqual(all.count, 1)
        let createdPlan = try XCTUnwrap(all.first)
        let createdPlanId = createdPlan.planId

        // Act: update some fields; keep duration nil to ensure it remains unchanged
        let newName = sample.name + " Plus"
        let newPrice = sample.price + 4.99
        let newBenefits = sample.benefits + ["Chat Q&A"]

        try await manager.updateMembershipPlan(teamId: sample.teamId,
                                                 planId: createdPlanId,
                                                 name: newName,
                                                 price: newPrice,
                                                 benefits: newBenefits,
                                                 durationInMonths: nil)

        // Assert: fetch again and verify persisted changes
        all = try await manager.getAllMembershipPlans(teamId: sample.teamId)
        let updated = try XCTUnwrap(all.first(where: { $0.planId == createdPlanId }))

        XCTAssertEqual(updated.name, newName)
        XCTAssertEqual(updated.price, newPrice, accuracy: 0.0001)
        XCTAssertEqual(updated.benefits, newBenefits)
        XCTAssertEqual(updated.durationInMonths, sample.durationInMonths) // unchanged
    }

    func testRemoveMembershipPlan() async throws {
        let plans: [DBTeamMembershipPlan] = TestDataLoader.load("TestTeamMembershipPlans", as: [DBTeamMembershipPlan].self)
        let sample = try XCTUnwrap(plans.first)

        // Seed two for the same team
        try await manager.addMembershipPlan(teamId: sample.teamId, name: sample.name, price: sample.price, benefits: sample.benefits, durationInMonths: sample.durationInMonths)
        try await manager.addMembershipPlan(teamId: sample.teamId, name: sample.name + " 2", price: sample.price + 10, benefits: sample.benefits, durationInMonths: sample.durationInMonths)

        var all = try await manager.getAllMembershipPlans(teamId: sample.teamId)
        XCTAssertEqual(all.count, 2)

        let planIdToRemove = try XCTUnwrap(all.first(where: { $0.name == sample.name })?.planId)
        try await manager.removeMembershipPlan(teamId: sample.teamId, planId: planIdToRemove)

        all = try await manager.getAllMembershipPlans(teamId: sample.teamId)
        XCTAssertEqual(all.count, 1)
        XCTAssertFalse(all.contains(where: { $0.planId == planIdToRemove }))
    }


    func testUpdateNonexistentPlanDoesNotCrash() async throws {
        let teamId = "team-A"

        await XCTAssertThrowsErrorAsync(
            try await self.manager.updateMembershipPlan(teamId: teamId,
                                                     planId: "nope",
                                                     name: "X",
                                                     price: 1,
                                                     benefits: [],
                                                     durationInMonths: 1)
        )

        // And still nothing exists
        let all = try await manager.getAllMembershipPlans(teamId: teamId)
        XCTAssertEqual(all.count, 0)
    }

    func testRemoveNonexistentPlanDoesNotCrash() async throws {
        let teamId = "team-A"
        try await manager.removeMembershipPlan(teamId: teamId, planId: "does-not-exist")
        let all = try await manager.getAllMembershipPlans(teamId: teamId)
        XCTAssertEqual(all.count, 0)
    }
}
