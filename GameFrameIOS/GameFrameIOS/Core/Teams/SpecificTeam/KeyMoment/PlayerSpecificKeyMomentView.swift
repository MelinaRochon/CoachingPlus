//
//  PlayerSpecificKeyMomentView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI
import AVFoundation
import GameFrameIOSShared

/// A view that displays a specific key moment for a player, including video playback, transcript, and feedback.
///
/// ### Features:
/// - Displays key moment details such as game title, timestamp, and team name.
/// - Provides a video preview placeholder and playback progress slider.
/// - Shows the transcript of the key moment.
/// - Integrates a comment section for feedback and discussions.
struct PlayerSpecificKeyMomentView: View {
    
    /// Tracks the progress of video playback (simulated with a slider).
    @State private var progress: Double = 0.0
    
    /// Stores user comments input.
    @State private var comment: String = ""
    
    /// Represents the total duration of the key moment in seconds.
    @State private var totalDuration: Double = 180 // Default: 3 minutes (180 seconds)
    
    /// View model for handling comments related to this key moment.
    @StateObject private var commentViewModel = CommentSectionViewModel()
    
    /// The game associated with this key moment.
    @State var game: DBGame
    
    /// The team associated with this key moment.
    @State var team: DBTeam
    
    /// The specific key moment transcript to be displayed.
    @State var specificKeyMoment: keyMomentTranscript
    
    /// ViewModels for handling transcript-related logic.
    @StateObject private var transcriptModel = TranscriptModel()
    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// List of players associated with feedback for this key moment.
    @State private var feedbackFor: [PlayerNameAndPhoto] = []
    
    /// The start duration  of the video clip (default: 0s).
    @State private var startDuration: Double = 0.0
    
    /// Video player instance for handling playback in the view
    @State private var player: AVPlayer?

    /// Tracks whether the video is currently playing.
    @State private var isPlaying: Bool = false

    /// Indicates when the user is actively moving the seek slider.
    @State private var isSeeking: Bool = false

    @State var videoUrl: URL

    var body: some View {
        ScrollView {
            VStack {
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(game.title).font(.title2)
                        Spacer()
                    }
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
                VStack (alignment: .center){
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
                    Text("Transcription").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                    Text(specificKeyMoment.transcript).font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
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
                    transcriptId: String(specificKeyMoment.transcriptId)
                )
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await loadVideoAndFeedback()
        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
        .onAppear {
            transcriptModel.setDependencies(dependencies)
            fgVideoRecordingModel.setDependencies(dependencies)
            audioRecordingModel.setDependencies(dependencies)
            commentViewModel.setDependencies(dependencies)
        }
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
            
            let feedback = specificKeyMoment.feedbackFor ?? []
            
            // Load feedback list
            let fbFor: [String] = feedback.map { $0.playerId }
            feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
            
            self.player = AVPlayer(url: videoUrl)
        } catch {
            print("❌ Error loading key moment: \(error)")
        }
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
    
    
    /// Creates a custom text field for user comments.
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder text displayed in the text field.
    ///   - text: A binding to the comment text input.
    /// - Returns: A styled `TextField` view.
    private func commentTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 30)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
    
    
    /// Formats time in minutes and seconds (e.g., `1:30`).
    ///
    /// - Parameter time: The time in seconds.
    /// - Returns: A formatted string representing minutes and seconds.
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

//#Preview {
//    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
//    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
//    let specificKeyMoment = keyMomentTranscript(id: 1, keyMomentId: "keyMoment1", transcriptId: "1", transcript: "This is a test", frameStart: Date(), frameEnd: Date(), feedbackFor: [])
//    
//    PlayerSpecificKeyMomentView(game: game, team: team, specificKeyMoment: specificKeyMoment)
//}
