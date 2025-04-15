//
//  SwiftUIView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI

/// A SwiftUI view that presents filtering and settings options for game and player visibility.
/// It allows toggling between upcoming and past games, and selecting a player filter option.
///
/// - Parameters:
///   - showUpcomingGames: A binding to a Boolean that controls whether upcoming games are shown.
///   - showRecentGames: A binding to a Boolean that controls whether past games are shown.
///   - showPlayers: A binding to an array of player filter options (e.g., "All Players").
///   - showPlayersIndex: A binding to the currently selected index in the `showPlayers` array.
struct UpcomingGameSectionView: View {
    @Binding var showUpcomingGames: Bool
    @Binding var showRecentGames: Bool
    @Binding var showPlayers: [String]
    @Binding var showPlayersIndex: Int
    
    var body: some View {
        VStack {
            List {
                // Section for toggling visibility of past and upcoming games
                Section(header: Text("Footage Settings")) {
                    Button {
                        showRecentGames.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showRecentGames ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                            Text("Show Past Games").foregroundStyle(.black)
                        }
                    }
                    Button {
                        showUpcomingGames.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showUpcomingGames ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                            Text("Show Upcoming Games").foregroundStyle(.black)
                        }
                    }
                }
                
                // Section for choosing which group of players to show using a picker
                Section(header: Text("Player Settings")) {
                    Picker("Show Players", selection: $showPlayersIndex) {
                        ForEach(showPlayers.indices, id: \.self) { i in
                            Text(self.showPlayers[i])
                        }
                    }
                }
                
            }.scrollDisabled(true) // Disables scrolling for this list
        }
    }
}
