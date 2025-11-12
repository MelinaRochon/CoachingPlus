//////
//////  WatchConnecter.swift
//////  GameFrameIOS
//////
//////  Created by Mélina Rochon on 2025-11-10.
//////
////
////import Foundation
////import WatchConnectivity
////
////class WatchConnecter: NSObject, WCSessionDelegate {
////    var session: WCSession
////    
////    init(session: WCSession = .default) {
////        self.session = session
////        super.init()
////        session.delegate = self
////        session.activate()
////    }
////    
////    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
////        
////    }
////    
////    func sessionDidBecomeInactive(_ session: WCSession) {
////        
////    }
////    
////    func sessionDidDeactivate(_ session: WCSession) {
////        
////    }
////    
////    
////    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
////        
////    }
////}
//
//
//import WatchConnectivity
//
//class iPhoneConnectivityProvider: NSObject, WCSessionDelegate {
//    
//    static let shared = iPhoneConnectivityProvider()
//    var dependencies: DependencyContainer?
//
//    override init() {
//        super.init()
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
//    }
//
//    func session(_ session: WCSession, didReceive file: WCSessionFile) {
//        print("Received audio file from watch: \(file.fileURL)")
//        
//        // Move file to a permanent location if needed
//        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("received_audio.m4a")
//        try? FileManager.default.moveItem(at: file.fileURL, to: destination)
//        
//        // Transcribe it
//        SpeechTranscriber.shared.transcribeAudio(at: destination) { transcript in
//            print("Transcription: \(transcript ?? "none")")
//            
//            // Upload both
//            FirebaseUploader.uploadAudioAndTranscript(audioURL: destination, transcript: transcript)
//        }
//    }
//    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//        <#code#>
//    }
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        <#code#>
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        <#code#>
//    }
//
//}


import WatchConnectivity
import Foundation
import GameFrameIOSShared

final class iPhoneConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    private let dependencies: DependencyContainer

    init(session: WCSession = .default, dependencies: DependencyContainer) {
        self.session = session
        self.dependencies = dependencies
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - File Transfer Handling
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
        print("We are here")
        guard let context = dependencies.currentGameContext else {
            print("⚠️ No current game context available.")
            return
        }
        
        print("📥 Received file from watch: \(file.fileURL.lastPathComponent)")
        
        let metadata = file.metadata ?? [:]
        print("📎 Metadata: \(metadata)")

        /**
        // Receiving metadata
        let recordStartTime = metadata["recording_start_time"] as? Date
        let recordEndTime = metadata["recording_end_time"] as? Date

        // Move file to a known temp destination
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("watch_audio/\(UUID().uuidString).m4a")
        do {
            try FileManager.default.moveItem(at: file.fileURL, to: destination)
        } catch {
            print("❌ Failed to move file: \(error)")
            return
        }
         DispatchQueue.main.async { // May not be here
             
        // Step 1: Transcribe the audio (on iPhone)
        SpeechTranscriber.shared.transcribeAudio(at: destination) { [weak self] transcript in
            guard let self else { return }
            print("🗣 Transcription complete: \(transcript ?? "none")")
            
            Task {
                await self.uploadAudioAndTranscript(
                    audioURL: destination,
                    transcript: transcript,
                    context: context,
                    recordStartTime: recordStartTime ?? Date(),
                    recordEndTime: recordEndTime ?? Date()
                )
            }
        }
         } // May not be here
         */
    }
    
    func notifyWatchGameStarted(gameId: String) {
        guard session.isReachable else {
            print("⌛ Watch not reachable, queuing game start info")
            WCSession.default.transferUserInfo(["gameStarted": true, "gameId": gameId])
            return
        }

        session.sendMessage(
            ["gameRecordingOn": true, "gameId": gameId],
            replyHandler: nil,
            errorHandler: { error in
                print("⚠️ Failed to notify Watch: \(error.localizedDescription)")
            }
        )
        print("✅ Notified Watch that game started: \(gameId)")
    }
    
    func notifyWatchGameEnded() {
        guard session.isReachable else {
            print("⌛ Watch not reachable, queuing game start info")
            WCSession.default.transferUserInfo(["gameEnded": true])
            return
        }

        session.sendMessage(
            ["gameRecordingOn": false],
            replyHandler: nil,
            errorHandler: { error in
                print("⚠️ Failed to notify Watch: \(error.localizedDescription)")
            }
        )
        print("✅ Notified Watch that game ended")
    }


    // MARK: - Upload
    private func uploadAudioAndTranscript(audioURL: URL, transcript: String?, context: GameSessionContext, recordStartTime: Date, recordEndTime: Date) async {
        do {
            
            let fileName = "\(UUID().uuidString).m4a"
            let path = "audio/\(context.teamId)/\(context.gameId)/\(fileName)"
            
            // Upload audio file to database
            StorageManager.shared.uploadAudioFile(localFile: audioURL, path: path) { result in
                switch result {
                case .success(let downloadURL):
                    print("Audio uploaded! URL: \(downloadURL)")
                    // Store this in Firestore
                case .failure(let error):
                    print("Error uploading audio: \(error.localizedDescription)")
                }
            }
            
            if self.dependencies.currentGameRecordingsContext == nil {
                self.dependencies.currentGameRecordingsContext = GameRecordingsContext()
            }
            let feedbackFor = try await getPlayerAssociatedToFeedback(transcript: transcript ?? "", players: context.players ?? [])
            
            if let feedbackFor = feedbackFor {
                var tmpFeedback: [String] = []
                tmpFeedback.append(feedbackFor.firstName)
                if let nick = feedbackFor.nickname { tmpFeedback.append(nick) }

                // transcript = normalizeTranscript(transcript, roster: tmpFeedback)
            }
            
            // Determine which players the feedback is for
            try await addTranscriptToDB(
                teamId: context.teamId,
                gameId: context.gameId,
                uploadedBy: context.uploadedBy,
                recordingStart: recordStartTime,
                recordingEnd: recordEndTime,
                transcription: transcript ?? "",
                feedbackFor: feedbackFor,
                players: context.players,
                pathAudioURL: path
            )

//            if let players = context.players {
//                let feedbackFor = try await getPlayerAssociatedToFeedback(transcript: transcript ?? "", players: players)
//                
//                if let feedbackFor = feedbackFor {
//                    var tmpFeedback: [String] = []
//                    tmpFeedback.append(feedbackFor.firstName)
//                    if let nick = feedbackFor.nickname { tmpFeedback.append(nick) }
//
////                            transcript = normalizeTranscript(transcript, roster: tmpFeedback)
//                }
//                
//                // Determine which players the feedback is for
//                var fbFor: [String]?
//                if feedbackFor == nil {
//                    // Associate the feedback to every player on the team
//                    fbFor = players.map { $0.playerId }
//                } else {
//                    // Add a new key moment to the database
//                    fbFor = feedbackFor.map { [$0.playerId] } ?? []
//                }
//                   
//                try await addTranscriptToDB(
//                    teamId: context.teamId,
//                    gameId: context.gameId,
//                    uploadedBy: context.uploadedBy,
//                    recordingStart: recordStartTime,
//                    recordingEnd: recordEndTime,
//                    transcription: transcript ?? "",
//                    feedbackFor: fbFor,
//                    pathAudioURL: path
//                )
//            } else {
//
//            }
//            // Create a new key moment entry
//            let keyMomentDTO = KeyMomentDTO(fullGameId: nil, gameId: context.gameId, uploadedBy: context.uploadedBy, audioUrl: path, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: fbFor)
//            
//            // Add a new key moment to the database
//            let keyMomentDocId = try await dependencies?.keyMomentManager.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO)
//            guard let safeKeyMomentId = keyMomentDocId else {
//                print("Error: The key moment doc ID is nil. Aborting.")
//                return
//            }
//
//            
//            let audioURLResult = try await dependencies.storageManager.uploadAudioFile(localFile: audioURL, path: path)
//            print("✅ Uploaded audio to \(audioURLResult)")
//            
//            let metadata = [
//                "path": path,
//                "transcript": transcript ?? "",
//                "timestamp": Date().ISO8601Format()
//            ]
//            
//            try await dependencies.firestoreManager.addDocument(collection: "recordings", data: metadata)
            print("📤 Uploaded transcription + metadata to Firestore")

            // Clean up
            try? FileManager.default.removeItem(at: audioURL)
        } catch {
            print("🔥 Upload error: \(error.localizedDescription)")
        }
    }
    
    private func addTranscriptToDB(teamId: String, gameId: String, uploadedBy: String, recordingStart: Date, recordingEnd: Date, transcription: String, feedbackFor: PlayerTranscriptInfo?, players: [PlayerTranscriptInfo]?, pathAudioURL: String) async throws {
        do {
            
            var fbFor: [String]?
            if let players = players, feedbackFor == nil {
                // Associate the feedback to every player on the team
                fbFor = players.map { $0.playerId }
            } else {
                // Add a new key moment to the database
                fbFor = feedbackFor.map { [$0.playerId] } ?? []
            }

            print("Adding key moment & transcript to db")
            // Create a new key moment entry
            let keyMomentDTO = KeyMomentDTO(
                fullGameId: nil,
                gameId: gameId,
                uploadedBy: uploadedBy,
                audioUrl: pathAudioURL,
                frameStart: recordingStart,
                frameEnd: recordingEnd,
                feedbackFor: fbFor
            )
            
            // Add a new key moment to the database
            guard let keyMomentDocId = try await dependencies.keyMomentManager.addNewKeyMoment(teamId: teamId, keyMomentDTO: keyMomentDTO) else {
                print("Error: The key moment doc ID is nil. Aborting.")
                return
            }
            
            // Add a new transcript to the database
            let confidence: Int = 5 // Should be from 1 to 5 where 1 is the lowest and 5 is most confident
            
            // Create a new transcript entry
            let transcriptDTO = TranscriptDTO(
                keyMomentId: keyMomentDocId,
                transcript: transcription,
                language: "English",
                generatedBy: uploadedBy,
                confidence: confidence,
                gameId: gameId
            )
            
            // Add a new transcript to the database
            guard let transcriptDocId = try await dependencies.transcriptManager.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO) else {
                print("Error: the transcript doc ID is nil.")
                return
            }

            // TODO: Update the feedback for array that is showed on the audio and video views (local array)
            
            var feedbackForArray: [PlayerTranscriptInfo] = []
            
            if let feedback = feedbackFor {
                print("append feedback")
                feedbackForArray.append(feedback)
                // Add a new recording to the array
                let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: "\(recordingsLength)", transcriptId: "\(recordingsLength)", transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                
                //                        let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
            } else {
                // if there are players on the team, then associate to each one of them
                if let playersInTeam = players {
                    print("append all players")
                    feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                    let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                    // Add a new recording to the array
                    //                            let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                    let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: "\(recordingsLength)", transcriptId: "\(recordingsLength)", transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                    
                    //                            self.recordings.append(newRecording)
                    self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                } else {
                    print("no feedback")
                }
            }
            
        } catch {
            print("Error when adding a new recording to the database from watchOS.")
            return
        }
    }
    
    private func getPlayerAssociatedToFeedback(transcript: String, players: [PlayerTranscriptInfo]) async throws -> PlayerTranscriptInfo? {
        // Normalize transcript -> tokens
        let tokens = transcript
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }

        let grams = ngrams(from: tokens, maxN: 3)

        var bestPlayer: PlayerTranscriptInfo?
        var bestScore: Double = 0.0
        let threshold: Double = 0.70 // tune between ~0.6 - 0.85

        for player in players {
            // candidate name variants
            var candidates: [String] = []
            candidates.append(player.firstName)
            candidates.append(player.lastName)
            if let nick = player.nickname { candidates.append(nick) }

            for cand in candidates {
                let candNorm = cand.normalizedForMatching()
                for gram in grams {
                    let score = similarity(candNorm, gram.normalizedForMatching())
                    if score > bestScore {
                        bestScore = score
                        bestPlayer = player
                    }
                }
            }
        }

        if let p = bestPlayer, bestScore >= threshold {
            print("Matched player: \(p.firstName) \(p.lastName) with score \(bestScore)")
            return p
        } else {
            print("No confident match (bestScore=\(bestScore)); returning nil")
            return nil
        }

    }
    

    // MARK: - WCSessionDelegate boilerplate
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            print("iPhone session activated: \(activationState.rawValue), error: \(String(describing: error))")
        print("iPhone session isPaired: \(session.isPaired)")
        print("iPhone session isWatchAppInstalled: \(session.isWatchAppInstalled)")
        print("iPhone session isReachable: \(session.isReachable)")
        }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("📩 Received message: \(message)")
        do {
            // Receiving metadata
            let recordStartTime = message["recording_start_time"] as? Date
            let recordEndTime = message["recording_end_time"] as? Date
            let transcript = message["test_transcript"] as? String

            guard let context = dependencies.currentGameContext else {
                print("⚠️ No current game context available.")
                return
            }
            
            DispatchQueue.main.async {
                if self.dependencies.currentGameRecordingsContext == nil {
                    self.dependencies.currentGameRecordingsContext = GameRecordingsContext()
                }
                
                Task {
                    if let players = context.players {
                        let player = try await self.getPlayerAssociatedToFeedback(transcript: transcript!, players: players)
                        if let feedbackFor = player {
                            var tmpFeedback: [String] = []
                            tmpFeedback.append(feedbackFor.firstName)
                            if let nick = feedbackFor.nickname { tmpFeedback.append(nick) }
                            
                            //                            transcript = normalizeTranscript(transcript, roster: tmpFeedback)
                        }
                        
                        // Determine which players the feedback is for
                        var fbFor: [String]?
                        if player == nil {
                            // Associate the feedback to every player on the team
                            fbFor = players.map { $0.playerId }
                        } else {
                            // Add a new key moment to the database
                            fbFor = player.map { [$0.playerId] } ?? []
                        }
                                                
                        var feedbackForArray: [PlayerTranscriptInfo] = []
                        
                        if let feedback = player {
                            print("append feedback")
                            feedbackForArray.append(feedback)
                            // Add a new recording to the array
                            let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                            let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: "\(recordingsLength)", transcriptId: "\(recordingsLength)", transcript: transcript ?? "No transcript found", frameStart: recordStartTime!, frameEnd: recordEndTime!, feedbackFor: feedbackForArray)
                            
                            //                        let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                            self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                        } else {
                            // if there are players on the team, then associate to each one of them
                            if let playersInTeam = context.players {
                                print("append all players")
                                feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                                let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                                // Add a new recording to the array
                                //                            let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: safeKeyMomentId, transcriptId: transcriptDocId, transcript: transcription, frameStart: recordingStart, frameEnd: recordingEnd, feedbackFor: feedbackForArray)
                                let newRecording = keyMomentTranscript(id: recordingsLength, keyMomentId: "\(recordingsLength)", transcriptId: "\(recordingsLength)", transcript: transcript ?? "No transcript found", frameStart: recordStartTime!, frameEnd: recordEndTime!, feedbackFor: feedbackForArray)
                                
                                //                            self.recordings.append(newRecording)
                                self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                            } else {
                                print("no feedback")
                            }
                        }
                    }
                }
            }
        } catch {
            print("error when receiving message: \(error)")
        }
    }
}
