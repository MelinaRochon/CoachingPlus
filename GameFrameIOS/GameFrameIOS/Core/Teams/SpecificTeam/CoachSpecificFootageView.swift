//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/**
 `CoachSpecificFootageView` is a SwiftUI view designed for soccer coaches to review game footage,
 transcripts, and key moments after a match.

 ## Overview:
 This view provides a structured interface for coaches to:
 - View basic game details such as title, team name, and start time.
 - Access the full game transcript.
 - Browse and review key moments recorded during the match.
 - See individual transcripts of specific game segments.
 - Open a detailed game information view.
  
 The view dynamically loads game-related data, including transcripts and key moments, when it appears.

 ## Main Components:
 1. **Game Details Section**
    - Displays the game title, team nickname, and start time.
    - Includes a button to view additional game details in a modal.

 2. **Full Game Transcript Section**
    - Provides access to a complete game transcript via `CoachFullGameTranscriptView`.

 3. **Key Moments Section**
    - Shows a list of recorded key moments, each linked to `CoachSpecificKeyMomentView`.
    - If no key moments are found, a placeholder message is displayed.

 4. **Transcripts Section**
    - Lists individual transcripts of specific moments, with navigation to `CoachSpecificTranscriptView`.
    - Displays a message if no transcripts are available.

 5. **Data Fetching & State Management**
    - Uses `TranscriptModel` to asynchronously fetch transcripts and key moments.
    - Tracks whether key moments and transcripts exist using state variables (`keyMomentsFound`, `transcriptsFound`).
 
 This view is designed to be navigable and user-friendly, allowing coaches to quickly access and analyze game footage and feedback.
 */
struct CoachSpecificFootageView: View {
    
    /// ViewModel for handling transcript-related data operations.
    @StateObject private var transcriptModel = TranscriptModel()
    
    /// The start time of the game, used for timestamp calculations.
    @State private var gameStartTime: Date?
    
    /// Controls whether the game details view is presented.
    @State private var isGameDetailsEnabled: Bool = false
    
    /// Flags indicating whether key moments and transcripts were found.
    @State private var keyMomentsFound: Bool = false
    @State private var transcriptsFound: Bool = false
    
    /// The game and team associated with this footage.
    @State var game: DBGame
    @State var team: DBTeam
    
    /// Stores retrieved transcripts and key moments.
    @State private var transcripts: [keyMomentTranscript]?
    @State private var keyMoments: [keyMomentTranscript]?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Game details section
                    HStack(alignment: .top) {
                        VStack {
                            Text(game.title).font(.title2).multilineTextAlignment(.center)
                            Text(team.teamNickname).font(.headline)
                            if let gameStartTime = gameStartTime {
                                Text(gameStartTime, style: .date).font(.subheadline).foregroundStyle(.secondary)
                            }
                            
                            Button {
                                isGameDetailsEnabled.toggle()
                            } label: {
                                Text("View Game Details").foregroundColor(Color.red).underline()
                            }
                            Divider()
                        }
                    }
                    
                    // Full game transcript section
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink(destination: CoachFullGameTranscriptView()) {
                            Text("Full Game Transcript")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("Watch").foregroundColor(.gray)
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Key moments section
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: CoachAllKeyMomentsView(game: game, team: team, keyMoments: keyMoments)) {
                            Text("Key moments")
                                .font(.headline)
                                .foregroundStyle(keyMomentsFound ? .black : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(keyMomentsFound ? .black : .secondary)
                            Spacer()
                            
                        }.padding(.bottom, 4).disabled(!keyMomentsFound)
                        
                        // Display key moments if available
                        if let keyMoments = keyMoments {
                            if !keyMoments.isEmpty {
                                ForEach(keyMoments, id: \.id) { keyMoment in
                                    HStack(alignment: .top) {
                                        NavigationLink(destination: CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: keyMoment)) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 110, height: 60)
                                                .cornerRadius(10)
                                            
                                            VStack {
                                                HStack {
                                                    if let gameStartTime = gameStartTime {
                                                        let durationInSeconds = keyMoment.frameStart.timeIntervalSince(gameStartTime)
                                                        Text(formatDuration(durationInSeconds)).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2).foregroundStyle(.black)
                                                        Spacer()
                                                        Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                                    }
                                                }
                                                Text(keyMoment.transcript).font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black).lineLimit(3)
                                            }
                                        }
                                    }
                                }
                            } else {
                                // key moments empty
                                Text("No key moments.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Transcript section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        NavigationLink(destination: CoachAllTranscriptsView(game: game, team: team, transcripts: transcripts)) {
                            Text("Transcript")
                                .font(.headline)
                                .foregroundStyle(transcriptsFound ? .black : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(transcriptsFound ? .black : .secondary)
                            Spacer()
                            
                        }
                        .padding(.bottom, 4)
                        .disabled(!transcriptsFound)
                        
                        // Display available transcripts
                        if let transcripts = transcripts {
                            if !transcripts.isEmpty {
                                ForEach(transcripts, id: \.id) { recording in
                                    HStack(alignment: .center) {
                                        NavigationLink(destination: CoachSpecificTranscriptView(game: game, team: team, transcript: recording)) {
                                            HStack(alignment: .center) {
                                                if let gameStartTime = gameStartTime {
                                                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                                                    Text(formatDuration(durationInSeconds)).bold().font(.headline).foregroundColor(Color.black)
                                                    Spacer()
                                                    Text("Transcript: \(recording.transcript)")
                                                        .font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3).padding(.top, 4).foregroundColor(Color.black)
                                                    
                                                    Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                                                }
                                            }.tag(recording.id as Int)
                                        }
                                    }
                                }
                            } else {
                                // Transcripts empty
                                Text("No transcripts.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    if let startTime = game.startTime {
                        gameStartTime = startTime
                    }
                    
                    let (tmpTranscripts, tmpKeyMom) = try await transcriptModel.getAllTranscriptsAndKeyMoments(gameId: game.gameId, teamDocId: team.id)
                    
                    self.transcripts = tmpTranscripts
                    self.keyMoments = tmpKeyMom
                    
                    if let allTranscripts = transcripts {
                        if !allTranscripts.isEmpty {
                            transcriptsFound = true
                        }
                    }
                    
                    if let allKeyMoments = keyMoments {
                        if !allKeyMoments.isEmpty {
                            keyMomentsFound = true
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(selectedGame: game, team: team, userType: "Coach")
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    CoachSpecificFootageView(game: game, team: team)
}
