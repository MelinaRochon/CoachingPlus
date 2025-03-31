//
//  CoachAllRecentFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/**
 `CoachAllRecentFootageView` displays all previously recorded game footage.

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
struct CoachAllRecentFootageView: View {
    
    // MARK: - State Properties

    /// Stores the text entered in the search bar to filter recorded footage.
    @State private var searchText: String = ""
    
    /// Holds the list of past games with recorded footage.
    @State var pastGames: [HomeGameDTO] = []
    
    /// Determines whether to show an error message when no recorded games are available.
    @State private var showNoGamesError: Bool = false

    // MARK: - View

    var body: some View {
        NavigationView {
            List  {
                Section {
                    if !pastGames.isEmpty {
                        ForEach(pastGames, id: \.game.gameId) { pastGame in
                            NavigationLink(destination: SelectedRecentGameView(selectedGame: pastGame)) {
                                HStack {
                                    CustomUIFields.gameVideoPreviewStyle()
                                    
                                    VStack {
                                        Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        Text( formatStartTime(pastGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No games found.").font(.caption).foregroundStyle(.secondary)
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
    CoachAllRecentFootageView(pastGames: [])
}
