//
//  CoachSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificTranscriptView: View {
    
    @State var gameId: String // Game ID
    @State var teamDocId: String // Team document ID
    @State var recording: keyMomentTranscript? // Optional key moment transcript
    @State private var isEditing: Bool = false
    
    @StateObject private var transcriptViewModel = TranscriptViewModel()
    @StateObject private var commentViewModel = CommentSectionViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                if let game = transcriptViewModel.game {
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(game.title).font(.title2)
                                Spacer()
                            }
                            
                            if let recording = recording {
                                HStack {
                                    Text("Transcript #\(recording.id + 1)")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.bottom, -2)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    if let team = transcriptViewModel.team {
                                        Text(team.name)
                                            .font(.subheadline)
                                            .foregroundStyle(.black.opacity(0.9))
                                    }
                                    if let recording = recording {
                                        Text(recording.frameStart.formatted(.dateTime.year().month().day().hour().minute()))
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
                        
                        if let recording = recording {
                            // Transcription section
                            VStack(alignment: .leading) {
                                if let gameStartTime = transcriptViewModel.gameStartTime {
                                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                                    Text(formatDuration(durationInSeconds))
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.bottom, 2)
                                    
                                    Text(recording.transcript)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 10)

                            // Feedback for Section
                            if let feedbackFor = transcriptViewModel.feedbackFor {
                                VStack(alignment: .leading) {
                                    Text("Feedback For")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 10)
                                    
                                    ForEach(feedbackFor, id: \.playerId) { player in
                                        HStack {
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .frame(width: 22, height: 22)
                                                .foregroundStyle(.gray)
                                                .padding(.vertical, 5)
                                            Text(player.name)
                                        }
                                    }
                                }.padding(.horizontal)
                            }
                            VStack {
                                Divider()
                                // Comment Section View
                                CommentSectionView(
                                    viewModel: commentViewModel,
                                    teamId: teamDocId,
                                    keyMomentId: "keyMomentId",
                                    gameId: gameId,
                                    transcriptId: "\(recording.id)"
                                )
                            }.frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
            }
            .task {
                do {
                    try await transcriptViewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
                    let feedbackFor = recording!.feedbackFor ?? []
                    
                    // Add a new key moment to the database
                    let fbFor: [String] = feedbackFor.map { $0.playerId }
                    try await transcriptViewModel.getFeebackFor(feedbackFor: fbFor)
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action for sharing
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if !isEditing {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Edit")
                    }
                    .foregroundColor(.red)
                } else {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Save")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    CoachSpecificTranscriptView(gameId: "", teamDocId: "", recording: nil)
}
