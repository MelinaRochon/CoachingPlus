//
//  PlayerHomePageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/**
 The `PlayerHomePageView` is the main view for the player’s homepage. This screen displays two sections:
 - **Scheduled Games**: Future games the player is scheduled for, with a preview of the next games and a link to view all scheduled games.
 - **Recent Footage**: Past games where footage is available, with a preview of the last games and a link to view all recent footage.
 
 The view also handles error display, loading state, and scrolling behavior. It uses a `GameModel` to fetch the games associated with the player and separates them into past and future categories.

 - **State Properties**:
    - `gameModel`: A view model responsible for loading game data and managing the state related to games.
    - `pastGames`: A list of past games (recent footage) that the player has participated in.
    - `futureGames`: A list of upcoming scheduled games for the player.
    - `showErrorMessage`: A flag to control when to display an error message.

 - **View Structure**:
    - The `NavigationStack` is used to allow navigation between views.
    - **Scheduled Games Section**: Displays a preview of upcoming games and a link to view all scheduled games.
    - **Recent Footage Section**: Displays a preview of past games with footage and a link to view all recent games.
    - A `CustomUIFields.loadingSpinner` is shown when both past and future games are empty to indicate that data is still loading.

 - **Game Data Fetching and Filtering**:
    - The games are loaded using the `gameModel.loadAllAssociatedGames()` function.
    - Once the games are fetched, they are filtered into future and past games based on their start time and duration using the `filterGames` function.

 - **Error Handling**:
    - If an error occurs while loading the games, an alert is shown with an error message.

 - **Functions**:
    - `filterGames`: This function categorizes the fetched games into `futureGames` and `pastGames` based on the current date and time. It compares the game’s end time with the current date to determine if the game is upcoming or has already occurred.

*/
struct PlayerHomePageView: View {
    
    // MARK: - State Properties
    
    /// ViewModel responsible for loading game data.
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer
        
    /// List of past games (recent footage).
    @State private var pastGames: [HomeGameDTO] = []
    @State private var pastGameIndexed: [IndexedGame] = []

    /// List of upcoming games (scheduled games).
    @State private var futureGames: [HomeGameDTO] = []
    
    /// Controls whether an error message is displayed.
    @State private var showErrorMessage: Bool = false
            
    @State private var selectedIndex: Int = 0
    @State private var isLoadingMyPastGames: Bool = false
    @State private var isLoadingMyScheduledGames: Bool = false
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                CustomSegmentedPicker(
                    selectedIndex: $selectedIndex,
                    options: [
                        (title: "Recent Games", icon: "person.crop.square.badge.video.fill"),
                        (title: "Scheduled Games", icon: "calendar.badge.clock"),
                    ]
                )
                
                if selectedIndex == 0 {
                    // Show the recent games, if any
                    CustomListSection(
                        titleContent: {
                            AnyView(
                                CustomUIFields.customDivider("Most Recent Games")
                            )
                        },
                        items: pastGameIndexed.map { $0 },
                        isLoading: isLoadingMyPastGames,
                        isLoadingProgressViewTitle: "Searching for my recent games…",
                        noItemsFoundIcon: "questionmark.video.fill",
                        noItemsFoundTitle: "No recent games found at this time.",
                        noItemsFoundSubtitle: "Try again later",
                        destinationBuilder: { indexedGame in
                            SelectedRecentGameView(selectedGame: indexedGame.homeGame, userType: .player)
                        },
                        rowContent: { indexedGame in
                            AnyView(
                                HStack {
                                    Image(systemName: indexedGame.isFullGame ? "video.fill" : "microphone.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 5)
                                    
                                    VStack (alignment: .leading, spacing: 2) {
                                        Text(indexedGame.homeGame.game.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        Text(indexedGame.homeGame.team.name)
                                            .font(.footnote)
                                            .padding(.leading, 1)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.gray)
                                        Text(formatStartTime(indexedGame.homeGame.game.startTime))
                                            .font(.caption)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            )
                        }
                    )

                } else {
                    CustomListSection(
                        titleContent: {
                            AnyView(
                                CustomUIFields.customDivider("Upcoming Games")
                            )
                        },
                        items: futureGames.prefix(20).map { $0 },
                        isLoading: isLoadingMyScheduledGames,
                        rowLogo: "clock.fill",
                        rowLogoColor: .green,
                        isLoadingProgressViewTitle: "Searching for my upcoming games…",
                        noItemsFoundIcon: "clock.badge.questionmark.fill",
                        noItemsFoundTitle: "No upcoming games found at this time.",
                        noItemsFoundSubtitle: "Try again later",
                        destinationBuilder: { game in
                            SelectedScheduledGameView(selectedGame: game, userType: .player)
                        },
                        rowContent: { game in
                            AnyView(
                                HStack {
                                    VStack (alignment: .leading, spacing: 2) {
                                        Text(game.game.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        Text(game.team.name)
                                            .font(.footnote)
                                            .padding(.leading, 1)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.gray)
                                        Text(formatStartTime(game.game.startTime))
                                            .font(.caption)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.green)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            )
                        }
                    )
                }
                
                Spacer()
            }
            .onAppear {
                gameModel.setDependencies(dependencies)
            }
            .task {
                // Fetch games when view loads
                do {
                    isLoadingMyPastGames = true
                    isLoadingMyScheduledGames = true

                    let allGames = try await gameModel.loadAllAssociatedGames()
                    print("back from allGames is setr to: \(allGames)")
                    if !allGames.isEmpty {
                        // Filter games into future and past categories
                        await filterGames(allGames: allGames)
                        
                        if !pastGames.isEmpty {
                            
                            let indexed: [IndexedGame] = try await withThrowingTaskGroup(of: IndexedGame.self) { group in
                                for pastGame in pastGames {
                                    group.addTask {
                                        let fullGameExist = try await dependencies.fullGameRecordingManager
                                            .doesFullGameVideoExistsWithGameId(
                                                teamDocId: pastGame.team.id,
                                                gameId: pastGame.game.gameId,
                                                teamId: pastGame.team.teamId
                                            )
                                        
                                        return IndexedGame(
                                            id: "\(pastGame.game.gameId)-\(UUID().uuidString)",
                                            isFullGame: fullGameExist,
                                            homeGame: pastGame
                                        )
                                    }
                                }
                                
                                var results: [IndexedGame] = []
                                for try await result in group {
                                    results.append(result)
                                }
                                return results
                            }
                            
                            pastGameIndexed = indexed
                            pastGameIndexed.sort { a, b in
                                let da = a.homeGame.game.startTime ?? .distantPast
                                let db = b.homeGame.game.startTime ?? .distantPast
                                return da > db // DESCENDING — newest first
                            }
                        }
                    }
                    isLoadingMyPastGames = false

                } catch {
                    print("Error needs to be handled. \(error)")
                    isLoadingMyPastGames = false
                    isLoadingMyScheduledGames = false
                    showErrorMessage = true
                }
            }
            .alert("Error occured when loading games.", isPresented: $showErrorMessage) {
                Button(role: .cancel) {
                    // reset email and password
                } label: {
                    Text("OK")
                }
            }
            .navigationTitle(Text("Home"))
            .navigationBarTitleDisplayMode(.large)
        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
    }
        
    
    // MARK: - Functions
    
    /// Filters the provided list of games into past and future categories based on their end time.
    /// - Parameter allGames: An array of `HomeGameDTO` objects representing all games associated with the coach.
    private func filterGames(allGames: [HomeGameDTO]) async {
        // Get the current date and time to determine whether a game is in the past or future.
        let currentDate = Date()
        
        // Temporary arrays to store categorized games.
        var tmpFutureGames: [HomeGameDTO] = []
        var tmpPastGames: [HomeGameDTO] = []
        
        // Iterate over all provided games.
        for game in allGames {
            // Ensure the game has a valid start time before processing.
            if let startTime = game.game.startTime {
                let gameEndTime = startTime.addingTimeInterval(TimeInterval(game.game.duration))
                
                // If the game is still ongoing or in the future, add it to future games.
                if gameEndTime > currentDate {
                    tmpFutureGames.append(game)
                } else {
                    // Otherwise, classify it as a past game.
                    tmpPastGames.append(game)
                }
            }
        }
        
        // Update the view's state with the filtered lists.
        self.pastGames = tmpPastGames
        self.futureGames = tmpFutureGames
        isLoadingMyScheduledGames = false
    }
}

#Preview {
    PlayerHomePageView()
}

extension UINavigationBarAppearance {
    func setColor(title: UIColor? = nil) {
        configureWithTransparentBackground()
        if let titleColor = title {
            largeTitleTextAttributes = [.foregroundColor: titleColor]
            titleTextAttributes = [.foregroundColor: titleColor]
        }
        UINavigationBar.appearance().scrollEdgeAppearance = self
        UINavigationBar.appearance().standardAppearance = self
        UINavigationBar.appearance().tintColor = UIColor.red
    }
}
