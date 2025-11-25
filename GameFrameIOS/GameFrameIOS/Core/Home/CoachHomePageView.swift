//
//  CoachHomePageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/// The main home page for a coach, displaying upcoming scheduled games and recent game recordings.
/// This view fetches the coach's associated games and categorizes them into past and future games.
struct CoachHomePageView: View {
    
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

//                                CustomDividerWithNavigationLink(
//                                    title: "Most Recent Games",
//                                    subTitle: "See All",
//                                    subTitleColor: .red
//                                ) {
//                                    AllRecentFootageView(pastGames: pastGames, userType: .coach)
//                                }
                            )
                        },
                        items: pastGameIndexed.map { $0 },
                        isLoading: isLoadingMyPastGames,
                        isLoadingProgressViewTitle: "Searching for my recent games…",
                        noItemsFoundIcon: "questionmark.video.fill",
                        noItemsFoundTitle: "No recent games found at this time.",
                        noItemsFoundSubtitle: "Try again later",
                        destinationBuilder: { indexedGame in
                            SelectedRecentGameView(selectedGame: indexedGame.homeGame, userType: .coach)
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
                    // Show the scheduled games
                    CustomListSection(
                        titleContent: {
                            AnyView(
                                CustomUIFields.customDivider("Upcoming Games")
//                                CustomDividerWithNavigationLink(
//                                    title: "Upcoming Games",
//                                    subTitle: "See All",
//                                    subTitleColor: .red
//                                ) {
//                                    AllScheduledGamesView(futureGames: futureGames, userType: .coach)
//                                }
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
                            SelectedScheduledGameView(selectedGame: game, userType: .coach)
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
                pastGameIndexed = []
                gameModel.setDependencies(dependencies)
            }

            .task {
                // Fetch games when view loads
                do {
                    isLoadingMyPastGames = true
                    isLoadingMyScheduledGames = true
                    let allGames = try await gameModel.loadAllAssociatedGames()

                    if !allGames.isEmpty {
                        // Filter games into future and past categories
                        await filterGames(allGames: allGames)
                        
                        // Update flags based on availability of games
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
                        
                        print(">>> NOW ALL pastGameIndexed : \(pastGameIndexed.map { $0.homeGame.game.title }.joined(separator: ", ")) ")

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
    CoachHomePageView()
}


struct IndexedGame: Identifiable {
    let id: String
    let isFullGame: Bool
    let homeGame: HomeGameDTO
}
