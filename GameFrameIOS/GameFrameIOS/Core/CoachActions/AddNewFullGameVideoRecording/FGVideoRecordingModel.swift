//
//  FGVideoRecordingModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import SwiftUI

/** This file defines the `FGVideoRecordingModel` class, which manages the data and logic
  for handling video recordings related to a full game. It is an `ObservableObject` that
  tracks the file URL, start time, end time, and game ID associated with the video recording.

  ## Purpose:
  The class provides functionality for creating and managing video recordings of games,
  allowing coaches to upload and associate video files with specific teams and games.
  It is used to store and handle video recording metadata, as well as to facilitate
  uploading video recordings to the server through the `FullGameVideoRecordingManager`.

  ## Key Features:
  - Tracks video recording metadata (file URL, start time, end time, game ID).
  - Supports asynchronous creation of a video recording through the `createFGRecording` method.
  - Includes a test function to log the recording details for debugging purposes.
 */
@MainActor
final class FGVideoRecordingModel: ObservableObject {
    // MARK: - Published Properties
       
    /// URL of the video file.
    @Published var fileURL = ""

    /// Start time of the video recording.
    @Published var startTime: Date = Date()

    /// End time of the video recording.
    @Published var endTime: Date = Date()

    /// ID of the associated game for the video recording.
    @Published var gameId: String = ""

    // MARK: - Methods
    
    /// Creates a new video recording entry and uploads it to the server.
    ///
    /// This asynchronous function attempts to create a new `FullGameVideoRecordingDTO` object
    /// and upload it using `FullGameVideoRecordingManager`. The recording is associated with a
    /// specified team and game ID.
    ///
    /// - Parameter teamId: The ID of the team the video recording is associated with.
    /// - Returns: A boolean indicating whether the video recording was successfully created and uploaded.
    /// - Throws: An error if the creation or upload process fails.
    ///
    /// Example usage:
    /// ```swift
    /// let success = try await createFGRecording(teamId: "123")
    /// ```
    func createFGRecording(teamId: String?) async throws -> Bool {
        do {
            // Retrieve the authenticated user's coach ID.
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let coachId = authUser.uid

            // Check if the team ID is valid.
            guard teamId != nil else {
                print("no team id. aborting..")
                return false
            }
             
            // Create a new video recording DTO with necessary data.
            let newFGVideoRecording = FullGameVideoRecordingDTO(
                gameId: gameId,
                uploadedBy: coachId,
                fileURL: fileURL,
                startTime: Date(),
                endTime: nil, // TO DO - we don't know yet the end time of the video recording
                teamId: teamId!
            )

            // Upload the new video recording to the server.
            try await FullGameVideoRecordingManager.shared.addFullGameVideoRecording(fullGameVideoRecordingDTO: newFGVideoRecording)
            return true
        } catch {
            // Handle any errors that occur during the process.
            print("Failed to create team: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Test function to log current video recording details.
    ///
    /// This method is for debugging purposes and logs the values of the file URL, start time,
    /// and end time to the console.
    func test() {
        print("fileURL: \(fileURL), startTime: \(startTime), endTime: \(endTime)")
    }
}
