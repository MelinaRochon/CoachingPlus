//
//  SelectedRecentGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import SwiftUI

struct SelectedRecentGameView: View {
    @StateObject private var viewModel = SelectedGameModel()
    @State var gameId: String // scheduled game id is passed when this view is called
    @State var teamDocId: String // scheduled game id is passed when this view is called

    var body: some View {
        NavigationView {
            VStack {
                if let selectedGame = viewModel.selectedGame {
                    Divider() // for the title
                    VStack {
                        Text(selectedGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text(selectedGame.team.name).font(.title3).foregroundStyle(.secondary)
                            
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text(selectedGame.game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)

                        }
                    }
                    .navigationTitle(Text(selectedGame.game.title))
                    
                }
                Spacer()
            }
        }
        .task {
            do {
                try await viewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
            } catch {
                print("ERROR. \(error)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Start the recording
                Button
                {
                    
                } label: {
                    HStack {
                        Text("Record").font(.subheadline)
                        Image(systemName: "record.circle").resizable().frame(width: 15, height: 15)
                        
                    }.foregroundColor(.white)
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(Color.red)
                        .cornerRadius(25)
                }
            }
        }
        
    }
}

#Preview {
    SelectedRecentGameView(gameId: "", teamDocId: "")
}
