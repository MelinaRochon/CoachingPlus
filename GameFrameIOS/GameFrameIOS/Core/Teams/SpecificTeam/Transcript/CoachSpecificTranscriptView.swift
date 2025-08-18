//
//  CoachSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/// `CoachSpecificTranscriptView` displays details for a specific transcript from a game.
/// It shows game information, transcript text, associated players, and comments.
struct CoachSpecificTranscriptView: View {
    
    /// State variable to track whether the edit mode is active.
    @State private var isEditing: Bool = false
    
    /// View model responsible for handling comments.
    @StateObject private var commentViewModel = CommentSectionViewModel()
    
    /// View model responsible for handling transcript-related operations.
    @StateObject private var transcriptModel = TranscriptModel()
    
    /// The game associated with the transcript.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// The specific transcript being displayed.
    @State var transcript: keyMomentTranscript?

    /// Stores player details for whom feedback is provided in this transcript.
    @State private var feedbackFor: [PlayerNameAndPhoto]? = []
    
    @State private var audioFileRetrieved: Bool = false;
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    // Game title and transcript information section.
                    VStack(alignment: .leading) {
                        HStack {
                            Text(game.title).font(.title2)
                            Spacer()
                        }
                        
                        // Displays the transcript ID if available.
                        if let transcript = transcript {
                            HStack {
                                Text("Transcript #\(transcript.id + 1)")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.bottom, -2)
                        }
                        
                        // Displays team name and transcript creation time.
                        HStack {
                            VStack(alignment: .leading) {
                                Text(team.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.black.opacity(0.9))
                                if let transcript = transcript {
                                    Text(transcript.frameStart.formatted(.dateTime.year().month().day().hour().minute()))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 3)
                    
                    Divider().padding(.vertical, 2)
                    
                    if let transcript = transcript {
                        // Displays the transcript text along with its timestamp relative to game start.
                        VStack(alignment: .leading) {
                            
                            if audioFileRetrieved {
                                let localAudioURL = FileManager.default
                                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    .appendingPathComponent("downloaded_audio.m4a")
                                
                                AudioPlayerView(audioURL: localAudioURL)
                            }
                            
                            if let gameStartTime = game.startTime {
                                let durationInSeconds = transcript.frameStart.timeIntervalSince(gameStartTime)
                                Text(formatDuration(durationInSeconds))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.bottom, 2)
                                
                                Text(transcript.transcript)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Feedback for Section
                        if let feedbackFor = feedbackFor {
                            // Displays a list of players for whom the feedback applies.
                            VStack(alignment: .leading) {
                                Text("Feedback For")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text(feedbackFor.map { $0.name}.joined(separator: ", ")).font(.caption).padding(.top, 2)
                                }.multilineTextAlignment(.leading)
                            }.padding(.horizontal).padding(.vertical, 10)
                        }
                        VStack {
                            Divider()
                            // Comment section allowing users to view and add comments for the transcript.
                            CommentSectionView(
                                viewModel: commentViewModel,
                                teamDocId: team.id,
                                keyMomentId: "\(transcript.keyMomentId)",
                                gameId: game.gameId,
                                transcriptId: "\(transcript.transcriptId)"
                            )
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
            .task {
                do {
                    print("CoachSpecificTranscript, teamDocId: \(team.id)")
                    if let transcript = transcript {
                        let feedback = transcript.feedbackFor ?? []
                        
                        // Add a new key moment to the database
                        let fbFor: [String] = feedback.map { $0.playerId }
                        feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
        }
        .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        // Action for sharing
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .padding(.bottom, 6)
                    }
                    .foregroundColor(.red)
                
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
                    } else {
                        Button {
                            withAnimation {
                                isEditing.toggle()
                            }
                        } label: {
                            Text("Save")
                        }
                        .frame(width: 40)
                        .foregroundColor(.red)
                    }
                }
        }
        .task {
            // Fetch the audio url
            print("TRANSCRIPT INFO: \(transcript)")
            if let transcript = transcript {
                do {
                    let audioURL = try await transcriptModel.getAudioFileUrl(keyMomentId: transcript.keyMomentId, gameId: game.gameId, teamId: team.teamId)
                    
                    if let url = audioURL {
                        // Fetch audio file from db
                        let storageRef = StorageManager.shared.getAudioURL(path: url)
                        
                        let localURL = FileManager.default
                            .urls(for: .documentDirectory, in: .userDomainMask)[0]
                            .appendingPathComponent("downloaded_audio.m4a")
                        
                        
                        
                        storageRef.write(toFile: localURL) { url, error in
                            if let error = error {
                                print("❌ Failed to download audio: \(error.localizedDescription)")
                            } else {
                                print("✅ Audio downloaded to: \(url?.path ?? "")")
                                // You can now use this local file (e.g., to play it)
                                audioFileRetrieved = true
                            }
                        }
                    }

                } catch {
                    print("ERROR WHEN fetching AUDIO url: \(error)")
                }
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    NavigationStack {
        CoachSpecificTranscriptView(game: game, team: team, transcript: nil)
    }
}
