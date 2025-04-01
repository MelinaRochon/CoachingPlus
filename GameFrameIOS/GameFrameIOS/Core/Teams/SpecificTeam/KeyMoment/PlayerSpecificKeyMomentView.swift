//
//  PlayerSpecificKeyMomentView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

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
    
    /// View model for handling transcript-related data.
    @StateObject private var transcriptModel = TranscriptModel()

    /// List of players associated with feedback for this key moment.
    @State private var feedbackFor: [PlayerNameAndPhoto]? = []
    
    var body: some View {
        ScrollView {
            VStack {
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(game.title).font(.title2)
                        Text("Inside player specific key moments")
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
                        VStack {
                            HStack {
                                Text("Name").font(.subheadline).foregroundStyle(.secondary).padding(.top, 5)
                                Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray).padding(.top, 5)
                            }
                        }
                    }
                    Spacer()
                }.padding(.leading).padding(.trailing)
                Divider()
                
                // Key moment Video Frame
                VStack (alignment: .center){
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 340, height: 180)
                        .cornerRadius(10).padding(.bottom, 5)
                    
                    // Progress Slider
                    Slider(value: $progress, in: 0...totalDuration)
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
                }.padding()
                
                // Transcription section
                VStack(alignment: .leading) {
                    Text("Transcription").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                    Text(specificKeyMoment.transcript).font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                }.padding(.bottom, 5)
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
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            do {
                let feedback = specificKeyMoment.feedbackFor ?? []

                // Fetch feedback-related player details
                let fbFor: [String] = feedback.map { $0.playerId }
                feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                
                // Calculate key moment duration based on game start time
                if let gameStartTime = game.startTime {
                    totalDuration = specificKeyMoment.frameStart.timeIntervalSince(gameStartTime)
                }
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
        }
        
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

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    let specificKeyMoment = keyMomentTranscript(id: 1, keyMomentId: "keyMoment1", transcriptId: "1", transcript: "This is a test", frameStart: Date(), frameEnd: Date(), feedbackFor: [])
    
    PlayerSpecificKeyMomentView(game: game, team: team, specificKeyMoment: specificKeyMoment)
}
