//
//  CoachMyTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared

/**
 This structure provides the view where coaches can see the footage (games) and players related to a specific team.
 The coach can toggle between the "Footage" and "Players" sections, add new games and players, and access team settings.
 
 ### Features:
 - This view displays all the footages (games) and players related to the selected team.
 - The user can toggle between "Footage" and "Players" using a segmented control at the top.
 - The coach can add new games and players to the team and also modify team settings.
 */
struct CoachMyTeamView: View {
    
    // MARK: - State Properties
    
    /// Tracks the selected segment (Footage or Players).
    @State private var selectedSegmentIndex = 0
    
    /// Toggles visibility for adding a player.
    @State private var addPlayerEnabled = false
    
    /// Toggles visibility for adding a game.
    @State private var addGameEnabled = false
    
    /// Toggles visibility for the team settings view.
    @State private var isTeamSettingsEnabled: Bool = false
        
    /// View model for managing game data.
    @StateObject private var gameModel = GameModel()
    
    /// View model for managing player data.
    @StateObject private var playerModel = PlayerModel()
    
    @StateObject private var teamModel = TeamModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// The team whose settings are being viewed and modified.
    @State var selectedTeam: DBTeam
    
    /// Holds the list of grouped games, organized by a label (e.g., "Upcoming Games", "Past Games").
    /// Initially set to `nil` to allow for asynchronous loading or conditional rendering.
    @State private var groupedGames: [(label: String, games: [IndexedFootage])]? = nil
    @State private var groupedFootage: [IndexedFootage] = []

    /// Toggles the visibility of the games settings view (e.g., filters or display preferences).
    @State private var isGamesSettingsEnabled: Bool = false

    /// Controls whether upcoming games should be shown in the list.
    @State private var showUpcomingGames = false

    /// Controls whether recent (past) games should be shown in the list.
    @State private var showRecentGames = true

    /// Defines the available filter options for displaying players in the UI.
    @State private var showPlayers = ["All Players", "Accepted Players", "Invited Players"]

    /// Tracks the currently selected index in the `showPlayers` filter array.
    @State private var showPlayersIndex = 0
    
    @State private var dismissOnRemove: Bool = false

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    @State private var showErrorWhenSaving: Bool = false

    @State private var isLoadingFootage: Bool = false
    @State private var isLoadingMoreFootage: Bool = false
    @State private var hasTriggeredLoadFor: Set<String> = []
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Divider()
            
            // Segmented Picker to toggle between "Footage" and "Players" views
            CustomSegmentedPicker(
                selectedIndex: $selectedSegmentIndex,
                options: [
                    (title: "Footage", icon: "video.fill"),
                    (title: "Players", icon: "figure.indoor.soccer"),
                ]
            )
            
            // Main list that dynamically changes based on the selected segment
            if (selectedSegmentIndex == 0) {
                
                if isLoadingFootage {
                    VStack {
                        ProgressView("Loading Game Footage")
                            .padding()
                            .background(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                            // "Footage" section: Displays games related to the team
                            // Looping through games related to the team
                            if let groupedGames = groupedGames, !groupedGames.isEmpty {
                                GroupedGamesList(
                                    groupedGames: groupedGames,
                                    selectedTeam: selectedTeam,
                                    showUpcomingGames: showUpcomingGames,
                                    showRecentGames: showRecentGames,
                                    userType: .coach
                                )
                                
                                if let last = groupedFootage.last {
                                    // Attach load trigger to last visible game cell
                                    Color.clear
                                        .frame(height: 1)
                                        .onAppear {
                                            guard gameModel.lastDoc != nil else { return }
                                            guard !isLoadingMoreFootage else { return }
                                            guard showRecentGames else { return }
                                            guard !hasTriggeredLoadFor.contains(last.id) else { return }
                                            
                                            hasTriggeredLoadFor.insert(last.id)
                                            
                                            Task { await loadMoreFootage() }
                                        }
                                }
                                
                                if isLoadingMoreFootage {
                                    ProgressView("Loading more footage…")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            } else {
                                VStack(alignment: .center) {
                                        Image(systemName: "video.slash.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                    
                                    Text("No game footage was found at this time.").font(.headline).foregroundStyle(.secondary)
                                    
                                    Text("Try adding a game first or try again later.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                        Color.clear.frame(height: 75)
                    }
                }
            } else {
                List {
                    // "Players" section: Displays players related to the team
                    // Looping through players related to the team
                    if !playerModel.players.isEmpty {
                        if showPlayersIndex == 0 { // All Players
                            PlayersList(players: playerModel.players, teamDocId: selectedTeam.id)
                            
                        } else if showPlayersIndex == 1 {
                            // Show all accepted players
                            let filteredPlayers = playerModel.players.filter { $0.status == "Accepted" }
                            PlayersList(players: filteredPlayers, teamDocId: selectedTeam.id)
                        } else {
                            // Show all players invited
                            let filteredPlayers = playerModel.players.filter { $0.status == "Pending Invite" }
                            PlayersList(players: filteredPlayers, teamDocId: selectedTeam.id)
                        }
                    } else {
                        VStack(alignment: .center) {
                            Image(systemName: "person.2.slash.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                            
                            Text("No player was found at this time.").font(.headline).foregroundStyle(.secondary)
                            
                            Text("Try adding a player to your roster.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                }.listStyle(PlainListStyle())
            }
            
            Spacer()
        }
        .navigationTitle(Text(selectedTeam.teamNickname))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            teamModel.setDependencies(dependencies)
            gameModel.setDependencies(dependencies)
            playerModel.setDependencies(dependencies)
            refreshData() // Refresh data when the view appears
        }
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
        .onChange(of: dismissOnRemove) {
            Task {
                do {
                    // Remove team from database and from all players
                    try await teamModel.deleteTeam(teamDocId: selectedTeam.id)
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .toolbar {
            // Toolbar item for accessing team settings
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        isTeamSettingsEnabled.toggle() // Toggle team settings visibility
                    }) {
                        Label("Settings", systemImage: "gear")
                    }
                    .tint(.red)
                    
                    Button(action: {
                        isGamesSettingsEnabled.toggle()
                    }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .tint(.red)
                    
                    Menu {
                        Button{
                            addGameEnabled.toggle()
                        } label: {
                            Label("Add Game", systemImage: "calendar.badge.plus")
                        }
                        Button{
                            addPlayerEnabled.toggle()
                        } label: {
                            Label("Add Player", systemImage: "person.fill.badge.plus")
                        }
                        
                    } label: {
                        Label("Plus", systemImage: "plus")
                    }
                    .tint(.red)
                }
            }
        }
        .fullScreenCover(isPresented: $addPlayerEnabled, onDismiss: refreshData) {
            // Sheet to add a new player
            CoachAddNewInviteView(team: selectedTeam)
        }
        .sheet(isPresented: $addGameEnabled, onDismiss: refreshData) {
            // Sheet to add a new game
            CoachAddingGameView(team: selectedTeam, showErrorWhenSaving: $showErrorWhenSaving) // Adding a new game
        }
        .sheet(isPresented: $isTeamSettingsEnabled) {
            // Sheet to modify team settings
            TeamSettingsView(userType: .coach, team: selectedTeam, dismissOnRemove: $dismissOnRemove)
        }
        .sheet(isPresented: $isGamesSettingsEnabled) {
            NavigationStack {
                TeamSectionView(showUpcomingGames: $showUpcomingGames, showRecentGames: $showRecentGames, showPlayers: $showPlayers, showPlayersIndex: $showPlayersIndex, userType: .coach)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(20)
                    .presentationBackgroundInteraction(.disabled)
                    .interactiveDismissDisabled(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                isGamesSettingsEnabled = false
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray) // Make text + icon white
                                    .frame(width: 40, height: 40) // Make it square
                                    .background(Circle().fill(Color(uiColor: .systemGray6)))
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 0)
                        }
                    }
            }
        }
        .alert("Error occured when saving game", isPresented: $showErrorWhenSaving) {
            Button("OK") {
                showErrorWhenSaving = false
            }
        } message: {
            Text("Please try again later")
        }
    }
    
    
    // MARK: - Function
    
    /// Function to refresh team data and load games and players
    private func refreshData() {
        Task {
            do {
                // Load games and players associated with the team
                print("selected them = \(selectedTeam)")
                isLoadingFootage = true
                await gameModel.loadInitial(teamDocId: selectedTeam.id)
                
                await withTaskGroup(of: IndexedFootage?.self) { group in
                    for game in gameModel.games {
                        group.addTask {
                            do {
                                let exists = try await dependencies.fullGameRecordingManager
                                    .doesFullGameVideoExistsWithGameId(
                                        teamDocId: selectedTeam.id,
                                        gameId: game.gameId,
                                        teamId: game.teamId
                                    )
                                // Use stable id (gameId); avoid UUID unless intentionally unique
                                return IndexedFootage(id: game.gameId, isFullGame: exists, game: game)
                            } catch {
                                print("error checking file for \(game.gameId): \(error)")
                                return nil
                            }
                        }
                    }
                    
                    for await result in group {
                        if let indexed = result {
                            // append on main thread
                            await MainActor.run {
                                // avoid duplicates (defensive)
                                if !groupedFootage.contains(where: { $0.id == indexed.id }) {
                                    groupedFootage.append(indexed)
                                }
                            }
                        }
                    }
                }
                
                self.groupedGames = groupFootageByWeek(groupedFootage)                
                isLoadingFootage = false
                
                guard let tmpPlayers = selectedTeam.players else {
                    print("There are no players in the team at the moment. Please add one.")
                    // TODO: - Will need to add more here! Maybe an icon can show on the page to let the user know there's no player in the team
                    return
                }
                
                guard let tmpInvites = selectedTeam.invites else {
                    print("There are no players in the team at the moment. Please add one.")
                    // TODO: Will need to add more here! Maybe an icon can show on the page to let the user know there's no player in the team
                    return
                }

                try await playerModel.getAllPlayers(invites: tmpInvites, players: tmpPlayers)
            } catch {
                isLoadingFootage = false
                // Print error message if data fetching fails
                print("Error occurred when getting the team games data: \(error.localizedDescription)")
            }
        }
    }
    
    func loadMoreFootage() async {
        guard !isLoadingMoreFootage else { return }
        isLoadingMoreFootage = true

        await gameModel.loadMore(teamDocId: selectedTeam.id)

        await withTaskGroup(of: IndexedFootage?.self) { group in
            for game in gameModel.games {
                group.addTask {
                    do {
                        let exists = try await dependencies.fullGameRecordingManager
                            .doesFullGameVideoExistsWithGameId(
                                teamDocId: selectedTeam.id,
                                gameId: game.gameId,
                                teamId: game.teamId
                            )
                        return IndexedFootage(id: game.gameId, isFullGame: exists, game: game)
                    } catch {
                        print("error checking file for \(game.gameId): \(error)")
                        return nil
                    }
                }
            }

            for await result in group {
                if let indexed = result {
                    await MainActor.run {
                        if !groupedFootage.contains(where: { $0.id == indexed.id }) {
                            groupedFootage.append(indexed)
                        }
                    }
                }
            }
        }

        groupedGames = groupFootageByWeek(groupedFootage)
        isLoadingMoreFootage = false
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    CoachMyTeamView(selectedTeam: team)
}


struct IndexedFootage: Identifiable {
    let id: String
    let isFullGame: Bool
    let game: DBGame
}
