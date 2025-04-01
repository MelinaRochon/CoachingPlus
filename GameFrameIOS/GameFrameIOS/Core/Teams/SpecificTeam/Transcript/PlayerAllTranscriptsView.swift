//
//  PlayerAllTranscriptsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerAllTranscriptsView: View {
    @State private var searchText: String = ""
    @State private var showFilterSelector = false
    
//    @State var gameId: String // scheduled game id is passed when this view is called
//    @State var teamDocId: String // scheduled game id is passed when this view is called
//    @StateObject private var viewModel = TranscriptViewModel()

    @State var game: DBGame
    @State var team: DBTeam
    @State var transcripts: [keyMomentTranscript]?

    var body: some View {
        NavigationView {
//            if let game = viewModel.game {
                
                VStack (alignment: .leading) {
                    VStack (alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(game.title).font(.title2)
                            Spacer()
                            Button (action: {
                                showFilterSelector.toggle()
                            }) {
                                Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 20, height: 20)
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
//                                if let team = viewModel.team {
                                    Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
//                                }
                                if let startTime = game.startTime {
                                    Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            // Edit Icon
                            Button(action: {}) {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.blue) // Adjust color
                            }
                            // Share Icon
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue) // Adjust color
                            }
                        }
                    }.padding(.leading).padding(.trailing).padding(.top, 3)
                    
                    Divider().padding(.vertical, 2)
                    
                    SearchTranscriptView(game: game, team: team, transcripts: transcripts)
                }// Show filters
                .sheet(isPresented: $showFilterSelector, content: {
                    FilterTranscriptsListView().presentationDetents([.medium])
                })
                
//            }
        }
//        .task {
//            do {
//                try await viewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
//            } catch {
//                print("Error when loading all key moments. \(error)")
//            }
//        }
        
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    PlayerAllTranscriptsView(game: game, team: team, transcripts: [])
}
