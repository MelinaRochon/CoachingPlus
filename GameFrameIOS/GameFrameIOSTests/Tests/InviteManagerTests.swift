//
//  InviteManagerTests.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-23.
//

import XCTest
@testable import GameFrameIOSShared

final class LocalInviteRepositoryTests: XCTestCase {
    var manager: InviteManager!
    var localRepo: LocalInviteRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalInviteRepository()
        manager = InviteManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        localRepo = nil
        manager = nil
        try super.tearDownWithError()
    }

    func testCreateNewInviteAndGetById() async throws {
        // Arrange
        let dto = InviteDTO(
            userDocId: "user1",
            playerDocId: "player1",
            email: "player@email.com",
            status: "Accepted",
            dateAccepted: Date(),
            teamId: "team1"
        )

        // Act
        let id = try await manager.createNewInvite(inviteDTO: dto)
        let fetched = try await manager.getInvite(id: id)

        // Assert
        let inv = try XCTUnwrap(fetched)
        XCTAssertEqual(inv.id, id)
        XCTAssertEqual(inv.email, dto.email)
        XCTAssertEqual(inv.teamId, dto.teamId)
        XCTAssertEqual(inv.playerDocId, dto.playerDocId)
        XCTAssertEqual(inv.status, dto.status)
    }

    func testGetInviteByEmailAndTeamId() async throws {
        // Load the same fixture the repo uses so we know expected values
        let fixtures: [DBInvite] = TestDataLoader.load("TestInvites", as: [DBInvite].self)
        guard fixtures.count >= 2 else {
            XCTFail("TestInvites.json should contain at least 2 invites for this test.")
            return
        }

        let a = fixtures[0]
        let b = fixtures[1]

        // Act
        let foundA = try await manager.getInviteByEmailAndTeamId(email: a.email, teamId: a.teamId)
        let foundB = try await manager.getInviteByEmailAndTeamId(email: b.email, teamId: b.teamId)
        let notFound = try await manager.getInviteByEmailAndTeamId(email: "nope@example.com", teamId: a.teamId)

        // Assert
        XCTAssertEqual(foundA?.email, a.email)
        XCTAssertEqual(foundA?.teamId, a.teamId)

        XCTAssertEqual(foundB?.email, b.email)
        XCTAssertEqual(foundB?.teamId, b.teamId)

        XCTAssertNil(notFound)
    }


    func testGetInviteByPlayerDocIdAndTeamId() async throws {
        // Load the same fixture the repo uses so we know what's in memory
        let fixtures: [DBInvite] = TestDataLoader.load("TestInvites", as: [DBInvite].self)
        guard let sample = fixtures.first else {
            XCTFail("TestInvites.json must contain at least one invite.")
            return
        }

        // Act: teamDocId is ignored by LocalInviteRepository, so pass any value
        let found = try await manager.getInviteByPlayerDocIdAndTeamId(
            playerDocId: sample.playerDocId,
            teamDocId: "ignored-team"
        )

        // Assert: found by playerDocId; teamDocId is not enforced
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.playerDocId, sample.playerDocId)
        XCTAssertEqual(found?.teamId, sample.teamId)

        // Negative case: unknown playerDocId should return nil
        let notFound = try await manager.getInviteByPlayerDocIdAndTeamId(
            playerDocId: "non-existent-player",
            teamDocId: sample.teamId
        )
        XCTAssertNil(notFound)
    }


    func testUpdateInviteStatus() async throws {
        let existing = try await manager.getInviteByEmailAndTeamId(email: "player9@example.com", teamId: "team3")
        let id = try XCTUnwrap(existing?.id)

        try await manager.updateInviteStatus(id: id, newStatus: "accepted")

        let fetched = try await manager.getInvite(id: id)
        XCTAssertEqual(fetched?.status, "accepted")
    }


    func testDeleteInvite() async throws {
        let fixtures: [DBInvite] = TestDataLoader.load("TestInvites", as: [DBInvite].self)
        let fixture = try XCTUnwrap(fixtures.first, "Expected at least one invite in TestInvites.json")
        let id = fixture.id

        // Sanity check: it should exist in the repo before deletion
        let pre = try await manager.getInvite(id: id)
        XCTAssertNotNil(pre, "Fixture invite should exist before deletion")

        // Act: delete it
        try await manager.deleteInvite(id: id)

        // Assert: it should no longer exist
        let post = try await manager.getInvite(id: id)
        XCTAssertNil(post, "Invite should be deleted")
    }


    func testDeleteNonexistentInvite() async throws {
            do {
                try await manager.deleteInvite(id: "missing")
                XCTFail("Expected deleteInvite to throw, but it did not")
            } catch {
                let ns = error as NSError
                XCTAssertEqual(ns.domain, "InviteRepository")
                XCTAssertEqual(ns.code, 404)
            }
    }
}
