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
        
    @Binding var showLandingPageView: Bool

    // AudioRecordingModel that manages key moments and transcripts
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var gameModel = GameModel()

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
    
    @State private var gameStartTime: Date = Date()
    
//    init(teamId: String, errorWrapper: ErrorWrapper?, showLandingPageView: Binding<Bool>) {
//        self.teamId = teamId
//        self.errorWrapper = errorWrapper
//        self._showLandingPageView = showLandingPageView
//    }
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
                NavigationLink(destination: CoachMainTabView(showLandingPageView: $showLandingPageView), isActive: $navigateToHome) { EmptyView()
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
                    
                    // Get the game
                    let game = try await gameModel.getGame(teamId: teamId, gameId: gameId)
                    if game == nil {
                        throw GameValidationError.invalidStartTime
                    }
                    self.gameStartTime = game!.startTime ?? Date()
                    
                    // Initialising the audio recorder
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord)
                    
                    // requesting permission
                    // require microphone usage description
                    self.session.requestRecordPermission{ (status) in
                        if !status {
                            // error msg
                            self.alert.toggle()
                        }
                        //self.audios.removeAll()

//                        else {
//                            // if permission is granted, fetching data
//                            self.getAudios()
//                        }
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
//            self.getAudios() // updating data
            
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
    
    
    // MARK: - Helper Functions

    /// Initializes the audio recording session
    private func initializeAudioRecording() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let audioDir = url.appendingPathComponent("audio/\(teamId)/\(gameId)", isDirectory: true)

        do {

            try FileManager.default.createDirectory(at: audioDir, withIntermediateDirectories: true)
            let tempURL =  audioDir.appendingPathComponent("\(self.audios.count + 1).m4a")
//            let tempURL = url.appendingPathComponent("audio/\(teamId)/\(gameId)/\(self.audios.count + 1)")
//                .appendingPathExtension("m4a")
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
    
    //Saving audio file at: /Users/melina_rochon/Library/Developer/CoreSimulator/Devices/FA1F232C-56E4-4236-B408-CDDF90C3F447/data/Containers/Data/Application/55697331-1F14-4225-82C3-7A2F203DDB43/Documents/test55.m4a

//    let audioURL = URL(fileURLWithPath: "/path/to/audio.m4a")
//    uploadAudioFile(localFile: audioURL, fileName: "coach_feedback_001.m4a") { result in
//        switch result {
//        case .success(let url):
//            print("Audio uploaded! File available at: \(url)")
//        case .failure(let error):
//            print("Upload failed: \(error.localizedDescription)")
//        }
//    }
//
//    
//    func uploadAudioFile(localFile: URL, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        // 1. Create a reference to the location in Firebase Storage
////        let storageRef = Storage.storage().reference().child("audio/\(fileName)")
//        
//        let fileName = "\(UUID().uuidString).m4a"
//        let path = "audio/\(teamId)/\(gameId)/\(fileName)"
//        let audioRef = StorageManager.shared.storage.child(path)
//        
////        let bucket = "gs://gameframe-4ea7d.firebasestorage.app"
////        let storagePath = "\(bucket)/audio/\(fileName)"
//        
//        // 2. Upload the file
//        let uploadTask = audioRef.putFile(from: localFile, metadata: nil) { metadata, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            // 3. Once uploaded, get the download URL
//            audioRef.downloadURL { url, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                if let downloadURL = url {
//                    completion(.success(downloadURL))
//                }
//            }
//        }
//    }

    
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
        
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        let audioFilename = "test29.m4a"
//
//        // Construct the full local file URL
//        let localURL = documentsPath.appendingPathComponent(audioFilename)
//
//        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent(UUID().uuidString)
//            .appendingPathExtension("m4a")
//        
//        uploadAudioFile(localFile: localURL, fileName: "coach_feedback_test.m4a") { result in
//            switch result {
//            case .success(let url):
//                print("Audio uploaded! File available at: \(url)")
//            case .failure(let error):
//                print("Upload failed: \(error.localizedDescription)")
//            }
//        }


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
//    func getAudios() {
//        let fileManager = FileManager.default
//
//        let folderURL = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent("audio/\(teamId)/\(gameId)", isDirectory: true)
//
//        do {
////            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
////            do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//
//            // fetch all data from document directory...
////            let results = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
//            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
//
//            // Add all the files in the audio array
//            for i in audioFiles {
//                self.audios.append(i)
//            }
//        } catch {
//            print("ALLLOSSS>>>> \(error.localizedDescription)")
//        }
//    }
    
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

#Preview {
    AudioRecordingView(showLandingPageView: .constant(false), teamId: "", errorWrapper: .constant(nil))
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
