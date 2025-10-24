//
//  KeyMomentManagerTests.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-23.
//

import XCTest
@testable import GameFrameIOS

final class KeyMomentManagerTests: XCTestCase {
    var manager: KeyMomentManager!
    var localRepo: LocalKeyMomentRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalKeyMomentRepository()
        manager = KeyMomentManager(repo: localRepo)
    }
    
    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
    
    // Helper to load the same fixtures the repo uses
    private func loadFixtures() -> [DBKeyMoment] {
        TestDataLoader.load("TestKeyMoments", as: [DBKeyMoment].self)
    }
    
    func testGetKeyMoment() async throws {
        let fixtures = loadFixtures()
        let sample = try XCTUnwrap(fixtures.first, "Need at least one key moment in TestKeyMoments.json")

        let km = try await manager.getKeyMoment(teamId: "ignored",
                                                gameId: sample.gameId,
                                                keyMomentDocId: sample.keyMomentId)
        XCTAssertNotNil(km)
        XCTAssertEqual(km?.gameId, sample.gameId)
        XCTAssertEqual(km?.keyMomentId, sample.keyMomentId)
    }

    func testAssignPlayerToKeyMomentsForEntireTeam() async throws {
        // Arrange: load existing moments from the seeded LocalKeyMomentRepository
            let all = try await manager.getAllKeyMoments(teamId: "ignored", gameId: try XCTUnwrap(loadFixtures().first?.gameId)) ?? []
            let gameId = try XCTUnwrap(all.first?.gameId)

            // Pick a playersCount that actually appears in this game's moments
            let anyCount = try XCTUnwrap(
                all.first(where: { $0.gameId == gameId && ($0.feedbackFor?.isEmpty == false) })?.feedbackFor?.count,
                "No key moments with non-empty feedbackFor in game \(gameId)"
            )

            // Filter the targets by that count
            let preTargets = all.filter { ($0.feedbackFor?.count ?? 0) == anyCount }
            XCTAssertFalse(preTargets.isEmpty, "No key moments matched playersCount \(anyCount) in game \(gameId)")

            let newPlayerId = "p-test-123"

            // Sanity: ensure none already contain the new id (so we can detect a change)
            XCTAssertTrue(
                preTargets.allSatisfy { !($0.feedbackFor ?? []).contains(newPlayerId) },
                "Fixture already contains \(newPlayerId); choose a different id for the test"
            )

            let targetIds = Set(preTargets.map(\.keyMomentId))

            // Act
            try await manager.assignPlayerToKeyMomentsForEntireTeam(
                teamDocId: "ignored",
                gameId: gameId,
                playersCount: anyCount,
                playerId: newPlayerId
            )

            // Assert: every targeted moment now contains the new id
            let post = try await manager.getAllKeyMoments(teamId: "ignored", gameId: gameId) ?? []
            let updatedTargets = post.filter { targetIds.contains($0.keyMomentId) }

            XCTAssertFalse(updatedTargets.isEmpty, "No updated targets found for ids \(targetIds)")
            for m in updatedTargets {
                XCTAssertTrue(
                    (m.feedbackFor ?? []).contains(newPlayerId),
                    "Expected \(m.keyMomentId) to include \(newPlayerId)"
                )
            }
    }
    
    func testGetKeyMomentWithDocId() async throws {
        let fixtures = loadFixtures()
        let sample = try XCTUnwrap(fixtures.first)

        let km = try await manager.getKeyMomentWithDocId(teamDocId: "ignored",
                                                         gameDocId: sample.gameId,
                                                         keyMomentDocId: sample.keyMomentId)
        XCTAssertEqual(km?.keyMomentId, sample.keyMomentId)
        XCTAssertEqual(km?.gameId, sample.gameId)
    }
    
    func testGetAudioUrl() async throws {
        let fixtures = loadFixtures()
        // Find a sample that actually has an audioUrl set
        guard let withAudio = fixtures.first(where: { $0.audioUrl != nil }) else {
            throw XCTSkip("No key moment with audioUrl in TestKeyMoments.json")
        }

        let url = try await manager.getAudioUrl(teamDocId: "ignored",
                                                gameDocId: withAudio.gameId,
                                                keyMomentId: withAudio.keyMomentId)
        XCTAssertEqual(url, withAudio.audioUrl)
    }
    
    func testGetAllKeyMoments() async throws {
        let fixtures = loadFixtures()
                // Choose a game and compute expected count
                let gameId = try XCTUnwrap(fixtures.first?.gameId)
                let expected = fixtures.filter { $0.gameId == gameId }

                let got = try await manager.getAllKeyMoments(teamId: "ignored", gameId: gameId) ?? []
                XCTAssertEqual(got.count, expected.count)
                XCTAssertEqual(Set(got.map(\.keyMomentId)), Set(expected.map(\.keyMomentId)))
    }
    
    func testGetAllKeyMomentsWithTeamDocId() async throws {
        let fixtures = loadFixtures()
        let gameId = try XCTUnwrap(fixtures.first?.gameId)
        let expected = fixtures.filter { $0.gameId == gameId }

        let got = try await manager.getAllKeyMomentsWithTeamDocId(teamDocId: "ignored", gameId: gameId) ?? []
        XCTAssertEqual(got.count, expected.count)
        XCTAssertEqual(Set(got.map(\.keyMomentId)), Set(expected.map(\.keyMomentId)))
    }
    
    func testAddNewKeyMoment() async throws {
        let dto = KeyMomentDTO(
            fullGameId: "f-game-id",
            gameId: "game-x",
            uploadedBy: "user1",
            audioUrl: "link-to-audio",
            frameStart: Date(),
            frameEnd: Date().addingTimeInterval(5),
            feedbackFor: []
        )
        let id = try await manager.addNewKeyMoment(teamId: "team-x", keyMomentDTO: dto)
        let km = try await manager.getKeyMoment(teamId: "team-x", gameId: "game-x", keyMomentDocId: try XCTUnwrap(id))
        XCTAssertEqual(km?.gameId, "game-x")
        XCTAssertEqual(km?.uploadedBy, "user1")
    }
    
    func testRemoveKeyMoment() async throws {
        let fixtures = loadFixtures()
        let sample = try XCTUnwrap(fixtures.first)

        // Ensure it exists
        let before = try await manager.getAllKeyMoments(teamId: "ignored", gameId: sample.gameId) ?? []
        XCTAssertTrue(before.contains { $0.keyMomentId == sample.keyMomentId })

        // Act
        try await manager.removeKeyMoment(teamId: "ignored", gameId: sample.gameId, keyMomentId: sample.keyMomentId)

        // Assert it's gone
        let after = try await manager.getAllKeyMoments(teamId: "ignored", gameId: sample.gameId) ?? []
        XCTAssertFalse(after.contains { $0.keyMomentId == sample.keyMomentId })
    }
    
    func testAddPlayerToFeedbackFor() async throws {
        let fixtures = loadFixtures()
        // Choose one with a feedback array (or treat as empty)
        let sample = try XCTUnwrap(fixtures.first)
        let newPlayer = "new-player-42"

        // Act
        try await manager.addPlayerToFeedbackFor(teamDocId: "ignored",
                                                 gameId: sample.gameId,
                                                 keyMomentId: sample.keyMomentId,
                                                 newPlayerId: newPlayer)

        // Assert
        let km = try await manager.getKeyMoment(teamId: "ignored",
                                                gameId: sample.gameId,
                                                keyMomentDocId: sample.keyMomentId)
        XCTAssertTrue(km?.feedbackFor?.contains(newPlayer) ?? false)
    }
    
    func testDeleteAllKeyMoments() async throws {
        let fixtures = loadFixtures()
        let gameId = try XCTUnwrap(fixtures.first?.gameId)

        // Precondition
        let pre = try await manager.getAllKeyMoments(teamId: "ignored", gameId: gameId) ?? []
        XCTAssertFalse(pre.isEmpty, "Fixture should contain key moments for this game")

        // Act
        try await manager.deleteAllKeyMoments(teamDocId: "ignored", gameId: gameId)

        // Assert: manager returns [] when repo is empty/nil
        let post = try await manager.getAllKeyMoments(teamId: "ignored", gameId: gameId) ?? []
        XCTAssertTrue(post.isEmpty, "All key moments for the game should be deleted")
    }

    func testUpdateFeedbackFor() async throws {
        // Arrange: use existing KM fixtures from repo init
        let fixtures: [DBKeyMoment] = TestDataLoader.load("TestKeyMoments", as: [DBKeyMoment].self)
        let km = try XCTUnwrap(fixtures.first)

        // Seed a transcript that points to that key moment (no JSON needed)
        localRepo.seedTranscripts([
            DBTranscript(
                transcriptId: "t-1",
                keyMomentId: km.keyMomentId,
                transcript: "some text",
                language: "en",
                generatedBy: "test",
                confidence: 100,
                gameId: km.gameId
            )
        ])

        // Act
        try await manager.updateFeedbackFor(
            transcriptId: "t-1",
            gameId: km.gameId,
            teamId: "ignored",
            teamDocId: "ignored",
            feedbackFor: [PlayerNameAndPhoto(playerId: "p-123", name: "A", photoURL: nil)]
        )

        // Assert
        let after = try await manager.getKeyMoment(teamId: "ignored", gameId: km.gameId, keyMomentDocId: km.keyMomentId)
        XCTAssertTrue(after?.feedbackFor?.contains("p-123") ?? false)
    }

}
