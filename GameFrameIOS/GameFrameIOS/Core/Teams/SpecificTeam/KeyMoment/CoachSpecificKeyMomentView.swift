//
//  CoachSpecificKeyMomentView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import AVKit
import AVFoundation
import GameFrameIOSShared

/// **Displays details of a specific key moment in a game.**
///
/// ### Features:
/// - Displays game and team details.
/// - Shows a video frame with a progress slider.
/// - Displays a transcript of the key moment.
/// - Integrates a comment section for feedback and discussions.
/// - Fetches relevant player feedback data asynchronously.
struct CoachSpecificKeyMomentView: View {
    
    /// Progress of the video playback (slider value).
    @State private var progress: Double = 0.0
    
    /// User input for adding a comment.
    @State private var comment: String = ""
    
    /// Total duration of the video clip (default: 180s).
    @State private var totalDuration: Double = 180
    
    /// The start duration  of the video clip (default: 0s).
    @State private var startDuration: Double = 0.0
    
    /// ViewModel for handling comments in the key moment discussion.
    @StateObject private var commentViewModel = CommentSectionViewModel()
    
    /// ViewModels for handling transcript-related logic.
    @StateObject private var transcriptModel = TranscriptModel()
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    
    /// View model responsible for fetching player information.
    @StateObject private var playerModel = PlayerModel()

    @EnvironmentObject private var dependencies: DependencyContainer
    
    /// The game associated with the key moment.
    @State var game: DBGame
    
    /// The team associated with the key moment.
    @State var team: DBTeam
    
    /// The specific key moment being viewed.
    @State var specificKeyMoment: keyMomentTranscript
    
    /// Stores feedback information for specific players.
    @State private var feedbackFor: [PlayerNameAndPhoto] = []
        
    /// Video player instance for handling playback in the view
    @State private var player: AVPlayer?
    
    /// Tracks whether the video is currently playing.
    @State private var isPlaying: Bool = false

    /// Indicates when the user is actively moving the seek slider.
    @State private var isSeeking: Bool = false
    
    @State var videoUrl: URL

    /// State variable to track whether the edit mode is active.
    @State private var isEditing: Bool = false
    @State private var dismissOnRemove: Bool = false
    
    @State private var originalTranscriptText: String = ""
    @State private var originalSelectedPlayers: [String] = []

    private var hasChanges: Bool {
        let currentSelectedPlayers = playersFeedback.filter { $0.isSelected }.map { $0.id }
        let samePlayers = Set(currentSelectedPlayers) == Set(originalSelectedPlayers)
        let sameTranscript = feedbackKeyMoment == originalTranscriptText
        
        return !(samePlayers && sameTranscript)
    }
    @State private var isInitialLoadComplete = false

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss

    /// Stores the editable transcript text when in edit mode.
    @State private var feedbackKeyMoment: String = ""
    
    /// Stores all players mapped into a feedback structure with selection state.
    @State private var playersFeedback: [PlayerFeedback] = []

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack (alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(game.title).font(.title2)
                            Spacer()
                        }
                        HStack {
                            Text("Key moment #\(specificKeyMoment.id+1)").font(.headline)
                            Spacer()
                        }.padding(.bottom, -2)
                        HStack (spacing: 0){
                            VStack(alignment: .leading) {
                                Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                                if let startTime = game.startTime {
                                    Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }.padding(.leading).padding(.trailing)
                    Divider()
                    
                    // Key moment Video Frame
                    VStack (alignment: .leading){
                        
                        if let player = player {
                            VStack (alignment: .leading) {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        goToStartOfKeyMoment(player: player)
                                    }) {
                                        Text("Go To Key Moment").font(.caption2).bold().padding(.horizontal, 8).padding(.vertical, 5)
                                    } .background(.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.top, 0)
                                        .foregroundColor(.white)
                                }
                                
                                // Video player
                                AVPlayerWithoutControls(player: player)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .onAppear {
                                        playTrimmedSegment(player: player)
                                        setupPlayer(to: player)
                                    }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Button(action: {
                                            if isPlaying {
                                                player.pause()
                                            } else {
                                                player.play()
                                            }
                                            isPlaying.toggle()
                                        }) {
                                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.red)
                                        }
                                        Text("").font(.caption)
                                    }
                                    
                                    VStack (alignment: .leading) {
                                        Slider(value: $progress, in: startDuration...totalDuration, onEditingChanged: { editing in
                                            if !editing {
                                                print("not editing")
                                                let targetTime = CMTime(seconds: progress, preferredTimescale: 600)
                                                player.seek(to: targetTime) { _ in
                                                    isSeeking = false
                                                }
                                            } else {
                                                isSeeking = true
                                            }
                                        })
                                        .tint(.gray) // Change color if needed
                                        .frame(height: 20) // Adjust slider height
                                        
                                        // Time Labels (Start Time & Remaining Time)
                                        HStack {
                                            Text(formatTime(progress)) // Current time
                                                .font(.caption)
                                            Spacer()
                                            Text("-\(formatTime(totalDuration - progress))") // Remaining time
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal).padding(.bottom)
                        } else {
                            VStack (alignment: .center) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 340, height: 180)
                                    .cornerRadius(10).padding(.bottom, 5)
                            }
                        }
                    }
                    
                    // Transcription section
                    VStack(alignment: .leading) {
                        Text("Transcription")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 2)
                        Text(specificKeyMoment.transcript)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }.padding(.bottom, 5)
                    
                    // Feedback for Section
                    VStack(alignment: .leading) {
                        Text("Feedback For")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text(feedbackFor.map { $0.name }.joined(separator: ", "))
                                .font(.caption)
                                .padding(.top, 2)
                        }
                        .multilineTextAlignment(.leading)
                    }.padding(.horizontal).padding(.vertical, 10)
                    
                    Divider()
                    
                    // Integrated CommentSectionView
                    CommentSectionView(
                        viewModel: commentViewModel,
                        teamDocId: team.id,
                        keyMomentId: String(specificKeyMoment.id),
                        gameId: game.gameId,
                        transcriptId: String(specificKeyMoment.transcript)
                    )
                }
            }
            .onChange(of: dismissOnRemove) { newValue in
                // Remove transcript from database
                Task {
                    do {
                        try await transcriptModel.removeTranscript(gameId: game.gameId, teamId: team.teamId, transcriptId: specificKeyMoment.transcriptId, keyMomentId: specificKeyMoment.keyMomentId)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                NavigationView {
                    FeedbackForView(dismissOnRemove: $dismissOnRemove, allPlayers: team.players, feedbackTranscript: $feedbackKeyMoment, playersFeedback: $playersFeedback)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(action: {
                                    resetData()
                                    isInitialLoadComplete = false
                                    isEditing = false // Dismiss the full-screen cover
                                }) {
                                    Text("Cancel")
                                }
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: {
                                    saveData()
                                    isInitialLoadComplete = false
                                    isEditing = false // Dismiss the full-screen cover
                                }) {
                                    Text("Save")
                                }
                                .disabled(!hasChanges || !isInitialLoadComplete)
                            }
                        }
                        .task {
                            do {
                                
                                if let allPlayers = team.players {
                                    print("getting all players = \(allPlayers)")
                                    let players = try await playerModel.getAllPlayersNamesAndUrl(players: allPlayers)
                                    // Map to include selection state
                                    playersFeedback = players.map { (id, name, photoUrl) in
                                        let isSelected = feedbackFor.contains { $0.playerId == id }
                                        return PlayerFeedback(id: id, name: name, photoUrl: photoUrl, isSelected: isSelected)
                                    }
                                }
                                
                                originalTranscriptText = feedbackKeyMoment
                                originalSelectedPlayers = feedbackFor.map { $0.playerId }
                                isInitialLoadComplete = true
                                
                            } catch {
                                print("Error when fetching specific footage info: \(error)")
                            }
                        }
                }
            }
            .onAppear {
                playerModel.setDependencies(dependencies)
                transcriptModel.setDependencies(dependencies)
                fgVideoRecordingModel.setDependencies(dependencies)
                audioRecordingModel.setDependencies(dependencies)
                commentViewModel.setDependencies(dependencies)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !isEditing {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Edit")
                    }
                    .frame(width: 40)
                    .foregroundColor(.red)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await loadVideoAndFeedback()
            do {
                print("CoachSpecificTranscript, teamDocId: \(team.id)")
                
                    if !isEditing
                    {
                        let feedback = specificKeyMoment.feedbackFor ?? []
                        
                        // Add a new key moment to the database
                        let fbFor: [String] = feedback.map { $0.playerId }
                        feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                        feedbackKeyMoment = specificKeyMoment.transcript
                    }
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
    }
        
    ///
    /// - Updates `feedbackFor` with the players that were selected in the UI.
    /// - Persists transcript text and feedbackFor players to the database.
    /// - Updates the local transcript state with the edited values.
    ///
    /// Errors are caught and logged if saving fails.
    private func saveData() {
        Task {
            do {
                feedbackFor = playersFeedback
                    .filter { $0.isSelected }
                    .map { PlayerNameAndPhoto(playerId: $0.id, name: $0.name, photoURL: $0.photoUrl) }
                
                try await transcriptModel.updateTranscriptInfo(teamDocId: team.id, teamId: team.teamId, gameId: game.gameId, transcriptId: specificKeyMoment.transcriptId, feedbackFor: feedbackFor, transcript: feedbackKeyMoment)
                
                
                playersFeedback = []
                specificKeyMoment.transcript = feedbackKeyMoment
                
            } catch {
                // Print error message if saving data fails
                print("Error occurred when saving the transcript data: \(error.localizedDescription)")
            }
        }
    }
    
    /// Resets the feedback transcript text field to the original transcript content.
    ///
    /// - If `transcript` exists, it restores `feedbackTranscript` with its value.
    /// - If `transcript` is `nil`, it resets to an empty string.
    private func resetData() {
        feedbackKeyMoment = specificKeyMoment.transcript
    }

    
    /// Loads video and feedback for the key moment:
    /// - Computes start/end times
    /// - Fetches player feedback
    /// - Gets video URL from Firebase and sets up the player
    private func loadVideoAndFeedback() async {
        do {
            
            if let gameStartTime = game.startTime {
                startDuration = specificKeyMoment.frameStart.timeIntervalSince(gameStartTime)
                totalDuration = specificKeyMoment.frameEnd.timeIntervalSince(gameStartTime)
            }
            
//            let feedback = specificKeyMoment.feedbackFor ?? []
//            
//            // Load feedback list
//            let fbFor: [String] = feedback.map { $0.playerId }
//            feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
            
            self.player = AVPlayer(url: videoUrl)
        } catch {
            print("❌ Error loading key moment: \(error)")
        }
    }
    
    
    /// **Creates a custom-styled text field for user comments.**
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text displayed when the field is empty.
    ///   - text: A binding to the text entered by the user.
    /// - Returns: A styled `TextField` wrapped in a rounded border.
    private func commentTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 30)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
    
    
    /// Returns the time difference between two dates in seconds.
    ///
    /// - Parameters:
    ///   - start: The starting timestamp.
    ///   - end: The ending timestamp.
    /// - Returns: The elapsed time in seconds as a `Double`.
    private func getKeyMomentTimeInSeconds(start: Date, end: Date) -> Double {
        let differenceInSeconds = end.timeIntervalSince(start)
        return Double(differenceInSeconds)
    }
    
    
    /// Moves the video playback position to the specified time (in seconds).
    private func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player!.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
        
    
    /// Restarts playback from the beginning of the key moment.
    private func restart() {
        player!.pause()
        seek(to: startDuration)
        isPlaying = false
    }
    
    
    /// Configures the player with a periodic observer to track playback progress.
    ///  - Updates the `progress` state every 0.1s.
    ///  - Restarts playback if the end of the key moment is reached.
    private func setupPlayer(to player: AVPlayer) {
        // Add observer to update current time every 0.5s
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { time in
            if !isSeeking {
                progress = time.seconds
                
                if progress >= totalDuration {
                    restart()
                }
            }
        }
    }
       
    
    /// Plays only the trimmed portion of the video defined by the key moment.
    /// - Seeks the player to the start time.
    /// - Pauses and resets playback when the end time is reached.
    private func playTrimmedSegment(player: AVPlayer) {
        guard let gameStart = game.startTime else { return }
        
        let startTime = getKeyMomentTimeInSeconds(start: gameStart, end: specificKeyMoment.frameStart)
        let endTime   = getKeyMomentTimeInSeconds(start: gameStart, end: specificKeyMoment.frameEnd)
        
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let end   = CMTime(seconds: endTime, preferredTimescale: 600)
        
        // Seek to start
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
        
        // Stop at end
        player.addBoundaryTimeObserver(forTimes: [NSValue(time: end)], queue: .main) {
            player.pause()
            progress = 0.0
            player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
            isPlaying.toggle()
        }
    }
    
    
    /// Goes to the start of the key moment.
    /// - Seeks the player to the start time.
    private func goToStartOfKeyMoment(player: AVPlayer) {
        guard let gameStart = game.startTime else { return }
        let startTime = getKeyMomentTimeInSeconds(start: gameStart, end: specificKeyMoment.frameStart)
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        
        // Seek to start
        player.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    
    /// **Formats a given time value (in seconds) into a `minutes:seconds` string.**
    ///
    /// - Parameter time: The total time in seconds.
    /// - Returns: A formatted string representing the time in `MM:SS` format.
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


struct AVPlayerWithoutControls: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
