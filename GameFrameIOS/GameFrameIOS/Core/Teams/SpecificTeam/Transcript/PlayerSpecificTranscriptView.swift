//
//  PlayerSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerSpecificTranscriptView: View {
//    @State var gameId: String // game Id
//    @State var teamDocId: String // team document id
//    @State var recording: keyMomentTranscript?
    @State private var isEditing: Bool = false
    
//    @StateObject private var viewModel = TranscriptViewModel()
    @StateObject private var transcriptModel = TranscriptModel()
    @StateObject private var commentViewModel = CommentSectionViewModel()

    @State var game: DBGame
    @State var team: DBTeam
    @State var transcript: keyMomentTranscript?

    @State private var feedbackFor: [PlayerNameAndPhoto]? = []

    
    var body: some View {
        NavigationView {
            ScrollView {
//                if let game = viewModel.game {
                    
                    VStack {
                        VStack (alignment: .leading) {
                            HStack(spacing: 0) {
                                Text(game.title).font(.title2)
                                Spacer()
                                
                            }
                            if let transcript = transcript {
                                HStack {
                                    Text("Transcript #\(transcript.id+1)").font(.headline)
                                    Spacer()
                                }.padding(.bottom, -2)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
//                                    if let team = viewModel.team {
                                        Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
//                                    }
                                    if let transcript = transcript {
                                        Text(transcript.frameStart.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }.padding(.leading).padding(.trailing).padding(.top, 3)
                        
                        Divider().padding(.vertical, 2)
                        
                        // Transcription section
                        if let transcript = transcript {
                            // Transcription section
                            VStack(alignment: .leading) {
                                if let gameStartTime = game.startTime {
                                    let durationInSeconds = transcript.frameStart.timeIntervalSince(gameStartTime)
                                    Text(formatDuration(durationInSeconds)).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                                    
                                    Text("\(transcript.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                                }
                            }.padding(.bottom, 10).padding(.top)
                            
                            if let feedbackFor = feedbackFor {
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
                                // Comment Section View
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
//                }
            }
            .task {
                do {
//                    try await viewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
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
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    PlayerSpecificTranscriptView(game: game, team: team, transcript: nil)
}
