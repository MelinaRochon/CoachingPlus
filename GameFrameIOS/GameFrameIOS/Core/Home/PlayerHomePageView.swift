//
//  PlayerHomePageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerHomePageView: View {
    
    // MARK: - State Properties
    
    /// ViewModel responsible for loading game data.
    @StateObject private var gameModel = GameModel()
    
    //    @StateObject private var viewModel = HomePageViewModel()
    
    /// Indicates whether recent games are available.
    @State private var recentGamesFound: Bool = false
    
    /// Indicates whether future games are available.
    @State private var futureGamesFound: Bool = false
    
    /// List of past games (recent footage).
    @State private var pastGames: [HomeGameDTO] = []
    
    /// List of upcoming games (scheduled games).
    @State private var futureGames: [HomeGameDTO] = []
    
    /// Controls whether an error message is displayed.
    @State private var showErrorMessage: Bool = false
    
    /// Tracks whether the ScrollView should reset to the top.
    @State private var scrollToTop: Bool = false
    
    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            Divider()
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        // Scheduled Games Section
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: AllScheduledGamesView(futureGames: futureGames, userType: "Player")) {
                                Text("Scheduled Games")
                                    .font(.headline)
                                    .foregroundColor(futureGamesFound ? .blue : .secondary)
                                
                                Image(systemName: "chevron.right").foregroundColor(futureGamesFound ? .blue : .secondary)
                                Spacer()
                            }
                            .padding(.bottom, 4)
                            .disabled(!futureGamesFound)
                            
                            // Display preview of upcoming games
                            if !futureGames.isEmpty {
                                
                                // Loop through games and show a preview of the next 3 games
                                ForEach(futureGames.prefix(3), id: \.game.gameId) { scheduledGame in
                                    NavigationLink(destination: SelectedScheduledGameView(selectedGame: scheduledGame, userType: "Player")) {
                                        VStack {
                                            Text(scheduledGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                            
                                            Text(scheduledGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.secondary)
                                            Text(formatStartTime(scheduledGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                        }
                                    }.foregroundColor(.black)
                                }
                            } else {
                                Text("No scheduled game at the moment.").font(.caption).foregroundColor(.secondary)
                            }
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                        
                        // Recent Footage Section
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: AllRecentFootageView(pastGames: pastGames, userType: "Player")) {
                                Text("Recent Footage")
                                    .font(.headline)
                                    .foregroundColor(recentGamesFound ? .blue : .secondary)
                                
                                Image(systemName: "chevron.right").foregroundColor(recentGamesFound ? .blue : .secondary)
                                Spacer()
                            }
                            .padding(.bottom, 4)
                            .disabled(!recentGamesFound)
                            
                            if !pastGames.isEmpty {
                                // Loop through games and show a preview of the past 3 games
                                ForEach(pastGames.prefix(3), id: \.game.gameId) { pastGame in
                                    NavigationLink(destination: SelectedRecentGameView(selectedGame: pastGame, userType: "Player")) {
                                        HStack {
                                            CustomUIFields.gameVideoPreviewStyle()
                                            
                                            VStack {
                                                Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                Text(formatStartTime(pastGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Divider().background(content: { Color.gray.opacity(0.3) })
                                            }
                                        }
                                    }.foregroundColor(.black)
                                }
                            } else {
                                Text("No recent games at the moment.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                        .padding(.horizontal).padding(.top)
                        
                        if pastGames.isEmpty && futureGames.isEmpty {
                            CustomUIFields.loadingSpinner("Loading games...")
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            proxy.scrollTo(0, anchor: .top) // Scroll to top when view appears
                        }
                    }
                }
            }
            .task {
                // Fetch games when view loads
                do {
                    let allGames = try await gameModel.loadAllAssociatedGames()
                    
                    // Filter games into future and past categories
                    await filterGames(allGames: allGames)
                    
                    // Update flags based on availability of games
                    futureGamesFound = !futureGames.isEmpty
                    recentGamesFound = !pastGames.isEmpty
                } catch {
                    print("Error needs to be handled. \(error)")
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
        }
        .background(Color(UIColor.white))
        .navigationTitle(Text("Home"))
        .navigationBarTitleDisplayMode(.large)
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
    }
}

#Preview {
    PlayerHomePageView()
}
