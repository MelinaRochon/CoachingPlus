//
//  FullGameVideoRecordingTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Testing
@testable import GameFrameIOS
import Foundation

struct FullGameVideoRecordingTests {
        
    /// Tests the local repository implementation for adding
    /// and retrieving a full game video recording.
    @Test
    func testFullGameVideoRecording() async throws {
        // Use the local repository (no Firestore calls here)
        let localManager = FullGameVideoRecordingManager(repo: LocalFullGameRecordingRepository())
        
        // Create a demo DTO for a video recording
        let demoFullGame = FullGameVideoRecordingDTO(
            gameId: "abcd",
            uploadedBy: "uu123",
            fileURL: "/full_game/tt123/abcd.mp4",
            startTime: Date().addingTimeInterval(-2 * 60 * 60), // 2 hours ago
            endTime: Date(),
            teamId: "tt123"
        )
        
        // Run the test in a Task context
        Task {
            do {
                // Add the recording to the local repo
                let id = try await localManager.addFullGameVideoRecording(fullGameVideoRecordingDTO: demoFullGame)
                print("Full Game Video created locally with ID: \(id ?? "none")")
                
                // Fetch the recording back using the generated ID
                let fetched = try await localManager.getFullGameVideo(teamDocId: "tt123", fullGameId: id!)
                print("Fetched full game video locally: \(fetched?.id ?? "none")")
            } catch {
                // Print error if anything fails
                print("Error: \(error)")
            }
        }
    }
}
