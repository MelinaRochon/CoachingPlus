//
//  FullGameVideoRecordingRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation


/// Defines the contract for managing full game video recordings
public protocol FullGameVideoRecordingRepository {
    
    /// Fetches a full game video recording by its Firestore document ID
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team
    ///   - fullGameId: The Firestore document ID of the full game video recording
    /// - Returns: A `DBFullGameVideoRecording` object if found, otherwise `nil`
    func getFullGameVideo(teamDocId: String, fullGameId: String) async throws -> DBFullGameVideoRecording?
    
    
    /// Adds a new full game video recording to the repository
    /// - Parameter fullGameVideoRecordingDTO: Data transfer object containing the details of the recording
    /// - Returns: The generated Firestore document ID of the new recording, or `nil` if creation fails
    func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws -> String?
    
    
    /// Updates an existing full game video recording with end time and file path
    /// - Parameters:
    ///   - fullGameId: The Firestore document ID of the full game video recording
    ///   - teamDocId: The Firestore document ID of the team
    ///   - endTime: The timestamp indicating when the game ended
    ///   - path: The storage path (URL) to the recorded video file
    func updateFullGameVideoRecording(fullGameId: String, teamDocId: String, endTime: Date, path: String) async throws
    
    
    /// Fetches a full game video recording by the associated game ID (instead of recording ID)
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team
    ///   - gameId: The unique identifier of the game
    /// - Returns: A `DBFullGameVideoRecording` object if found, otherwise `nil`
    func getFullGameVideoWithGameId(teamDocId: String, gameId: String) async throws -> DBFullGameVideoRecording?
    
    func doesFullGameVideoExistsWithGameId(teamDocId: String, gameId: String, teamId: String) async throws -> Bool
}
