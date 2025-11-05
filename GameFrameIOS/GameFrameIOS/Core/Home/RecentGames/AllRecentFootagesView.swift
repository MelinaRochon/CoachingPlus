//
//  AllRecentFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI
import GameFrameIOSShared

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
        
    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: UserType
    
    /// Holds the list of filtered scheduled games.
    @State private var filteredGames: [HomeGameDTO] = []
    
    // MARK: - View
    
    var body: some View {
        List  {
            Section {
                if !pastGames.isEmpty {
                    // Show all the Recent Games
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
        .overlay {
            if !pastGames.isEmpty && filteredGames.isEmpty && searchText != "" {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("Try to search for another recent game.")
                }
            }
        }
        .onChange(of: searchText) {
            if !pastGames.isEmpty && searchText != "" {
                self.filteredGames = filterGames(pastGames, with: searchText)
            }
            else {
                self.filteredGames = pastGames
            }
        }
        .onAppear {
            self.filteredGames = pastGames
        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
    }
}

#Preview {
    AllRecentFootageView(pastGames: [], userType: .player)
}
