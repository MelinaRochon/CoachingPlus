//
//  PlayerSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerSpecificTranscriptView: View {
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id
    @State var recording: keyMomentTranscript?
    @State private var isEditing: Bool = false
    
    @StateObject private var viewModel = TranscriptViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let game = viewModel.game {
                    
                    VStack {
                        VStack (alignment: .leading) {
                            HStack(spacing: 0) {
                                Text(game.title).font(.title2)
                                Spacer()
                                
                            }
                            if let recording = recording {
                                HStack {
                                    Text("Transcript #\(recording.id+1)").font(.headline)
                                    Spacer()
                                }.padding(.bottom, -2)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    if let team = viewModel.team {
                                        Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                                    }
                                    if let recording = recording {
                                        Text(recording.frameStart.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }.padding(.leading).padding(.trailing).padding(.top, 3)
                        
                        Divider().padding(.vertical, 2)
                        
                        // Transcription section
                        if let recording = recording {
                            // Transcription section
                            VStack(alignment: .leading) {
                                if let gameStartTime = viewModel.gameStartTime {
                                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                                    Text(formatDuration(durationInSeconds)).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                                    
                                    Text("\(recording.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                                }
                            }.padding(.bottom, 10).padding(.top)
                            
                            if let feedbackFor = viewModel.feedbackFor {
                                // Feedback for section
                                VStack(alignment: .leading) {
                                    Text("Feedback For").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                                    ForEach(feedbackFor, id: \.playerId) { player in
                                        HStack {
                                            Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray).padding(.vertical, 5)
                                            Text(player.name)
                                        }.tag(player.playerId as String)
                                    }
                                }.padding(.horizontal)
                            }
                            VStack {
                                Divider()
                                
                                // TODO: Comment section
                                //CommentSectionView()
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
            }
            .task {
                do {
                    try await viewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
                    let feedbackFor = recording!.feedbackFor ?? []
                    
                    // Add a new key moment to the database
                    let fbFor: [String] = feedbackFor.map { $0.playerId }
                    try await viewModel.getFeebackFor(feedbackFor: fbFor)
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
        }
    }
}

#Preview {
    PlayerSpecificTranscriptView(gameId: "", teamDocId: "", recording: nil)
}
