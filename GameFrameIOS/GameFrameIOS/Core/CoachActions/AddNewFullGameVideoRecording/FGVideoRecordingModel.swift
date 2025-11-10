//
//  FGVideoRecordingModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import SwiftUI
import GameFrameIOSShared

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
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    // MARK: - Published Properties
       
    /// URL of the video file.
    @Published var fileURL = ""

    /// Start time of the video recording.
    @Published var startTime: Date = Date()

    /// End time of the video recording.
    @Published var endTime: Date = Date()

    /// ID of the associated game for the video recording.
    @Published var gameId: String = ""

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    
    // MARK: - Methods
        
    /// Test function to log current video recording details.
    ///
    /// This method is for debugging purposes and logs the values of the file URL, start time,
    /// and end time to the console.
    func test() {
        print("fileURL: \(fileURL), startTime: \(startTime), endTime: \(endTime)")
    }
    
    
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
    func createFGRecording(teamId: String, gameId: String) async throws -> String? {
        do {
            guard let repo = dependencies else {
                print("⚠️ Dependencies not set")
                return nil
            }

            // Retrieve the authenticated user's coach ID.
            let authUser = try repo.authenticationManager.getAuthenticatedUser()
            let coachId = authUser.uid

            // Get the game Id
            guard let game = try await repo.gameManager.getGame(gameId: gameId, teamId: teamId) else {
                return nil
            }
            
            // Create a new video recording DTO with necessary data.
            let newFGVideoRecording = FullGameVideoRecordingDTO(
                gameId: gameId,
                uploadedBy: coachId,
                fileURL: fileURL,
                startTime: game.startTime ?? Date(),
                endTime: nil, // TO DO - we don't know yet the end time of the video recording
                teamId: teamId
            )

            // Upload the new video recording to the server.
            let fgRecordingId = try await repo.fullGameRecordingManager.addFullGameVideoRecording(fullGameVideoRecordingDTO: newFGVideoRecording)
            return fgRecordingId
        } catch {
            // Handle any errors that occur during the process.
            print("Failed to create full game video recording: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// Updates a Full Game (FG) recording entry by uploading the associated video file
    /// to Firebase Storage and updating the Firestore document with its metadata.
    ///
    /// - Parameters:
    ///   - endTime: The timestamp marking when the recording ended. Used for updating the FG record.
    ///   - fgRecordingId: The Firestore document ID of the full game recording to update.
    ///   - gameId: The unique identifier of the game the video belongs to.
    ///   - teamId: The unique identifier of the team associated with the game.
    ///   - localFile: The local URL of the recorded video file to upload.
    ///
    /// - Throws: Any error encountered when retrieving the team or updating Firestore.
    ///
    /// - Note: Errors during the video upload are only logged; they do not propagate to the caller.
    ///         If you need stricter failure handling, consider changing the upload logic to `async/await`
    ///         instead of using a completion handler.
    func updateFGRecording(endTime: Date, fgRecordingId: String, gameId: String, teamId: String, localFile: URL) async throws {
        do {
            let path = "full_game/\(teamId)/\(gameId).mov"
            
            // Wait for upload to complete
            let downloadURL = try await StorageManager.shared.uploadVideoFile(localFile: localFile, path: path)
            print("Video uploaded! URL: \(downloadURL)")
            
            guard let team = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
                print("Unable to find team. Abort")
                return
            }
            
            try await dependencies?.fullGameRecordingManager.updateFullGameVideoRecording(
                fullGameId: fgRecordingId,
                teamDocId: team.id,
                endTime: endTime,
                path: path
            )
            
            // Safe to delete file now
            try FileManager.default.removeItem(at: localFile)
            print("🗑️ Deleted local file")
            
        } catch {
            print("Error in updateFGRecording: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    /// Retrieves the download URL (as a `String`) for a full game recording associated with a team and game.
    ///
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The unique identifier of the game.
    ///
    /// - Returns:
    ///   - The video file URL (`String`) if a full game recording document exists.
    ///   - `nil` if the document is not found or if an error occurs.
    ///
    /// - Throws: Any error thrown during the Firestore fetch operation.
    ///           Note that in practice, the function catches errors and returns `nil`,
    ///           so callers will usually not see thrown errors unless you refactor it.
    func getFGRecordingVideoUrl(teamDocId: String, gameId: String) async throws -> String? {
        do {
            guard let fullGame = try await dependencies?.fullGameRecordingManager.getFullGameVideoWithGameId(teamDocId: teamDocId, gameId: gameId) else {
                print("Unable to get full game video recording document. Aborting")
                return nil
            }
            return fullGame.fileURL
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
