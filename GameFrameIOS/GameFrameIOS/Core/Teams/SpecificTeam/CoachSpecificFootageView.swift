//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificFootageView: View {
    
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id
    
    @StateObject private var viewModel = SelectedGameModel()
    @StateObject private var transcriptModel = TranscriptViewModel()

    @State private var isGameDetailsEnabled: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let selectedGame = viewModel.selectedGame {
                    VStack {
                        HStack(alignment: .top) {
                            VStack {
                                Text(selectedGame.game.title).font(.title2).multilineTextAlignment(.center)
                                Text(selectedGame.team.teamNickname).font(.headline) //.foregroundStyle(.black.opacity(0.9))
                                if let startTime = selectedGame.game.startTime {
                                    Text(startTime, style: .date).font(.subheadline).foregroundStyle(.secondary)
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
                            NavigationLink(destination: CoachAllKeyMomentsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Key moments")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                                Spacer()
                                
                            }.padding(.bottom, 4)
                            
                            HStack (alignment: .top) {
                                NavigationLink(destination: CoachSpecificKeyMomentView(gameId: gameId, teamDocId: teamDocId)) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 110, height: 60)
                                        .cornerRadius(10)
                                    
                                    VStack {
                                        HStack {
                                            Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2).foregroundStyle(.black)
                                            Spacer()
                                            Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                        }
                                        
                                        Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                    }
                                }
                            }
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                            .padding(.horizontal).padding(.top)
                        
                        // Transcript
                        VStack(alignment: .leading, spacing: 10) {
                            
                            NavigationLink(destination: CoachAllTranscriptsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Transcript")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                                Spacer()
                                
                            }.padding(.bottom, 4)
                            if !transcriptModel.recordings.isEmpty {
                                ForEach(transcriptModel.recordings, id: \.id) { recording in
                                    HStack(alignment: .top) {
                                        NavigationLink(destination: CoachSpecificTranscriptView(gameId: gameId, teamDocId: teamDocId, recording: recording)) {
                                            HStack(alignment: .top) {
                                                let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                                                Text(formatDuration(durationInSeconds)).bold().font(.headline).foregroundColor(Color.black)
                                                Spacer()
                                                Text("Transcript: \(recording.transcript)")
                                                    .font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3).padding(.top, 4).foregroundColor(Color.black)
                                                
                                                Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                                            }.tag(recording.id as Int)
                                        }
                                    }
                                }
                            }
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                            .padding(.horizontal).padding(.top)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    try await viewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
                    try await transcriptModel.loadFirstThreeTranscripts(gameId: gameId, teamDocId: teamDocId)

                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(gameId: gameId, teamDocId: teamDocId)
            }
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}

#Preview {
    CoachSpecificFootageView(gameId: "", teamDocId: "")
}
