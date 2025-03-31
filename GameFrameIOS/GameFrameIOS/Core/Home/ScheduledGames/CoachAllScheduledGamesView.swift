//
//  CoachAllScheduledGamesView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/** Shows all the schedule games previously added by the coach. User can search for specific scheduled games using the search bar */
struct CoachAllScheduledGamesView: View {
    @State private var searchText: String = ""
    
    @StateObject private var viewModel = ScheduledGamesViewModel()
    
    var body: some View {
        NavigationView {
            List  {
                Section {
                    // Scheduled Games Section
                    // Show all the scheduled Games 
                    ForEach(viewModel.scheduledGames, id: \.game.gameId) { scheduledGame in
                        NavigationLink(destination: SelectedScheduledGameView(gameId: scheduledGame.game.gameId, teamDocId: scheduledGame.team.id)) {
                            HStack {
                                VStack {
                                    Text(scheduledGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    Text(scheduledGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    Text(formatStartTime(scheduledGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    //Text("Scheduled for in 50 minutes").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
            }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
        }
        .searchable(text: $searchText)
        .task {
            do {
                try await viewModel.loadScheduledGames()
            } catch {
                print("Error needs to be handled. \(error)") // TO DO - Handle error
            }
        }
        
    }
}

#Preview {
    CoachAllScheduledGamesView()
}
