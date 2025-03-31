//
//  CoachAllScheduledGamesView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/**
 `CoachAllScheduledGamesView` displays all scheduled games added by the coach.

 ## Features:
 - Lists all upcoming scheduled games.
 - Allows searching for specific games using a search bar.
 - Each game is displayed with its title, team name, and scheduled start time.
 - Tapping on a game navigates to `SelectedScheduledGameView` for detailed information.
 - If there are no scheduled games, it displays a placeholder message.

 ## User Interaction:
 - Coaches can scroll through their scheduled games.
 - Typing in the search bar filters the list of games.
 - Clicking on a game navigates to a detailed game view.
 */
struct CoachAllScheduledGamesView: View {
    
    // MARK: - State Properties

    /// Stores the text entered in the search bar to filter scheduled games.
    @State private var searchText: String = ""
    
    /// Holds the list of future scheduled games retrieved from the database.
    @State var futureGames: [HomeGameDTO] = []
    
    // MARK: - View

    var body: some View {
        NavigationView {
            List  {
                Section {
                    // Scheduled Games Section
                    
                    if !futureGames.isEmpty {
                        // Show all the scheduled Games
                        ForEach(futureGames, id: \.game.gameId) { futureGame in
                            NavigationLink(destination: SelectedScheduledGameView(selectedGame: futureGame)) {
                                HStack {
                                    VStack {
                                        Text(futureGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        Text(futureGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        Text(formatStartTime(futureGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No scheduled games found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            .background(Color.white) // Set background color to white for the List
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    CoachAllScheduledGamesView(futureGames: [])
}
