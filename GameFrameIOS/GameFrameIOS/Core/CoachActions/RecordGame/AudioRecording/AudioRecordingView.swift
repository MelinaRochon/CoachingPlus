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
        
    // AudioRecordingModel that manages key moments and transcripts
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    
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
    @Binding var errorWrapper: ErrorWrapper?
    @State var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    // Audio recording session and recorder states
    @State var session : AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert: Bool = false
    
    // Array to hold recorded audio file URLs
    @State var audios: [URL] = []
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                if !audioRecordingModel.recordings.isEmpty {
                    ScrollViewReader { proxy in
                        List {
                            Section(header: Text("Transcripts added")) {
                                ForEach(audioRecordingModel.recordings, id: \.id) { recording in
                                    RecordingRowView(recording: recording, players: audioRecordingModel.players)
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
                NavigationLink(destination: CoachMainTabView(showLandingPageView: .constant(false)), isActive: $navigateToHome) { EmptyView()
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
                    
                    // Initialising the audio recorder
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord)
                    
                    // requesting permission
                    // require microphone usage description
                    self.session.requestRecordPermission{ (status) in
                        if !status {
                            // error msg
                            self.alert.toggle()
                        } else {
                            // if permission is granted, fetching data
                            self.getAudios()
                        }
                    }
                } catch {
                    print("Error when loading the audio recording transcripts. Error: \(error)")
                }
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
            self.getAudios() // updating data
            
            if let startTime = recordingStartTime {
                let endTime = Date()
                audioRecordingModel.gameId = gameId
                audioRecordingModel.teamId = teamId
                
                Task {
                    do {
                        try await endRecording()  // Wait for the transcription to finish
                        
                        // Get the generated transcript
                        let transcript = speechRecognizer.transcript
                        
                        // Get the player that is associated to the transcript
                        let feedbackFor = try await getPlayerAssociatedToTranscript(transcript: transcript)
                        
                        // Cut the transcript to see if the name of the player is in the transcript
                        // See which player the transcript is associated to
                        try await audioRecordingModel.addRecording(recordingStart: startTime, recordingEnd: endTime, transcription: transcript, feedbackFor: feedbackFor)
                    } catch {
                        errorWrapper = ErrorWrapper(error: error, guidance: "Error when saving the audio recording. Please try again later.")
                    }
                }
            }
            
            // Reset the recording start and end times
            recordingStartTime = nil
        }
    }
    
    
    // MARK: - Helper Functions

    /// Initializes the audio recording session
    private func initializeAudioRecording() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileName = url.appendingPathComponent("test\(self.audios.count + 1).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
            print("Saving audio file at: \(fileName.path)")
            
            self.recorder.record()
        } catch {
            print(error.localizedDescription)
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
    
    
    /// Attempts to associate the transcription with a player by matching names or nicknames
    private func getPlayerAssociatedToTranscript(transcript: String) async throws -> PlayerTranscriptInfo? {
        var playerAssociated: PlayerTranscriptInfo? = nil
        if let players = audioRecordingModel.players {
            print("we have some oplayers")
            for player in players {
                // check if the transcript is associated to a player
                print("current player : \(player.firstName) \(player.lastName), nickname : \(player.nickname ?? "none")")
                
                if let nickname = player.nickname {
                    // check if the player's nickname is mentionned in the transcript
                    if transcript.contains(nickname) {
                        playerAssociated = player
                        print("found player wth nickname")
                        return playerAssociated
                    }
                }
                if transcript.contains(player.firstName) {
                    playerAssociated = player
                    print("found player wth name")
                    
                    return playerAssociated
                }
            }
        }
        
        return nil
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
    
        
    /// Fetches all saved audio files from the document directory
    func getAudios() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // fetch all data from document directory...
            let results = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            // Add all the files in the audio array
            for i in results {
                self.audios.append(i)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    AudioRecordingView(teamId: "", errorWrapper: .constant(nil))
}


/**
 This structure displays a row of a saved audio recording's transcript with the associated players' names.

 - `recording`: The transcript of the recording containing the key moment's data.
 - `players`: A list of players to be checked against the transcript to determine if feedback was given to any specific player.
 */
struct RecordingRowView: View {
    var recording: keyMomentTranscript
    var players: [PlayerTranscriptInfo]? = []

    var body: some View {
        VStack {
            HStack (alignment: .center) {
                // Calculate the duration of the recording from the start and end times
                let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                // Display the formatted duration of the recording
                Text(formatDuration(durationInSeconds)).bold().font(.headline)
                VStack {
                    Text("Transcript: \(recording.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    
                    // Check if the recording has feedback associated with it
                    if let feedbackFor = recording.feedbackFor {
                        // Check if feedback matches the number of players on the team
                        if let playersOnTeam = players {
                            if feedbackFor.count == playersOnTeam.count {
                                // If feedback is given to all players, display "All"
                                HStack {
                                    Text("All").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
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
                        Text("\(player.firstName) \(player.lastName) ").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    }.tag(player.playerId as String)
                }
            }
        }
    }
}
