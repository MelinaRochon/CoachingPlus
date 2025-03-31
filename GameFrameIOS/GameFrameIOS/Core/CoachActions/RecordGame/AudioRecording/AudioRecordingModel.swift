//
//  AudioRecordingViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//
 
import Foundation
 
struct keyMomentTranscript {
    let id: Int
    let keyMomentId: String // referenced key moment
    let transcriptId: String // referenced key moment
    let transcript: String // transcription
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [PlayerTranscriptInfo]?
}
 
struct PlayerTranscriptInfo {
    let playerId: String
    let firstName: String
    let lastName: String
    let nickname: String?
    let jersey: Int
}
 
/***
The audio recording view model links the AudioRecordingView to the KeyMomentManager and the TranscriptManager.
*/
@MainActor
final class AudioRecordingModel: ObservableObject {
    @Published var recordings: [keyMomentTranscript] = [];
    @Published var teamId: String = ""
    @Published var gameId: String = ""
    @Published var players: [PlayerTranscriptInfo]? = []
    
    /** Adds a new recording - adds a new keyMoment and transcript in the database. Update the recordings array */
    func addRecording(recordingStart: Date, recordingEnd: Date, transcription: String, feedbackFor: PlayerTranscriptInfo?) async throws {
            do {
                // Get the id of the authenticated user (coach)
                let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                // Add a new key moment to the database
                let fbFor: [String] = feedbackFor.map { [$0.playerId] } ?? []
                // Add a new key moment object
                let keyMomentDTO = KeyMomentDTO(fullGameId: nil, gameId: gameId, uploadedBy: authUser.uid, audioUrl: nil, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: fbFor)
                // Add a new key moment to the database
                let keyMomentDocId = try await KeyMomentManager.shared.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
                guard let safeKeyMomentId = keyMomentDocId else {
                    print("Error: The key moment doc ID is nil. Aborting.")
                    return
                }
                
                // Add a new transcript to the database
                let confidence: Int = 5 // Should be from 1 to 5 where 1 is the lowest and 5 is most confident
                // Add a new tranacript object
                let transcriptDTO = TranscriptDTO(keyMomentId: keyMomentDocId!, transcript: transcription, language: "English", generatedBy: authUser.uid, confidence: confidence, gameId: gameId)
                // Add a new transcript to the database
                guard let transcriptDocId = try await TranscriptManager.shared.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO) else {
                    print("Error: the transcript doc ID is nil.")
                    return
                }
                var feedbackForArray: [PlayerTranscriptInfo] = []
                /** Following code will be used in a future feature - adapting the feedback to multiple people */
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
    
    /** Add a unkown game to the database */
    func addUnknownGame(teamId: String) async throws -> String? {
        // Add game to the database
        return try await GameManager.shared.addNewUnkownGame(teamId: teamId)
    }
    
    /** Load all recordings to the AudioRecordingView */
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
                
                // Get all the key moments from the database
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return
                }
                
                // get the length of the array to set the id of the element of the list
                let recordingsLength = self.recordings.count
                
                // Retrieve all player's information on the team
                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)
                
                // Create a new object
                let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                
                // Adding new element to the array
                self.recordings.append(keyMomentTranscript)
            }
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
        }
    }
    
    /** Ends an audio recording game and updates the game duration */
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
    
    /** Load players for transcription */
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
    
    /** Get all player's information */
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
    
    /** Load a specific player's information */
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
