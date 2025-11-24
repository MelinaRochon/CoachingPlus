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
    
    @State private var selectedTab: Tab = .scheduled

       enum Tab: String, CaseIterable, Identifiable {
           case scheduled = "Scheduled Games"
           case recent = "Recent Games"

           var id: String { self.rawValue }

           var iconName: String {
               switch self {
               case .scheduled: return "calendar.badge.clock"
               case .recent: return "camera.badge.clock"
               }
           }
       }

    // MARK: - State Properties

    /// ViewModel responsible for loading game data.
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Indicates whether recent games are available.
    @State private var recentGamesFound: Bool = false
    
    /// Indicates whether future games are available.
    @State private var futureGamesFound: Bool = false
    
    /// List of past games (recent footage).
    @State private var pastGames: [HomeGameDTO] = []
    @State private var pastGameIndexed: [IndexedGame] = []

    /// List of upcoming games (scheduled games).
    @State private var futureGames: [HomeGameDTO] = []
    
    /// Controls whether an error message is displayed.
    @State private var showErrorMessage: Bool = false
    
    /// Tracks whether the ScrollView should reset to the top.
    @State private var scrollToTop: Bool = false
    
    @State private var selectedSegmentIndex: Int = 0
    @State private var segmentTypes: [String] = ["Scheduled Games", "Recent Games"]
    @State private var imageTypes: [String] = ["calendar.badge.clock", "camera.badge.clock"]
    
    @State private var selectedIndex: Int = 0
    
    @State private var isLoadingMyPastGames: Bool = false

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
                        items: Array(pastGameIndexed.prefix(20)),
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
                        isLoading: isLoadingMyPastGames,
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
                gameModel.setDependencies(dependencies)
            }

            .task {
                // Fetch games when view loads
                do {
                    isLoadingMyPastGames = true
                    let allGames = try await gameModel.loadAllAssociatedGames()
                    if !allGames.isEmpty {
                        // Filter games into future and past categories
                        await filterGames(allGames: allGames)
                        
                        // Update flags based on availability of games
                        if !pastGames.isEmpty {
                            print("pastGames is not emptu")
                            futureGamesFound = true
                            for (index, pastGame) in pastGames.prefix(20).enumerated() {
                                // Only do the first 3 games
                                let fullGameExist = try await dependencies.fullGameRecordingManager.doesFullGameVideoExistsWithGameId(
                                    teamDocId: pastGame.team.id,
                                    gameId: pastGame.game.gameId,
                                    teamId: pastGame.team.teamId
                                )
                                
                                let indexedGame = IndexedGame(id: index, isFullGame: fullGameExist, homeGame: pastGame)
                                print("indexed game = \(indexedGame)")
                                pastGameIndexed.append(indexedGame)
                            }

                        }
                        futureGamesFound = !futureGames.isEmpty
                        recentGamesFound = !pastGames.isEmpty
                    }
                    isLoadingMyPastGames = false
                } catch {
                    print("Error needs to be handled. \(error)")
                    isLoadingMyPastGames = false
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
//            .background(Color(UIColor.white))
            .navigationTitle(Text("Home"))
        }
        
    }
    
    // MARK: - Functions
    
    private func refreshHome(for index: Int) async throws {
        if index == 0 {
            do {
                
            }
        } else {
            
        }
    }

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
        let now = Date()
        self.pastGames = tmpPastGames // = tmpPastGames.compactMap { $0.game.startTime != nil ? $0 : nil } // keep only games with startTime
//            .filter { $0.game.startTime! <= now }               // force unwrap is safe here
//            .sorted { $0.game.startTime! > $1.game.startTime! }
        self.futureGames = tmpFutureGames
    }
        
    
}

#Preview {
    CoachHomePageView()
}


struct IndexedGame: Identifiable {
    let id: Int
    let isFullGame: Bool
    let homeGame: HomeGameDTO
}
