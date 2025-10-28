//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI
import TimerKit
import AVFoundation
import TranscriptionKit
import AVKit
import FirebaseStorage

/***
 This view is responsible for handling audio recording during a game session. It starts and stops audio recordings, manages transcriptions, and adds the resulting transcripts as key moments to the database.
 The user can start/stop the recording with a button, view saved transcripts, and associate the transcription with players based on the content.

 It also provides a navigation link to the main tab view once the recording ends.

 Key Responsibilities:
 - Initialize and manage audio recording using AVFoundation.
 - Transcribe the audio to text and associate the transcription with specific players.
 - Store and display the resulting transcripts.
 - Allow the user to end the recording and navigate to the main view.
 */
struct AudioRecordingView: View {
    
    // MARK: - ViewModel and State Variables
    
    let coachId: String
        
    @Binding var showLandingPageView: Bool

    // AudioRecordingModel that manages key moments and transcripts
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    // The start time of the recording
    @State private var recordingStartTime: Date?
    
    // Unique identifiers for the game and team
    @State private var gameId: String = ""
    @State var teamId: String = ""
    
    // State to control the visibility of the stop recording alert
    @State private var showStopRecordingAlert: Bool = false
    
    // Navigation state for transitioning back to the main page
    @State private var navigateToHome = false
    
    // Timer and speech recognition states
    @State var timer = ScrumTimer()
    
    @State private var errorWrapper: ErrorWrapper?

    @State var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    // Audio recording session and recorder states
    @State var session : AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert: Bool = false
    
    // Array to hold recorded audio file URLs
    @State var audios: [URL] = []
    
    @State private var gameStartTime: Date = Date()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                if !audioRecordingModel.recordings.isEmpty {
                    ScrollViewReader { proxy in
                        List {
                            Section(header: Text("Transcripts added")) {
                                ForEach(audioRecordingModel.recordings, id: \.id) { recording in
                                    RecordingRowView(recording: recording, players: audioRecordingModel.players, gameStart: gameStartTime)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .animation(.easeInOut(duration: 0.5), value: audioRecordingModel.recordings.count)
                        .onChange(of: audioRecordingModel.recordings.count) { newCount in
                            scrollToBottom(proxy: proxy, newCount: newCount)
                        }
                    }
                }
                // Audio Recording Button
                Spacer()
                Divider()
                VStack {
                    Spacer().frame(height: 20)
                    RecordingButtonView
                    { isRecording in
                        handleRecordingStateChange(isRecording)
                    }
                    Spacer().frame(height: 5)
                    
                }
                
                /** Link to go back to the main tab */
                NavigationLink(destination: CoachMainTabView(showLandingPageView: $showLandingPageView, coachId: coachId), isActive: $navigateToHome) { EmptyView()
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showStopRecordingAlert.toggle()
                    } label: {
                        Text("End Recording")
                    }.alert("Are you sure you want to stop recording?", isPresented: $showStopRecordingAlert) {
                        Button(role: .cancel) {
                            // Handle the cancelation
                        } label: {
                            Text("Cancel")
                        }
                        Button("End Recording") {
                            // Handle the end recording
                            // Update the game's duration, add the end time
                            // Let the user see a page after with the game's detail that he can edit?
                            Task {
                                do {
                                    try await audioRecordingModel.endAudioRecordingGame(teamId: teamId, gameId: gameId)
                                    // Go back to the main page
                                    removeAllTempAudioFiles(count: self.audios.count)
                                    navigateToHome = true
                                    
                                } catch {
                                    print("Error when ending recording. ")
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: self.$alert, content: {
                Alert(title: Text("Error"), message: Text("Enable Access"))
            })
            .task {
                do {
                    // Load all recordings that are already there, if there are some
                    // Start by creating a new game
                    let gameDocId = try await audioRecordingModel.addUnknownGame(teamId: teamId) // gameDocId
                    self.gameId = gameDocId ?? ""
                    
                    // Load the players of the team for the transcription
                    try await audioRecordingModel.loadPlayersForTranscription(teamId: teamId)
                    
                    if let players = audioRecordingModel.players {
                        let playerNames = players.compactMap { player in
                            [player.firstName, player.nickname].compactMap { $0 }
                        }.flatMap { $0 } // flatten

                        await speechRecognizer.updateContextualStrings(playerNames)
                        print("✅ Loaded player names into speech recognizer: \(playerNames)")
                    }
                    
                    // Get the game
                    let game = try await gameModel.getGame(teamId: teamId, gameId: gameId)
                    if game == nil {
                        throw GameValidationError.invalidStartTime
                    }
                    self.gameStartTime = game!.startTime ?? Date()
                    
                    // Initialising the audio recorder
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord, mode: .default)
                    
                    // requesting permission
                    // require microphone usage description
                    self.session.requestRecordPermission{ (status) in
                        if !status {
                            // error msg
                            self.alert.toggle()
                        }
                    }
                } catch {
                    print("Error when loading the audio recording transcripts. Error: \(error)")
                }
            }
            .onAppear {
                gameModel.setDependencies(dependencies)
                audioRecordingModel.setDependencies(dependencies)
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Helper Functions
        
    /// Handles the change of recording state (start/stop)
    func handleRecordingStateChange(_ isRecording: Bool) {
        if isRecording {
            // Start Recording: Capture start time
            
            // Initialize
            // Going to store audio in document directory...
            initializeAudioRecording()
            startRecording()
            
        } else {
            // Stop Recording: Save to recordings
            self.recorder.stop()
            
            if let startTime = recordingStartTime {
                let endTime = Date()
                audioRecordingModel.gameId = gameId
                audioRecordingModel.teamId = teamId
                
                Task {
                    do {
                        try await endRecording()  // Wait for the transcription to finish
                        
                        // Get the generated transcript
                        var transcript = speechRecognizer.transcript
                        
                        // Get the player that is associated to the transcript
                        let feedbackFor = try await getPlayerAssociatedToTranscript(transcript: transcript)
                        
                        if let feedbackFor = feedbackFor {
                            var tmpFeedback: [String] = []
                            tmpFeedback.append(feedbackFor.firstName)
                            if let nick = feedbackFor.nickname { tmpFeedback.append(nick) }

                            transcript = normalizeTranscript(transcript, roster: tmpFeedback)
                        }
                        
                        print("feedbackFor: \(feedbackFor)")
                        
                        // Cut the transcript to see if the name of the player is in the transcript
                        // See which player the transcript is associated to
                        try await audioRecordingModel.addRecording(recordingStart: startTime, recordingEnd: endTime, transcription: transcript, feedbackFor: feedbackFor, numAudioFiles: self.audios.count )
                        
                        print("AUDIO: \(self.audios)")
                    } catch {
                        errorWrapper = ErrorWrapper(error: error, guidance: "Error when saving the audio recording. Please try again later.")
                    }
                }
            }
            
            // Reset the recording start and end times
            recordingStartTime = nil
        }
    }
    
    
    func bestMatch(for word: String, in roster: [String]) -> String? {
        // naive example using Levenshtein or similar
        roster.min { lhs, rhs in
            levenshtein(word.lowercased(), lhs.lowercased()) <
            levenshtein(word.lowercased(), rhs.lowercased())
        }
    }
    
    func normalizeTranscript(_ transcript: String, roster: [String]) -> String {
        let words = transcript.split(separator: " ").map { String($0) }
        var correctedWords: [String] = []
        
        for word in words {
            if let match = bestMatch(for: word, in: roster),
               match.lowercased().first == word.lowercased().first {
                // extra guard so "Sofia" doesn't replace "Good"
                correctedWords.append(match)
            } else {
                correctedWords.append(word)
            }
        }
        
        return correctedWords.joined(separator: " ")
    }
    
    // MARK: - Helper Functions

    /// Initializes the audio recording session
    private func initializeAudioRecording() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let audioDir = url.appendingPathComponent("audio/\(teamId)/\(gameId)", isDirectory: true)

        do {

            try FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
            let tempURL =  audioDir.appendingPathComponent("\(self.audios.count + 1).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            
            self.recorder = try AVAudioRecorder(url: tempURL, settings: settings)
            
            self.audios.append(tempURL)
            print("Saving audio file at: \(tempURL.path)")
            
            self.recorder.record()
        } catch {
            print("❌ Failed to create audio directory: \(error.localizedDescription)")
        }
    }
    
    func removeAllTempAudioFiles(count: Int) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        for index in 1...count {
            let fileURL = documentsURL
                .appendingPathComponent("audio/\(teamId)/\(gameId)/\(index)")
                .appendingPathExtension("m4a")

            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("✅ Deleted: \(fileURL.lastPathComponent)")
                } catch {
                    print("❌ Failed to delete \(fileURL.lastPathComponent): \(error.localizedDescription)")
                }
            } else {
                print("⚠️ File not found: \(fileURL.path)")
            }

        }
    }
    
    
    /// Starts the transcription process
    private func startRecording() {
        speechRecognizer.resetTranscript() // reset the transcription
        speechRecognizer.startTranscribing() // start the speech to text transcript
        
        // set the start time
        recordingStartTime = Date()
    }
    
    
    /// Ends the transcription process after a delay to ensure all speech is transcribed
    private func endRecording() async throws {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5-second delay
        speechRecognizer.stopTranscribing()
    }
    
    
    private func levenshtein(_ s: String, _ t: String) -> Int {
        let s = Array(s)
        let t = Array(t)
        if s.isEmpty { return t.count }
        if t.isEmpty { return s.count }
        var v0 = Array(0...t.count)
        var v1 = [Int](repeating: 0, count: t.count + 1)
        for i in 0..<s.count {
            v1[0] = i + 1
            for j in 0..<t.count {
                let cost = s[i] == t[j] ? 0 : 1
                v1[j+1] = Swift.min(
                    v1[j] + 1,          // insertion
                    v0[j+1] + 1,        // deletion
                    v0[j] + cost        // substitution
                )
            }
            v0 = v1
        }
        return v1[t.count]
    }

    private func similarity(_ a: String, _ b: String) -> Double {
        let a = a.normalizedForMatching()
        let b = b.normalizedForMatching()
        if a.isEmpty && b.isEmpty { return 1.0 }
        let dist = Double(levenshtein(a, b))
        let maxLen = Double(max(a.count, b.count))
        return 1.0 - (dist / maxLen) // between 0.0 and 1.0
    }

    private func ngrams(from words: [String], maxN: Int = 3) -> [String] {
        var result: [String] = []
        for n in 1...maxN {
            if words.count < n { break }
            for i in 0...(words.count - n) {
                result.append(words[i..<(i+n)].joined(separator: " "))
            }
        }
        return result
    }

    // replacement getPlayerAssociatedToTranscript
    private func getPlayerAssociatedToTranscript(transcript: String) async throws -> PlayerTranscriptInfo? {
        guard let players = audioRecordingModel.players else { return nil }

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
    
        
    /// Scrolls the list to the most recent transcript
    private func scrollToBottom(proxy: ScrollViewProxy, newCount: Int) {
        guard let lastItem = audioRecordingModel.recordings.last else { return }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.8)) { // Smooth scrolling
                proxy.scrollTo(lastItem.id, anchor: .bottom)
            }
        }
    }
    
    
    /** This function stops the recording manually */
    func stopRecordingManually() {
        handleRecordingStateChange(false)
    }
    
    
    func getAudios() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let folderURL = documentsURL
            .appendingPathComponent("audio/\(teamId)/\(gameId)", isDirectory: true)

        do {
            // Get all files in the specified folder
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

            // Filter only .m4a audio files
            let audioFiles = fileURLs.filter { $0.pathExtension.lowercased() == "m4a" }

            // Append to your audio list
            self.audios.append(contentsOf: audioFiles)

            print("✅ Found \(audioFiles.count) audio files.")
        } catch {
            print("❌ Failed to get audio files: \(error.localizedDescription)")
        }
    }
}

// helper extensions / funcs (put near the top of the file)
extension String {
    func normalizedForMatching() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
}



#Preview {
    AudioRecordingView(coachId: "", showLandingPageView: .constant(false), teamId: "")
}


/**
 This structure displays a row of a saved audio recording's transcript with the associated players' names.

 - `recording`: The transcript of the recording containing the key moment's data.
 - `players`: A list of players to be checked against the transcript to determine if feedback was given to any specific player.
 - `gameStart`: The game start time to show the time the transcription started since the begining of the game.
 */
struct RecordingRowView: View {
    var recording: keyMomentTranscript
    var players: [PlayerTranscriptInfo]? = []
    var gameStart: Date
    
    var body: some View {
        VStack {
            HStack (alignment: .center) {
                // Calculate the duration of the recording from the start and end times
                let durationInSeconds = recording.frameStart.timeIntervalSince(gameStart)
                // Display the formatted duration of the recording
                Text(formatDuration(durationInSeconds)).bold().font(.headline).frame(width: 85)

                VStack {
                    Text("\(recording.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    
                    // Check if the recording has feedback associated with it
                    if let feedbackFor = recording.feedbackFor {
                        // Check if feedback matches the number of players on the team
                        if let playersOnTeam = players {
                            if feedbackFor.count == playersOnTeam.count {
                                // If feedback is given to all players, display "All"
                                HStack {
                                    Text("All").font(.caption).foregroundStyle(Color.orange).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                                }
                            } else {
                                // Otherwise, display the names of specific players that received feedback
                                PlayersNameView(feedbackFor: feedbackFor)
                            }
                        } else {
                            // If no player list is available, still show the feedback names
                            PlayersNameView(feedbackFor: feedbackFor)
                        }
                    }
                }
            }
        }
    }
    
    
   
}


/**
 This structure displays the names of players who received feedback associated with a transcript.

 - `feedbackFor`: A list of players who were given feedback in the recording, based on the transcript.
 */
private struct PlayersNameView: View {
    var feedbackFor: [PlayerTranscriptInfo]? = []

    var body: some View {
        HStack {
            // Loop through the feedback array and display each player's name
            if let players = feedbackFor {
                ForEach(players, id: \.playerId) { player in
                    HStack {
                        // Display player's first and last name
                        Text("\(player.firstName) \(player.lastName) ").font(.caption).foregroundStyle(Color.red).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    }.tag(player.playerId as String)
                }
            }
        }
    }
}
