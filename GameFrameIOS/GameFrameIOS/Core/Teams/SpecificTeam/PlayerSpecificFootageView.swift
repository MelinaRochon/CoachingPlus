//
//  PlayerSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerSpecificFootageView: View {
    
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id

    @StateObject private var viewModel = SelectedGameModel()
    @StateObject private var transcriptModel = TranscriptViewModel()
    @State private var gameStartTime: Date?

    @State private var isGameDetailsEnabled: Bool = false

    // See if transcripts and key moments were found
    // TO DO - Make sure they are associated to the player!
    @State private var keyMomentsFound: Bool = false
    @State private var transcriptsFound: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                if let selectedGame = viewModel.selectedGame {
                    
                    VStack {
                        HStack(alignment: .top) {
                            VStack {
                                Text(selectedGame.game.title).font(.title2)
                                Text(selectedGame.team.teamNickname).font(.headline)

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
                            NavigationLink(destination: PlayerFullGameTranscriptView()) {
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
                            NavigationLink(destination: PlayerAllKeyMomentsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Key moments")
                                    .font(.headline)
                                    .foregroundStyle(keyMomentsFound ? .black : .secondary)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(keyMomentsFound ? .black : .secondary)
                                Spacer()
                                
                            }.padding(.bottom, 4).disabled(keyMomentsFound == false)
                            
                            HStack (alignment: .top) {
                                if !transcriptModel.keyMoments.isEmpty {
                                    ForEach(transcriptModel.keyMoments, id: \.id) { keyMoment in
                                        HStack(alignment: .top) {
                                            NavigationLink(destination: PlayerSpecificKeyMomentView()) {
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
                        
                        // Transcript
                        VStack(alignment: .leading, spacing: 10) {
                            
                            NavigationLink(destination: PlayerAllTranscriptsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Transcript")
                                    .font(.headline)
                                    .foregroundStyle(transcriptsFound ? .black : .secondary)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(transcriptsFound ? .black : .secondary)
                                Spacer()
                                
                            }.padding(.bottom, 4).disabled(transcriptsFound == false)
                            
                            if !transcriptModel.recordings.isEmpty {
                                ForEach(transcriptModel.recordings, id: \.id) { recording in
                                    HStack(alignment: .center) {
                                        NavigationLink(destination: PlayerSpecificTranscriptView(gameId: gameId, teamDocId: teamDocId, recording: recording)) {
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
                                        }.foregroundStyle(.black)
                                    }
                                }
                            } else {
                                // Transcripts empty
                                Text("No transcripts.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    try await viewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
                    if let selectedGame = viewModel.selectedGame {
                        if let startTime = selectedGame.game.startTime {
                            gameStartTime = startTime
                        }
                    }
                    try await transcriptModel.loadFirstThreeTranscripts(gameId: gameId, teamDocId: teamDocId)
                    
                    if !transcriptModel.recordings.isEmpty {
                        transcriptsFound = true
                    }
                    try await transcriptModel.loadFirstThreeKeyMoments(gameId: gameId, teamDocId: teamDocId)
                    if !transcriptModel.keyMoments.isEmpty {
                        keyMomentsFound = true
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(gameId: gameId, teamDocId: teamDocId)
            }
        }
    }
}

#Preview {
    PlayerSpecificFootageView(gameId: "", teamDocId: "")
}
