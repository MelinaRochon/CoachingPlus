//
//  TranscriptModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation


/// **TranscriptModel** is responsible for handling transcript and key moment retrieval for a game.
///
/// ## Responsibilities:
/// - Fetching user details.
/// - Retrieving all transcripts and key moments for a given game.
/// - Filtering and sorting transcripts based on user type (player vs. coach).
/// - Loading player information for transcript feedback.
///
/// This class ensures all operations run on the main actor to prevent concurrency issues in SwiftUI.
@MainActor
final class TranscriptModel: ObservableObject {
    
    /// Retrieves the authenticated user from the database.
    ///
    /// - Returns: A `DBUser` object representing the authenticated user, or `nil` if not found.
    /// - Throws: An error if authentication fails.
    func getUser() async throws -> DBUser? {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        return try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
    
    /// Retrieves all transcripts and key moments for a specific game.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier for the game.
    ///   - teamDocId: The unique identifier for the team.
    /// - Returns: A tuple containing two optional arrays:
    ///   - The first array contains key moment transcripts for recorded clips.
    ///   - The second array contains key moments for full-game analysis.
    /// - Throws: An error if the retrieval process fails.
    func getAllTranscriptsAndKeyMoments(gameId: String, teamDocId: String) async throws -> ([keyMomentTranscript]?, [keyMomentTranscript]?) {
        do {
            // Retrieve all transcripts associated with the game.
            guard let transcripts = try await TranscriptManager.shared.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return (nil, nil)
            }
            
            // Retrieve the authenticated user.
            guard let user = try await getUser() else {
                print("Could not get user. Aborting..")
                return (nil, nil)
            }
            
            // Lists to store processed transcripts and key moments.
            var allRecordings: [keyMomentTranscript] = []
            var allKeyMoments: [keyMomentTranscript] = []

            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Retrieve the key moment associated with the transcript.
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return (nil, nil)
                }
                
                // Track the index positions for adding new transcripts.
                let recordingsLength = allRecordings.count
                let keyMomentsLength = allKeyMoments.count
                
                if let userId = user.userId {
                    if user.userType == "Player" {
                        // Players should only see key moments that are directed at them for privacy reasons.
                        if let feedbackFor = keyMoment.feedbackFor {
                            if feedbackFor.contains(userId) {
                                // Only show feedback for the player, not everyone it is addressed to
                                // Reason: Privacy reasons!
                                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: [userId])
                                let newKeyMomTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                                
                                // Adding new element to the transcripts array
                                allRecordings.append(newKeyMomTranscript)
                                
                                if keyMoment.fullGameId != nil {
                                    let newKeyMomTranscript = keyMomentTranscript(id: keyMomentsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                                    
                                    // Adding new element to the transcripts array
                                    allKeyMoments.append(newKeyMomTranscript)
                                }
                            }
                        }
                    } else {
                        // Coaches can see all key moments, so no filtering is needed.
                        let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)
                        
                        let newKeyMomTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                        
                        // Adding new element to the array
                        allRecordings.append(newKeyMomTranscript)
                        
                        if keyMoment.fullGameId != nil {
                            let newKeyMomTranscript = keyMomentTranscript(id: keyMomentsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                            
                            // Adding new element to the transcripts array
                            allKeyMoments.append(newKeyMomTranscript)
                        }
                    }
                }
            }
            
            // Sort transcripts by start frame to maintain chronological order.
            let sortedTranscripts = allRecordings.sorted(by: { $0.frameStart < $1.frameStart})
            let sortedKeyMoments = allKeyMoments.sorted(by: { $0.frameStart < $1.frameStart})
            
            return (sortedTranscripts, sortedKeyMoments)
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return (nil, nil)
        }
    }
    
    
    /// Retrieves information for a list of players based on their IDs.
    ///
    /// - Parameter feedbackFor: An array of player IDs.
    /// - Returns: An array of `PlayerTranscriptInfo` objects containing player details.
    /// - Throws: An error if any player information retrieval fails.
    func getAllPlayersInfo (feedbackFor: [String]?) async throws -> [PlayerTranscriptInfo] {
        var tmpPlayer: [PlayerTranscriptInfo] = []
        if let feedbackFor = feedbackFor {
            for playerId in feedbackFor {
                let player = try await loadPlayerInfo(playerId: playerId)!;
                
                tmpPlayer.append(player)
            }
        }
        return tmpPlayer
    }
    
    
    /// Retrieves detailed player information based on a given player ID.
    ///
    /// - Parameter playerId: The ID of the player.
    /// - Returns: A `PlayerTranscriptInfo` object containing the player's details, or `nil` if not found.
    /// - Throws: An error if retrieval fails.
    func loadPlayerInfo(playerId: String) async throws -> PlayerTranscriptInfo? {
        // Retrieve user information.
        guard let user = try await UserManager.shared.getUser(userId: playerId) else {
            print("no user found. abort")
            return nil
        }
        
        // Retrieve player-specific information.
        guard let player = try await PlayerManager.shared.getPlayer(playerId: playerId) else {
            print("no player found. abprt")
            return nil
        }
        
        // Create a structured player object.
        let playerObject = PlayerTranscriptInfo(playerId: playerId, firstName: user.firstName, lastName: user.lastName, nickname: player.nickName, jersey: player.jerseyNum)
        
        return playerObject
    }
    
    
    func getAudioFileUrl(keyMomentId: String, gameId: String, teamId: String) async throws -> String? {
        guard let keyMomentAudioURL = try await KeyMomentManager.shared.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentId)?.audioUrl else {
            return nil
        }
        
        return keyMomentAudioURL
    }

    
    /// Retrieves the names and profile pictures of players mentioned in feedback.
    ///
    /// - Parameter feedbackFor: An array of player IDs.
    /// - Returns: An array of `PlayerNameAndPhoto` objects containing player names and profile pictures.
    /// - Throws: An error if retrieval fails.
    func getFeebackFor(feedbackFor: [String]) async throws -> [PlayerNameAndPhoto] {
        var results: [PlayerNameAndPhoto] = []
        for id in feedbackFor {
            if let user = try await UserManager.shared.getUser(userId: id) {
                print("player: \(user.firstName) \(user.lastName)")
                results.append(
                    PlayerNameAndPhoto(playerId: id, name: user.firstName + " " + user.lastName, photoURL: nil)
                )
            }
        }
        return results
    }
    
    
    /// Updates transcript information in the database.
    ///
    /// - Parameters:
    ///   - teamDocId: Firestore document ID for the team.
    ///   - teamId: Team identifier.
    ///   - gameId: Game identifier.
    ///   - transcriptId: Transcript identifier.
    ///   - feedbackFor: Optional list of players receiving feedback.
    ///   - transcript: Optional updated transcript text.
    ///
    /// - Throws: If updating feedback or transcript fails.
    func updateTranscriptInfo(
        teamDocId: String,
        teamId: String,
        gameId: String,
        transcriptId: String,
        feedbackFor: [PlayerNameAndPhoto]?,
        transcript: String?
    ) async throws {
        if let feedbackFor = feedbackFor {
            try await KeyMomentManager.shared.updateFeedbackFor(
                transcriptId: transcriptId,
                gameId: gameId,
                teamId: teamId,
                teamDocId: teamDocId,
                feedbackFor: feedbackFor // save selected players
            )
        }
        
        if let transcript = transcript {
            try await TranscriptManager.shared.updateTranscript(teamDocId: teamDocId, gameId: gameId, transcriptId: transcriptId, transcript: transcript)
        }
    }
}
