//
//  FullGameVideoRecordingTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-02.
//

import XCTest
@testable import GameFrameIOS

final class FullGameVideoRecordingTests: XCTestCase {
    var manager: FullGameVideoRecordingManager!
    var localRepo: LocalFullGameRecordingRepository!
    var seeded: [DBFullGameVideoRecording]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // 1) Load fixtures from the test bundle
        seeded = TestDataLoader.load("TestFullGameRecordings", as: [DBFullGameVideoRecording].self)
        XCTAssertFalse(seeded.isEmpty, "Fixture must not be empty")

        // 2) Seed the repo with the exact same array
        localRepo = LocalFullGameRecordingRepository(fg_recording: seeded)

        // 3) Build the manager on top of this seeded repo
        manager = FullGameVideoRecordingManager(repo: localRepo)
    }
    
    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        seeded = nil
        try super.tearDownWithError()
    }
    
    func testGetFullGameVideoRecording() async throws {
        // Use a real item from the seeded array
        let sample = try XCTUnwrap(seeded.first)

        // IMPORTANT: fullGameId is the recording's id (NOT the gameId)
        let fetched = try await manager.getFullGameVideo(teamDocId: sample.teamId, fullGameId: sample.id)
        let rec = try XCTUnwrap(fetched, "Should fetch seeded recording by recording id")

        XCTAssertEqual(rec.id, sample.id)
        XCTAssertEqual(rec.teamId, sample.teamId)
        XCTAssertEqual(rec.gameId, sample.gameId)
        XCTAssertEqual(rec.fileURL, sample.fileURL)

        // date equality with a small tolerance
        XCTAssertEqual(rec.startTime.timeIntervalSince1970,
                       sample.startTime.timeIntervalSince1970,
                       accuracy: 1.0)
        if let sampleEnd = sample.endTime, let recEnd = rec.endTime {
            XCTAssertEqual(recEnd.timeIntervalSince1970,
                           sampleEnd.timeIntervalSince1970,
                           accuracy: 1.0)
        } else {
            XCTAssertNil(rec.endTime)
            XCTAssertNil(sample.endTime)
        }
    }

    func testGetFullGameVideoRecordingByGameId() async throws {
        // Use a known item from fixtures to query by gameId
        let fixtures: [DBFullGameVideoRecording] = TestDataLoader.load("TestFullGameRecordings", as: [DBFullGameVideoRecording].self)
        XCTAssertFalse(fixtures.isEmpty)

        let sample = fixtures[0]

        let got = try await manager.getFullGameVideoWithGameId(teamDocId: sample.teamId, gameId: sample.gameId)
        let rec = try XCTUnwrap(got, "Should fetch seeded recording by gameId")

        XCTAssertEqual(rec.id, sample.id)
        XCTAssertEqual(rec.teamId, sample.teamId)
        XCTAssertEqual(rec.gameId, sample.gameId)
    }
    
    func testUpdateFullGameVideoRecordingPersists() async throws {
        // Pick a seeded record, then update it via manager
        let fixtures: [DBFullGameVideoRecording] = TestDataLoader.load("TestFullGameRecordings", as: [DBFullGameVideoRecording].self)
        XCTAssertFalse(fixtures.isEmpty)
        
        let sample = fixtures[0]
        let newEnd = Date().addingTimeInterval(600)
        let newPath = "sandbox://videos/\(sample.id).mp4"
        
        try await manager.updateFullGameVideoRecording(
            fullGameId: sample.id,
            teamDocId: sample.teamId,
            endTime: newEnd,
            path: newPath
        )
        
        // Re-fetch and assert changes
        let updated = try await manager.getFullGameVideo(teamDocId: sample.teamId, fullGameId: sample.id)
        let rec = try XCTUnwrap(updated)
        let recEnd = try XCTUnwrap(rec.endTime, "rec.endTime should not be nil")
        
        XCTAssertEqual(rec.fileURL, newPath)
        XCTAssertEqual(
            recEnd.timeIntervalSince1970,
            newEnd.timeIntervalSince1970,
            accuracy: 1.0 // within 1 second
        )
    }

    func testGetNonexistentReturnsNil() async throws {
        let got = try await manager.getFullGameVideo(teamDocId: "no-team", fullGameId: "no-id")
        XCTAssertNil(got)
    }

    func testUpdateNonexistentDoesNotThrow() async throws {
        do {
            try await manager.updateFullGameVideoRecording(
                fullGameId: "missing",
                teamDocId: "team-x",
                endTime: Date(),
                path: "nowhere"
            )
            // passes if no throw
        } catch {
            XCTFail("Expected no throw, but got: \(error)")
        }
    }
}
