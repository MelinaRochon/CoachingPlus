//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificFootageView: View {
    
//    @State var gameId: String // game Id
//    @State var teamDocId: String // team document id
    
    @StateObject private var viewModel = SelectedGameModel()
    @StateObject private var transcriptModel = TranscriptViewModel()
    
    
    @StateObject private var tModel = TranscriptModel()
    
    @State private var gameStartTime: Date?

    @State private var isGameDetailsEnabled: Bool = false
    
    // See if transcripts and key moments were found
    @State private var keyMomentsFound: Bool = false
    @State private var transcriptsFound: Bool = false
    
    @State var game: DBGame
    @State var team: DBTeam
    
    @State private var keyMoments: [keyMomentTranscript]?;
    @State private var transcripts: [keyMomentTranscript]?;

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
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
                    
                    // Watch Full Game
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
                    
                    // Key moments
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: CoachAllKeyMomentsView(gameId: game.gameId, teamDocId: team.id)) {
                            Text("Key moments")
                                .font(.headline)
                                .foregroundStyle(keyMomentsFound ? .black : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(keyMomentsFound ? .black : .secondary)
                            Spacer()
                            
                        }.padding(.bottom, 4).disabled(keyMomentsFound == false)
                        
                        HStack (alignment: .top) {
                            if let keyMoments = keyMoments {
                                if !keyMoments.isEmpty {
                                    ForEach(keyMoments, id: \.id) { keyMoment in
                                        HStack(alignment: .top) {
                                            NavigationLink(destination: CoachSpecificKeyMomentView(gameId: game.gameId, teamDocId: team.id, recording: keyMoment)) {
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
                                }
                                else {
                                    // key moments empty
                                    Text("No key moments.").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Transcript
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
                        
                        if let transcripts = transcripts {
                            ForEach(transcripts, id: \.id) { recording in
                                HStack(alignment: .center) {
                                    NavigationLink(destination: CoachSpecificTranscriptView(gameId: game.gameId, teamDocId: team.id, recording: recording)) {
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
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    let (recordings, keyMom) = try await tModel.loadAllTranscripts(gameId: game.gameId, teamDocId: team.id)
                    
                    self.keyMoments = keyMom
                    self.transcripts = recordings
                    
                    if let startTime = game.startTime {
                        gameStartTime = startTime
                    }
                    
                    if let transcripts = transcripts {
                        if !transcripts.isEmpty {
                            transcriptsFound = true
                        }
                    }

                    if let keyMoments = keyMoments {
                        if !keyMoments.isEmpty {
                            keyMomentsFound = true
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(gameId: game.gameId, teamDocId: team.id)
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: false, teamId: "123")
    CoachSpecificFootageView(game: game, team: team)
}
