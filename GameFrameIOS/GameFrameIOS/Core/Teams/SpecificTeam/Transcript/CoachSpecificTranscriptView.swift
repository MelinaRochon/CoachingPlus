//
//  CoachSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificTranscriptView: View {
    
//    @State var gameId: String // Game ID
//    @State var teamDocId: String // Team document ID
//    @State var recording: keyMomentTranscript? // Optional key moment transcript
    @State private var isEditing: Bool = false
    
//    @StateObject private var transcriptViewModel = TranscriptViewModel()
    @StateObject private var commentViewModel = CommentSectionViewModel()
    @StateObject private var transcriptModel = TranscriptModel()
    
    @State var game: DBGame
    @State var team: DBTeam
    @State var transcript: keyMomentTranscript?

    @State private var feedbackFor: [PlayerNameAndPhoto]? = []

    var body: some View {
        NavigationView {
            ScrollView {
//                if let game = transcriptViewModel.game {
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(game.title).font(.title2)
                                Spacer()
                            }
                            
                            if let transcript = transcript {
                                HStack {
                                    Text("Transcript #\(transcript.id + 1)")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.bottom, -2)
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
//                                    if let team = transcriptViewModel.team {
                                        Text(team.name)
                                            .font(.subheadline)
                                            .foregroundStyle(.black.opacity(0.9))
//                                    }
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
                            // Transcription section
                            VStack(alignment: .leading) {
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
                                VStack(alignment: .leading) {
                                    Text("Feedback For")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 10)
                                    
//                                    ForEach(feedbackFor, id: \.playerId) { player in
                                        HStack {
//                                            Image(systemName: "person.circle")
//                                                .resizable()
//                                                .frame(width: 22, height: 22)
//                                                .foregroundStyle(.gray)
//                                                .padding(.vertical, 5)
                                            Text(feedbackFor.map { $0.name}.joined(separator: ", ")).font(.caption).padding(.top, 5)
                                        }.multilineTextAlignment(.leading)
//                                    }
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
                    print("CoachSpecificTranscript, teamDocId: \(team.id)")
                    if let transcript = transcript {
                        let feedback = transcript.feedbackFor ?? []
                        
                        // Add a new key moment to the database
                        let fbFor: [String] = feedback.map { $0.playerId }
                        feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                    }
//                    try await transcriptViewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
//                    let feedbackFor = transcript!.feedbackFor ?? []
                    
                    // Add a new key moment to the database
//                    let fbFor: [String] = feedbackFor.map { $0.playerId }
//                    try await transcriptViewModel.getFeebackFor(feedbackFor: fbFor)
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
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    CoachSpecificTranscriptView(game: game, team: team, transcript: nil)
}
