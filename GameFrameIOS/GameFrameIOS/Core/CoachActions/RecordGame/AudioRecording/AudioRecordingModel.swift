//
//  AudioRecordingViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//
 
import Foundation
 
/// Represents a transcript associated with a key moment in a game.
struct keyMomentTranscript {
    let id: Int
    let keyMomentId: String // referenced key moment
    let transcriptId: String // referenced key moment
    let transcript: String // transcription
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [PlayerTranscriptInfo]?
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
    
    /// Adds a new audio recording and its corresponding key moment and transcript to the database.
    ///
    /// - Parameters:
    ///   - recordingStart: The start time of the recording.
    ///   - recordingEnd: The end time of the recording.
    ///   - transcription: The transcribed text from the audio.
    ///   - feedbackFor: The player associated with the feedback (if any).
    /// - Throws: An error if the operation fails.
    func addRecording(recordingStart: Date, recordingEnd: Date, transcription: String, feedbackFor: PlayerTranscriptInfo?) async throws {
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
            
            print("fbFor test : \(fbFor)")
            
            // Get authenticated coach ID
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            // Create a new key moment entry
            let keyMomentDTO = KeyMomentDTO(fullGameId: nil, gameId: gameId, uploadedBy: authUser.uid, audioUrl: nil, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: fbFor)
            
            // Add a new key moment to the database
            let keyMomentDocId = try await KeyMomentManager.shared.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
            guard let safeKeyMomentId = keyMomentDocId else {
                print("Error: The key moment doc ID is nil. Aborting.")
                return
            }
            
            // Add a new transcript to the database
            let confidence: Int = 5 // Should be from 1 to 5 where 1 is the lowest and 5 is most confident
            
            // Create a new transcript entry
            let transcriptDTO = TranscriptDTO(keyMomentId: keyMomentDocId!, transcript: transcription, language: "English", generatedBy: authUser.uid, confidence: confidence, gameId: gameId)
            // Add a new transcript to the database
            guard let transcriptDocId = try await TranscriptManager.shared.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO) else {
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
                let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                self.recordings.append(newRecording)
            } else {
                // if there are players on the team, then associate to each one of them
                if let playersInTeam = players {
                    print("append all players")
                    feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                    let recordingsLength = self.recordings.count
                    // Add a new recording to the array
                    let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                    self.recordings.append(newRecording)
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
        return try await GameManager.shared.addNewUnkownGame(teamId: teamId)
    }
    

    /// Loads all recordings and their associated key moments from the database.
    ///
    /// - Throws: An error if the operation fails.
    func loadAllRecordings() async throws {
        do {
            
            // Get all the transcripts from the database
            guard let transcripts = try await TranscriptManager.shared.getAllTranscripts(teamId: teamId, gameId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return
            }
            
            // transcripts were fround in the database. Get the key moments associated to each
            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Fetch the key moment associated with the transcript
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return
                }
                
                // get the length of the array to set the id of the element of the list
                let recordingsLength = self.recordings.count
                
                // Retrieve all player's information on the team
                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)
                
                // Create a new key moment transcript object
                let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                
                // Adding new element to the array
                self.recordings.append(keyMomentTranscript)
            }
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
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
        guard let team = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Team could not be found. Aborting.")
            return
        }
        
        guard let game = try await GameManager.shared.getGame(gameId: gameId, teamId: teamId) else {
            print("Could not get the game. Aborting.")
            return
        }
        
        let endTime = Date() // get the end time of the game
        
        if let startTime = game.startTime {
            // Get the duration of the game in seconds
            let duration = endTime.timeIntervalSince(startTime)
            let durationInSeconds = Int(duration)
            try await GameManager.shared.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: team.id, duration: durationInSeconds)
        }
    }
    
    
    /// Loads players associated with the team for transcription purposes.
    ///
    /// - Parameter teamId: The ID of the team.
    /// - Throws: An error if the operation fails.
    func loadPlayersForTranscription(teamId: String) async throws {
        // Get the player, if there are some
        guard let team = try await TeamManager.shared.getTeam(teamId: teamId) else {
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
            guard let playerObject = try await loadPlayerInfo(playerId: playerId) else {
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
                let player = try await loadPlayerInfo(playerId: playerId)!;
                
                tmpPlayer.append(player)
            }
        }
        return tmpPlayer
    }
    

    /// Loads detailed player information for a given player ID.
    ///
    /// - Parameter playerId: The player's ID.
    /// - Returns: A `PlayerTranscriptInfo` object, or `nil` if not found.
    func loadPlayerInfo(playerId: String) async throws -> PlayerTranscriptInfo? {
        // get the user info
        guard let user = try await UserManager.shared.getUser(userId: playerId) else {
            print("no user found. abort")
            return nil
        }
        
        guard let player = try await PlayerManager.shared.getPlayer(playerId: playerId) else {
            print("no player found. abprt")
            return nil
        }
        
        // create an object to store the player's info
        let playerObject = PlayerTranscriptInfo(playerId: playerId, firstName: user.firstName, lastName: user.lastName, nickname: player.nickName, jersey: player.jerseyNum)
        
        return playerObject
    }
}
