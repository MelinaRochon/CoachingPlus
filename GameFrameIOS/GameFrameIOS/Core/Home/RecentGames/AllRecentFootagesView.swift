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
    @State private var pastGameIndexed: [IndexedGame] = []

    @State private var isLoadingMyPastGames: Bool = false
    
    @StateObject private var gameModel = GameModel()
    @State private var teamDocId: String = "6mpZlv7mGho5XaBN8Xcs" // HORNETS

    @EnvironmentObject private var dependencies: DependencyContainer

    // MARK: - View
    
    var body: some View {
        
        VStack {
//            CustomListSection(
//                titleContent: {
//                    AnyView(
//                        CustomUIFields.customDivider("All Recent Games")
////                        CustomDividerWithNavigationLink(
////                            title: "Most Recent Games",
////                            subTitle: "See All",
////                            subTitleColor: .red
////                        ) {
////                            AllRecentFootageView(pastGames: pastGames, userType: .coach)
////                        }
//                    )
//                },
//                items: Array(pastGameIndexed),
//                isLoading: isLoadingMyPastGames,
//                isLoadingProgressViewTitle: "Searching for my recent games…",
//                noItemsFoundIcon: "questionmark.video.fill",
//                noItemsFoundTitle: "No recent games found at this time.",
//                noItemsFoundSubtitle: "Try again later",
//                destinationBuilder: { indexedGame in
//                    SelectedRecentGameView(selectedGame: indexedGame.homeGame, userType: .coach)
//                },
//                rowContent: { indexedGame in
//                    AnyView(
//                        HStack {
//                            Image(systemName: indexedGame.isFullGame ? "video.fill" : "microphone.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.red)
//                                .padding(.horizontal, 5)
//                            
//                            VStack (alignment: .leading, spacing: 2) {
//                                Text(indexedGame.homeGame.game.title)
//                                    .font(.subheadline)
//                                    .fontWeight(.medium)
//                                    .multilineTextAlignment(.leading)
//                                    .lineLimit(2)
//                                    .foregroundStyle(.black)
//                                Text(indexedGame.homeGame.team.name)
//                                    .font(.footnote)
//                                    .padding(.leading, 1)
//                                    .multilineTextAlignment(.leading)
//                                    .foregroundStyle(.gray)
//                                Text(formatStartTime(indexedGame.homeGame.game.startTime))
//                                    .font(.caption)
//                                    .multilineTextAlignment(.leading)
//                                    .foregroundStyle(.black)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    )
//                }
//            )

        }
        List  {
            Section {
//                if !pastGames.isEmpty {
                    // Show all the Recent Games
                    GameList(
                        games: gameModel.homeGames,
                        prefix: nil,
                        gameType: .recent,
                        destinationBuilder: { game in
                            AnyView(SelectedRecentGameView(selectedGame: game, userType: userType))
                        }
                    )
                
                if gameModel.lastDoc != nil {
                        ProgressView()
                            .task { await gameModel.loadMore(teamDocId: teamDocId) }
                    }
//                } else {
//                    Text("No games found.").font(.caption).foregroundStyle(.secondary)
//                }
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
            gameModel.setDependencies(dependencies)
            Task {
                isLoadingMyPastGames = true
                await gameModel.loadInitial(teamDocId: teamDocId)
//                self.filteredGames = pastGames
//                
//                if !pastGames.isEmpty {
//                    print("pastGames is not emptu")
//                    for (index, pastGame) in pastGames.enumerated() {
//                        // Only do the first 3 games
//                        let fullGameExist = try await dependencies.fullGameRecordingManager.doesFullGameVideoExistsWithGameId(
//                            teamDocId: pastGame.team.id,
//                            gameId: pastGame.game.gameId,
//                            teamId: pastGame.team.teamId
//                        )
//                        
//                        let indexedGame = IndexedGame(id: index, isFullGame: fullGameExist, homeGame: pastGame)
////                        print("indexed game = \(indexedGame)")
//                        pastGameIndexed.append(indexedGame)
//                    }
//                    
//                }
                isLoadingMyPastGames = false
            }

        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
    }
}

#Preview {
    AllRecentFootageView(pastGames: [], userType: .player)
}
