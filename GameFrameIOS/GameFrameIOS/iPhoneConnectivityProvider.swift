///
///  WatchConnecter.swift
///  GameFrameIOS
///
///  Created by Mélina Rochon on 2025-11-10.
///

import WatchConnectivity
import Foundation
import GameFrameIOSShared

final class iPhoneConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    private let dependencies: DependencyContainer
    private var timer: Timer? // For heartbeats messages to the watch while the game is running
    
    var canRecordWithWatch: Bool {
        session.isPaired &&
        session.isWatchAppInstalled
    }
    
    func isWatchReadyForRecording() -> Bool {
        return session.isPaired && session.isWatchAppInstalled
    }
    
    @Published var watchAppVersion: String? = nil
    
    var isWatchReachable: Bool {
        session.isReachable
    }
    
    var isWatchVersionValid: Bool {
        guard let version = watchAppVersion else { return false }
        print("versions: \(version)")
        return version.compare("1.2.0", options: .numeric) != .orderedAscending
    }
    
    init(session: WCSession = .default, dependencies: DependencyContainer) {
        self.session = session
        self.dependencies = dependencies
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func startHeartbeats() {
        stopHeartbeats() // ensure no duplicates
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.sendHeartbeat()
        }
    }
    
    func stopHeartbeats() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sendHeartbeat() {
        guard session.isReachable else { return }
        session.sendMessage(["heartbeat": true], replyHandler: nil) { error in
            print("Failed to send heartbeat: \(error.localizedDescription)")
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
        print(" --- file : \(file.fileURL)")

        // Receiving metadata
        let recordStartTime = metadata["recording_start_time"] as? Date
        let recordEndTime = metadata["recording_end_time"] as? Date
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent("watch_audio", isDirectory: true)

        // Create the folder if needed
        try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let destination = folderURL.appendingPathComponent("\(UUID().uuidString).m4a")

        do {
            try fileManager.moveItem(at: file.fileURL, to: destination)
            print("Moved to:", destination)
        } catch {
            print("Failed to move file:", error)
            return
        }

        // Move file to a known temp destination
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
        }
    }
    
    func notifyWatchGameStarted(gameId: String) {
        guard session.isReachable else {
            print("⌛ Watch not reachable, queuing game start info")
            WCSession.default.transferUserInfo(["gameRecordingOn": true])
            return
        }
        

        session.sendMessage(
            ["gameRecordingOn": true],
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
            WCSession.default.transferUserInfo(["gameRecordingOn": true])
            return
        }
        
        print("->>>> ending game")
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
                DispatchQueue.main.async {
                    self.dependencies.currentGameRecordingsContext = GameRecordingsContext()
                }
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

            print("📤 Uploaded transcription + metadata to Firestore")

            // Clean up
//            try? FileManager.default.removeItem(at: audioURL)
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
            DispatchQueue.main.async {
            if let feedback = feedbackFor {
                feedbackForArray.append(feedback)
                
                // Add a new recording to the array
                let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                let newRecording = keyMomentTranscript(
                    id: recordingsLength,
                    keyMomentId: "\(recordingsLength)",
                    transcriptId: "\(recordingsLength)",
                    transcript: transcription,
                    frameStart: recordingStart,
                    frameEnd: recordingEnd,
                    feedbackFor: feedbackForArray
                )
                
                self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
            } else {
                // if there are players on the team, then associate to each one of them
                if let playersInTeam = players {
                    feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                    
                    let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                    // Add a new recording to the array
                    let newRecording = keyMomentTranscript(
                        id: recordingsLength,
                        keyMomentId: "\(recordingsLength)",
                        transcriptId: "\(recordingsLength)",
                        transcript: transcription,
                        frameStart: recordingStart,
                        frameEnd: recordingEnd,
                        feedbackFor: feedbackForArray
                    )
                    
                    self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                } else {
                    print("no feedback")
                }
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
            if let version = message["watchAppVersion"] as? String {
                DispatchQueue.main.async {
                    self.watchAppVersion = version
                }
            }
            
            if let recordStartTime = message["recording_start_time"] as? Date, let recordEndTime = message["recording_end_time"] as? Date, let transcript = message["test_transcript"] as? String {
                
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
                            let player = try await self.getPlayerAssociatedToFeedback(transcript: transcript, players: players)
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
                                let newRecording = keyMomentTranscript(
                                    id: recordingsLength,
                                    keyMomentId: "\(recordingsLength)",
                                    transcriptId: "\(recordingsLength)",
                                    transcript: transcript,
                                    frameStart: recordStartTime,
                                    frameEnd: recordEndTime,
                                    feedbackFor: feedbackForArray
                                )
                                
                                self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                            } else {
                                // if there are players on the team, then associate to each one of them
                                if let playersInTeam = context.players {
                                    print("append all players")
                                    feedbackForArray.append(contentsOf: playersInTeam.map { $0 })
                                    let recordingsLength = self.dependencies.currentGameRecordingsContext!.recordings.count
                                    // Add a new recording to the array
                                    let newRecording = keyMomentTranscript(
                                        id: recordingsLength,
                                        keyMomentId: "\(recordingsLength)",
                                        transcriptId: "\(recordingsLength)",
                                        transcript: transcript,
                                        frameStart: recordStartTime,
                                        frameEnd: recordEndTime,
                                        feedbackFor: feedbackForArray
                                    )
                                    
                                    self.dependencies.currentGameRecordingsContext!.recordings.append(newRecording)
                                } else {
                                    print("no feedback")
                                }
                            }
                        }
                    }
                }
            } else {
                // TODO: Add an alert here to let the user know the recording cannot be saved properly
                print("Could not get messages for recording_start_time, recording_end_time")
            }
        } catch {
            print("error when receiving message: \(error)")
        }
    }
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        print("📩 Received message w/ reply handler: \(message)")
        
        // 1. Handle game state request
        if message["requestState"] as? Bool == true {
            let isGameRunning = dependencies.currentGameContext != nil
            replyHandler(["gameRecordingOn": isGameRunning])
            return
        }
    }
}
