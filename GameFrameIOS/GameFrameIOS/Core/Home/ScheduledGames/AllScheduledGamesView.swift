//
//  AllScheduledGamesView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/**
 `AllScheduledGamesView` displays all scheduled games added by the coach.

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
struct AllScheduledGamesView: View {
    
    // MARK: - State Properties

    /// Stores the text entered in the search bar to filter scheduled games.
    @State private var searchText: String = ""
    
    /// Holds the list of future scheduled games retrieved from the database.
    @State var futureGames: [HomeGameDTO] = []
    
    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: String
    
    /// Holds the list of filtered scheduled games.
    @State private var filteredGames: [HomeGameDTO] = []

    // MARK: - View

    var body: some View {
        NavigationStack {
            List  {
                Section {
                    // Scheduled Games Section
                    if !futureGames.isEmpty {
                        // Show all the scheduled Games
                        GameList(
                            games: filteredGames,
                            prefix: 5,
                            gameType: .scheduled,
                            destinationBuilder: { game in
                                AnyView(SelectedScheduledGameView(selectedGame: game, userType: userType))
                            }
                        )
                    } else {
                        Text("No scheduled games found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            .background(Color.white) // Set background color to white for the List
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Scheduled Games"))
            .navigationTitle(Text("All Scheduled Games"))
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if !futureGames.isEmpty && filteredGames.isEmpty && searchText != "" {
                    ContentUnavailableView {
                        Label("No Results", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try to search for another scheduled game.")
                    }
                }
            }
            .onChange(of: searchText) {
                if !futureGames.isEmpty && searchText != "" {
                    self.filteredGames = filterGames(futureGames, with: searchText)
                }
                else {
                    self.filteredGames = futureGames
                }
            }
            .onAppear {
                self.filteredGames = futureGames
            }
        }
    }
}

#Preview {
    AllScheduledGamesView(futureGames: [], userType: "Coach")
}
