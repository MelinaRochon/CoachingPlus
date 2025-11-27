//
//  AudioRecordingViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//
 
import Foundation
import GameFrameIOSShared
import SwiftUI
 
/// Represents a transcript associated with a key moment in a game.
struct keyMomentTranscript: Identifiable, Equatable {
    static func == (lhs: keyMomentTranscript, rhs: keyMomentTranscript) -> Bool {
        lhs.id == rhs.id &&
        lhs.transcript == rhs.transcript &&
        lhs.frameStart == rhs.frameStart
    }
    
    let id: Int
    let keyMomentId: String // referenced key moment
    let transcriptId: String // referenced key moment
    var transcript: String // transcription
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    var feedbackFor: [PlayerTranscriptInfo]?
}
 
/// Holds information about a player associated with a transcript.
struct PlayerTranscriptInfo {
    let playerId: String
    let firstName: String
    let lastName: String
    let nickname: String?
    let jersey: Int
}
 
/***
The **AudioRecordingModel** acts as the ViewModel for the AudioRecordingView, linking it to the **KeyMomentManager** and **TranscriptManager** for handling key moments and transcripts associated with audio recordings during a game.

This model handles:
- Adding and storing recordings.
- Fetching and loading key moments and associated transcripts from the database.
- Managing the state of the game, team, and players related to audio recording functionality.

It also performs tasks such as adding game metadata, ending the game with updated durations, and loading player information for feedback during transcription.
*/
@MainActor
final class AudioRecordingModel: ObservableObject {
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    /// An array of key moment transcripts (audio recordings with associated feedback).
    /// Each entry corresponds to a unique key moment with a transcript.
    @Published var recordings: [keyMomentTranscript] = []
    
    /// The ID of the team that the current audio recording session belongs to.
    /// Used to link recordings to a specific team and fetch relevant data.
    @Published var teamId: String = ""
    
    /// The ID of the game being recorded. Used to associate recordings with a specific game session.
    @Published var gameId: String = ""
    
    /// An array of players' information, specifically needed for associating feedback with specific players.
    /// This array is loaded with the player's first name, last name, nickname, and jersey number.
    @Published var players: [PlayerTranscriptInfo]? = []

    @Published var fullGameUrl: String?
    
    @StateObject private var playerTeamInfoModel = PlayerTeamInfoModel()

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

    /// Adds a new audio recording and its corresponding key moment and transcript to the database.
    ///
    /// - Parameters:
    ///   - recordingStart: The start time of the recording.
    ///   - recordingEnd: The end time of the recording.
    ///   - transcription: The transcribed text from the audio.
    ///   - feedbackFor: The player associated with the feedback (if any).
    /// - Throws: An error if the operation fails.
    func addRecording(recordingStart: Date, recordingEnd: Date, transcription: String, feedbackFor: PlayerTranscriptInfo?, numAudioFiles: Int) async throws {
        do {
            // Determine which players the feedback is for
            var fbFor: [String]
            if feedbackFor == nil {
                // Associate the feedback to every player on the team
                fbFor = players!.map { $0.playerId }
            } else {
                // Add a new key moment to the database
                fbFor = feedbackFor.map { [$0.playerId] } ?? []
            }
               
            guard let repo = dependencies?.authenticationManager else {
                print("⚠️ Dependencies not set")
                return
            }

            // Get authenticated coach ID
            let authUser = try repo.getAuthenticatedUser()
            
            let fileName = "\(UUID().uuidString).m4a"
            let path = "audio/\(teamId)/\(gameId)/\(fileName)"
                    
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let tempURL = url.appendingPathComponent("audio/\(teamId)/\(gameId)/\(numAudioFiles)")
                .appendingPathExtension("m4a")
            
            if dependencies?.currentGameRecordingsContext == nil {
                dependencies?.currentGameRecordingsContext = GameRecordingsContext()
            }

            StorageManager.shared.uploadAudioFile(localFile: tempURL, path: path) { result in
                switch result {
                case .success(let downloadURL):
                    print("Audio uploaded! URL: \(downloadURL)")
                    // Store this in Firestore
                case .failure(let error):
                    print("Error uploading audio: \(error.localizedDescription)")
                }
            }
            
            // Create a new key moment entry
            let keyMomentDTO = KeyMomentDTO(
                fullGameId: nil,
                gameId: gameId,
                uploadedBy: authUser.uid,
                audioUrl: path,
                frameStart: recordingStart,
                frameEnd: recordingEnd,
                feedbackFor: fbFor
            )
            
            // Add a new key moment to the database
            let keyMomentDocId = try await dependencies?.keyMomentManager.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
            guard let safeKeyMomentId = keyMomentDocId else {
                print("Error: The key moment doc ID is nil. Aborting.")
                return
            }
            
            // Add a new transcript to the database
            let confidence: Int = 5 // Should be from 1 to 5 where 1 is the lowest and 5 is most confident
            
            // Create a new transcript entry
            let transcriptDTO = TranscriptDTO(
                keyMomentId: keyMomentDocId!,
                transcript: transcription,
                language: "English",
                generatedBy: authUser.uid,
                confidence: confidence,
                gameId: gameId
            )
            
            // Add a new transcript to the database
            guard let transcriptDocId = try await dependencies?.transcriptManager.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO) else {
                print("Error: the transcript doc ID is nil.")
                return
            }
            
            // Retrieve associated players
            var feedbackForArray: [PlayerTranscriptInfo] = []
            // Following code will be used in a future feature - adapting the feedback to multiple people
            /********
             if feedbackFor == "none" {
             feedbackForArray = []
             } else if feedbackFor == "all" {
             if let playersInTeam = players {
             feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
             }
             } else {
             if let playersInTeam = players {
             let p = playersInTeam.first(where: { $0.playerId == feedbackFor })
             feedbackForArray.append(p!)
             }
             }
             **/
            
            // Add the new recording to the local array
            if let feedback = feedbackFor {
                print("append feedback")
                feedbackForArray.append(feedback)
                // Add a new recording to the array
                let recordingsLength = self.recordings.count
                let newRecording = keyMomentTranscript(
                    id: recordingsLength,
                    keyMomentId: safeKeyMomentId,
                    transcriptId: transcriptDocId,
                    transcript: transcription,
                    frameStart: recordingStart,
                    frameEnd: recordingEnd,
                    feedbackFor: feedbackForArray
                )
//                self.recordings.append(newRecording)
                dependencies?.currentGameRecordingsContext!.recordings.append(newRecording)
            } else {
                // if there are players on the team, then associate to each one of them
                if let playersInTeam = players {
                    print("append all players")
                    feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                    let recordingsLength = self.recordings.count
                    // Add a new recording to the array
                    let newRecording = keyMomentTranscript(
                        id: recordingsLength,
                        keyMomentId: safeKeyMomentId,
                        transcriptId: transcriptDocId,
                        transcript: transcription,
                        frameStart: recordingStart,
                        frameEnd: recordingEnd,
                        feedbackFor: feedbackForArray
                    )
//                    self.recordings.append(newRecording)
                    dependencies?.currentGameRecordingsContext!.recordings.append(newRecording)

                } else {
                    print("no feedback")
                }
            }
        } catch {
            print("Error when adding a new recording to the database. ")
            return
        }
    }
        

    /// Creates an unknown game entry in the database.
    ///
    /// - Parameter teamId: The ID of the team associated with the game.
    /// - Returns: The ID of the created game, or `nil` if the operation fails.
    /// - Throws: An error if the operation fails.
    func addUnknownGame(teamId: String) async throws -> String? {
        // Add game to the database
        return try await dependencies?.gameManager.addNewUnkownGame(teamId: teamId)
    }
    

    /// Retrieves the URL for a full game recording, if one exists.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    /// - Returns: A `URL` pointing to the full game recording, or `nil` if no recording exists.
    /// - Note: This function does *not* throw an error if the full game recording cannot be found.
    ///         It only throws if the underlying repository call fails unexpectedly.
    func getFullGameRecordingUrlIfExists(teamDocId: String, gameId: String) async throws -> URL? {
        // Try to find the full game recording if it exists, otherwise, return nil
        do {
            guard let fullGame = try await dependencies?.fullGameRecordingManager.getFullGameVideoWithGameId(teamDocId: teamDocId, gameId: gameId) else {
                print("Unable to get full game video recording document")
                return nil
                // TODO: Shouldn't be an error here if we can't find a full game recording. However, it should be
            }
            if let url =  fullGame.fileURL { return URL(string: url) }
            else { return nil }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    

    /// Ends an audio recording game and updates its duration.
    ///
    /// - Parameters:
    ///   - teamId: The ID of the team.
    ///   - gameId: The ID of the game.
    /// - Throws: An error if the operation fails.
    func endAudioRecordingGame(teamId: String, gameId: String) async throws {
        // Update the game's duration, and add the end time
        guard let team = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
            print("Team could not be found. Aborting.")
            return
        }
        
        guard let game = try await dependencies?.gameManager.getGame(gameId: gameId, teamId: teamId) else {
            print("Could not get the game. Aborting.")
            return
        }
        
        let endTime = Date() // get the end time of the game
        
        if let startTime = game.startTime {
            // Get the duration of the game in seconds
            let duration = endTime.timeIntervalSince(startTime)
            let durationInSeconds = Int(duration)
            try await dependencies?.gameManager.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: team.id, duration: durationInSeconds)
        }
    }
    
    
    /// Loads players associated with the team for transcription purposes.
    ///
    /// - Parameter teamId: The ID of the team.
    /// - Throws: An error if the operation fails.
    func loadPlayersForTranscription(teamId: String) async throws {
        // Get the player, if there are some
        guard let team = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
            print("Error when loading team.")
            return
        }
        
        guard let players = team.players else {
            print("No players found for this team.")
            return
        }
        
        var tmpPlayers: [PlayerTranscriptInfo] = []
        
        // Load player's information for each player's in the team
        for playerId in players {
            
            // Retrieve the player's information
            guard let playerObject = try await loadPlayerInfo(playerId: playerId, teamId: teamId) else {
                print("No player")
                return
            }
            
            // Add each player's information to the array
            tmpPlayers.append(playerObject)
        }
        
        self.players = tmpPlayers
    }
    

    /// Retrieves information about players associated with a given list of IDs.
    ///
    /// - Parameter feedbackFor: An array of player IDs.
    /// - Returns: An array of `PlayerTranscriptInfo` objects.
    /// - Throws: An error if the operation fails.
    func getAllPlayersInfo(feedbackFor: [String]?) async throws -> [PlayerTranscriptInfo] {
        var tmpPlayer: [PlayerTranscriptInfo] = []
        
        // Retrieve all the players information
        if let feedbackFor = feedbackFor {
            for playerId in feedbackFor {
                let player = try await loadPlayerInfo(playerId: playerId, teamId: teamId)!;
                
                tmpPlayer.append(player)
            }
        }
        return tmpPlayer
    }
    

    /// Loads detailed player information for a given player ID.
    ///
    /// - Parameter playerId: The player's ID.
    /// - Returns: A `PlayerTranscriptInfo` object, or `nil` if not found.
    func loadPlayerInfo(playerId: String, teamId: String) async throws -> PlayerTranscriptInfo? {
        // get the user info
        guard let user = try await dependencies?.userManager.getUser(userId: playerId) else {
            print("no user found. abort")
            return nil
        }

        guard let player = try await dependencies?.playerManager.getPlayer(playerId: playerId) else {
            print("no player found. abort")
            return nil
        }

        guard let playerTeamInfo = try await dependencies?.playerTeamInfoManager.getPlayerTeamInfo(playerDocId: player.id, teamId: teamId) else {
            // TODO: Throw error
            throw PlayerTeamInfoError.playerTeamInfoNotFound
        }

        // create an object to store the player's info
        let playerObject = PlayerTranscriptInfo(
            playerId: playerId,
            firstName: user.firstName,
            lastName: user.lastName,
            nickname: playerTeamInfo.nickName,
            jersey: playerTeamInfo.jerseyNum ?? 0
        )

        return playerObject
    }
    
    func updateGameStartTime(gameId: String, teamId: String, startTime: Date) async throws {
        
        guard let team = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
            print("Unable to find team. Abort")
            return
        }

        try await dependencies?.gameManager.updateGameStartTimeUsingTeamDocId(
            gameId: gameId,
            teamDocId: team.id,
            startTime: startTime
        )
    }
    
    /// Loads detailed player information for a given player ID.
    ///
    /// - Parameter playerId: The player's ID.
    /// - Returns: A `PlayerTranscriptInfo` object, or `nil` if not found.
    func loadAllPlayersInfo(teamId: String) async throws {
        guard let team = try await dependencies?.teamManager.getTeam(teamId: teamId) else {
            print("Unable to get team. abort")
            // TODO: Throw error
            return
        }
        
        if let playerIds = team.players {
            
            
            // get the user info
            guard let users = try await dependencies?.userManager.getAllUsers(userIds: playerIds) else {
                print("no user found. abort")
                return
            }
            
            var tmpPlayers: [PlayerTranscriptInfo] = []
            for user in users {
                
                guard let userId = user.userId else {
                    print("USer id should not be nil")
                    // TODO: Throw error
                    return
                }
                // Get the team player info
                guard let playerTeamInfo = try await dependencies?.playerTeamInfoManager.getPlayerTeamInfoWithPlayerId(playerId: userId, teamId: teamId) else {
                    print("Could not find playerTeamInfo for \(userId). Abort")
                    // TODO: Manage the Throw error
                    throw PlayerTeamInfoError.playerTeamInfoNotFound
                }
                
                // create an object to store the player's info
                let playerObject = PlayerTranscriptInfo(
                    playerId: userId,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    nickname: playerTeamInfo.nickName,
                    jersey: playerTeamInfo.jerseyNum ?? 0
                )
                
                tmpPlayers.append(playerObject)
                
            }
            
            players = tmpPlayers
        }
    }

}
