//
//  AudioRecordingViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation

struct keyMomentTranscript {
    let id: Int
    let transcript: String // transcription
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [String]?
}

@MainActor
final class AudioRecordingViewModel: ObservableObject {
    @Published var recordings: [keyMomentTranscript] = [];
    @Published var teamId: String = "" // "zzlZyozdFYaQeUR5gsr7";
    @Published var gameId: String = "" // "HJ4E5nWK8Nep74IbZd0n";
    
    func addRecording(recordingStart: Date, recordingEnd: Date) async throws {
        do {
            // Get the id of the authenticated user (coach)
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            // Add a new key moment to the database
            let feedbackForArray: [String] = ["VnwgbZ8pPcXoIUlz5oXZi2YNLEE3"]
            let keyMomentDTO = KeyMomentDTO(fullGameId: nil, gameId: gameId, uploadedBy: authUser.uid, audioUrl: nil, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
            print("key moment DTO: \(keyMomentDTO)")
            let keyMomentDocId = try await KeyMomentManager.shared.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
            if keyMomentDocId == nil {
                print("Error. The key moment doc id is nil.")
                return
            }
            // Add a new transcript to the database
            let confidence: Int = 5 // Should be from 1 to 5 where 1 is the lowest and 5 is most confident
            let transcription: String = "The world of technology is evolving rapidly, shaping the way we live, work, and communicate. Innovations in artificial intelligence, robotics, and automation are transforming industries, making processes more efficient and accessible. Meanwhile, the rise of renewable energy sources is driving sustainability efforts, reducing dependence on fossil fuels. "
            let transcriptDTO = TranscriptDTO(keyMomentId: keyMomentDocId!, transcript: transcription, language: "English", generatedBy: authUser.uid, confidence: confidence, gameId: gameId)
            try await TranscriptManager.shared.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO)
            
            let recordingsLength = self.recordings.count
            let newRecording = keyMomentTranscript(id: recordingsLength, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)

            self.recordings.append(newRecording)
        } catch {
            print("Error when adding a new recording to the database. ")
            return
        }
    }
    
    func addUnknownGame(teamId: String) async throws -> String? {
        // Add game to the database
        return try await GameManager.shared.addNewUnkownGame(teamId: teamId)
    }

    
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
                let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: keyMoment.feedbackFor)
                
                // Adding new element to the array
                self.recordings.append(keyMomentTranscript)
            }
            
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
        }
    }
    
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
            print("duration \(duration) and in seconds: \(durationInSeconds)")
            try await GameManager.shared.updateGameDurationUsingTeamDocId(gameId: gameId, teamDocId: team.id, duration: durationInSeconds)
        }
    }
}
