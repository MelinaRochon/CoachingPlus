//
//  LocalTeamRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation

/// A local in-memory implementation of `FullGameVideoRecordingRepository`.
/// Useful for unit tests or preview data without hitting Firestore.
public final class LocalFullGameRecordingRepository: FullGameVideoRecordingRepository {
    
    /// Stores all full game video recordings locally in memory
    private var fullGameRecording: [DBFullGameVideoRecording] = []
    
    public init(fg_recording: [DBFullGameVideoRecording]? = nil) {
        // If no teams provided, fallback to default JSON
        self.fullGameRecording = fg_recording ?? TestDataLoader.load("TestFullGameRecordings", as: [DBFullGameVideoRecording].self)
    }
    
    /// Retrieves a full game video recording by its ID.
    /// - Parameters:
    ///   - teamDocId: The team document ID (not used in local storage, but kept for protocol consistency).
    ///   - fullGameId: The unique ID of the full game recording.
    /// - Returns: The matching `DBFullGameVideoRecording` if found, otherwise `nil`.
    public func getFullGameVideo(teamDocId: String, fullGameId: String) async throws -> DBFullGameVideoRecording? {
        return fullGameRecording.first { $0.id == fullGameId }
    }
    
    
    /// Adds a new full game video recording to the local storage.
    /// - Parameter fullGameVideoRecordingDTO: The DTO containing recording details.
    /// - Returns: The newly generated ID for the recording.
    public func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws -> String? {
        let fullGameId = UUID().uuidString
        let fullGameVideoRecording = DBFullGameVideoRecording(id: fullGameId, fullGameVideoRecordingDTO: fullGameVideoRecordingDTO)
        fullGameRecording.append(fullGameVideoRecording)
        return fullGameId
    }
    
    
    /// Updates the `endTime` and `fileURL` of a full game video recording.
    /// - Parameters:
    ///   - fullGameId: The ID of the recording to update.
    ///   - teamDocId: The team document ID (not used locally).
    ///   - endTime: The new end time of the recording.
    ///   - path: The new file path or URL of the recording.
    public func updateFullGameVideoRecording(fullGameId: String, teamDocId: String, endTime: Date, path: String) async throws {
        if let index = fullGameRecording.firstIndex(where: { $0.id == fullGameId }) {
            fullGameRecording[index].endTime = endTime
            fullGameRecording[index].fileURL = path
        }
    }
    
    
    /// Retrieves a full game video recording by its associated game ID.
    /// - Parameters:
    ///   - teamDocId: The team document ID (not used locally).
    ///   - gameId: The game ID linked to the recording.
    /// - Returns: The matching `DBFullGameVideoRecording` if found, otherwise `nil`.
    public func getFullGameVideoWithGameId(teamDocId: String, gameId: String) async throws -> DBFullGameVideoRecording? {
        return fullGameRecording.first { $0.gameId == gameId }
    }
    
    public func doesFullGameVideoExistsWithGameId(teamDocId: String, gameId: String, teamId: String) async throws -> Bool {
        let fileUrl = "full_game/\(teamId)/\(gameId).mov"

        return fullGameRecording.contains(where: { $0.fileURL ==  fileUrl})
    }
}
