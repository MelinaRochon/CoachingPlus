//
//  PlayerSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/// `PlayerSpecificTranscriptView` displays a detailed view of a single transcript for a player.
/// It includes transcript details, feedback information, and a comment section.
struct PlayerSpecificTranscriptView: View {
    
    /// Handles transcript-related data operations.
    @StateObject private var transcriptModel = TranscriptModel()
    
    /// Manages the comment section.
    @StateObject private var commentViewModel = CommentSectionViewModel()

    /// The game associated with the transcript.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// The specific transcript being displayed.
    @State var transcript: keyMomentTranscript?

    /// A list of players who received feedback in this transcript.
    @State private var feedbackFor: [PlayerNameAndPhoto]? = []
    
    /// Whether the associated audio file has been downloaded and is available for playback.
    @State private var audioFileRetrieved: Bool = false

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    // Header section displaying game and team details.
                    VStack (alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(game.title).font(.title2)
                            Spacer()
                            
                        }
                        
                        // Displays transcript ID if available.
                        if let transcript = transcript {
                            HStack {
                                Text("Transcript #\(transcript.id+1)").font(.headline)
                                Spacer()
                            }.padding(.bottom, -2)
                        }
                        
                        // Displays team name and transcript timestamp.
                        HStack {
                            VStack(alignment: .leading) {
                                Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                                if let transcript = transcript {
                                    Text(transcript.frameStart.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }.padding(.leading).padding(.trailing).padding(.top, 3)
                    
                    Divider().padding(.vertical, 2)
                    
                    // Displays transcript content if available.
                    if let transcript = transcript {
                        
                        // Transcript details section.
                        VStack(alignment: .leading) {
                            
                            // Show audio file
                            if audioFileRetrieved {
                                let localAudioURL = FileManager.default
                                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    .appendingPathComponent("downloaded_audio.m4a")
                                
                                AudioPlayerView(audioURL: localAudioURL)
                            }
                            
                            if let gameStartTime = game.startTime {
                                let durationInSeconds = transcript.frameStart.timeIntervalSince(gameStartTime)
                                Text(formatDuration(durationInSeconds)).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                                
                                Text("\(transcript.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                            }
                        }.padding(.bottom, 10).padding(.top)
                        
                        // Displays feedback recipients if available.
                        if let feedbackFor = feedbackFor {
                            VStack(alignment: .leading) {
                                Text("Feedback For").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                                ForEach(feedbackFor, id: \.playerId) { player in
                                    HStack {
                                        Text(player.name).font(.caption).padding(.top, 2)
                                    }.tag(player.playerId as String)
                                }
                            }.padding(.horizontal)
                        }
                        VStack {
                            Divider()
                            
                            /// Comment Section View
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
                    // Loads feedback recipient data for the transcript.
                    if let transcript = transcript {
                        let feedback = transcript.feedbackFor ?? []
                        
                        // Add a new key moment to the database
                        let fbFor: [String] = feedback.map { $0.playerId }
                        feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                        
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
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    PlayerSpecificTranscriptView(game: game, team: team, transcript: nil)
}
