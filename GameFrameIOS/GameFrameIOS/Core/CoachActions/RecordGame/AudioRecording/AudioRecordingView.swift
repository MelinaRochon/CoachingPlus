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
 This structure is called to start an audio recording. When an audio recording starts, it transcribes the
 speech to text, and adds it as a new keyMoment and a new transcript object to the database.
 */
struct AudioRecordingView: View {
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    
    @State private var recordingStartTime: Date?
    @State private var gameId: String = ""
    @State var teamId: String = ""
    @State private var showStopRecordingAlert: Bool = false
    @State private var navigateToHome = false
    
    @State var timer = ScrumTimer()
    @Binding var errorWrapper: ErrorWrapper?
    @State var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    // creating instance for recording
    @State var session : AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert: Bool = false
    
    // Fetch Audios
    @State var audios: [URL] = []
    
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
    
    /** Initialize the audio recording */
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
    
    /** Start the transcript and save the start time when recording. */
    private func startRecording() {
        speechRecognizer.resetTranscript() // reset the transcription
        speechRecognizer.startTranscribing() // start the speech to text transcript
        
        // set the start time
        recordingStartTime = Date()
    }
    
    /** End the transcript after a delay of half a second to make sure all the speech to text was transcribed successfully and stop the transcript */
    private func endRecording() async throws {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5-second delay
        speechRecognizer.stopTranscribing()
    }
    
    /** Find the player that is associated to the transcription */
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
    
    /** Scroll to bottom of the list - helper function */
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
        
    /** Get all the saved audio files in the directory */
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


/** This structure is called to show the player's names associated with the saved feedback (transcript) */
struct RecordingRowView: View {
    var recording: keyMomentTranscript
    var players: [PlayerTranscriptInfo]? = []

    var body: some View {
        VStack {
            HStack (alignment: .center) {
                let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                Text(formatDuration(durationInSeconds)).bold().font(.headline)
                VStack {
                    Text("Transcript: \(recording.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    if let feedbackFor = recording.feedbackFor {
                        // check if the feedback for array is the same length as the number of players on the team
                        if let playersOnTeam = players {
                            if feedbackFor.count == playersOnTeam.count {
                                HStack {
                                    Text("All").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                                }
                            } else {
                                PlayersNameView(feedbackFor: feedbackFor)
                            }
                        } else {
                            PlayersNameView(feedbackFor: feedbackFor)
                        }
                    }
                }
            }
        }
    }    
}

/** This structure is called when the player's name needs to be showed once the audio recording has been saved */
private struct PlayersNameView: View {
    var feedbackFor: [PlayerTranscriptInfo]? = []

    var body: some View {
        HStack {
            if let players = feedbackFor {
                ForEach(players, id: \.playerId) { player in
                    HStack {
                        Text("\(player.firstName) \(player.lastName) ").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                    }.tag(player.playerId as String)
                }
            }
        }
    }
}
