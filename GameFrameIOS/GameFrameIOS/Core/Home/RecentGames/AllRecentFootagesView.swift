//
//  AllRecentFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/**
 `AllRecentFootageView` displays all previously recorded game footage for coaches.

 ## Features:
 - Lists past games that have recorded footage.
 - Allows users to search for specific footage using a search bar.
 - Clicking on a game navigates to `SelectedRecentGameView` for detailed viewing.
 - If no past games are found, a placeholder message is displayed.

 ## User Interaction:
 - Coaches can scroll through the recorded games.
 - Typing in the search bar filters the list of past games.
 - Selecting a game opens its details, including recorded video previews.
 */
struct AllRecentFootageView: View {
    
    // MARK: - State Properties

    /// Stores the text entered in the search bar to filter recorded footage.
    @State private var searchText: String = ""
    
    /// Holds the list of past games with recorded footage.
    @State var pastGames: [HomeGameDTO] = []
    
    /// Determines whether to show an error message when no recorded games are available.
    @State private var showNoGamesError: Bool = false

    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: String
        
    // MARK: - View

    var body: some View {
        NavigationStack {
            List  {
                Section {
                    if !pastGames.isEmpty {
                        let filteredGames = filterGames(pastGames, with: searchText)
                        GameList(
                            games: filteredGames,
                            prefix: nil,
                            gameType: .recent,
                            destinationBuilder: { game in
                                AnyView(SelectedRecentGameView(selectedGame: game, userType: userType))
                            }
                        )
                    } else {
                        Text("No games found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            .background(Color.white) // Set background color to white for the List
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Recent Games"))
            .navigationTitle(Text("All Recent Games"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AllRecentFootageView(pastGames: [], userType: "Player")
}
