//
//  PlayerMyTeamView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared

/**
 This view is responsible for displaying the details of the selected team, including all recorded game footage and players related to that team.
 
 Key responsibilities:
 - Displays a list of games that the team has participated in, including their titles and start times.
 - Allows the user (typically a coach) to access a detailed view of each game's footage by navigating to the `PlayerSpecificFootageView`.
 - Displays a button in the toolbar for accessing the team's settings, where the coach can modify team-related information.
 - Handles the refresh of game and player data when the view appears, ensuring that the list of games and players is up to date.
 - Provides a mechanism for adding players to the team if the team is missing any players, including showing a message if there are no players or invited players available.
 - The view supports different modes depending on the user's role (e.g., coach or player).
 
 The view is structured to allow easy navigation between games, display key information about the games (such as game titles, start times, and game status), and provide settings to manage the team’s players.
 
 **Functions:**
 - `refreshData()`: Fetches the latest game and player data for the selected team. It loads all games associated with the team and fetches the players and invited players from the team’s data model.
 - `onAppear`: The view fetches the data whenever the view appears on the screen to ensure it is up-to-date.
 
 This view is specifically designed for coaches to manage and view team-related data, such as game schedules and player information. It also allows coaches to modify team settings and manage their players in a structured and intuitive way.
 
 */
struct PlayerMyTeamView: View {
    /// Stores the index of the selected segment (if segmented control is implemented in the future).
    @State private var selectedSegmentIndex = 0
    
    /// Controls whether the "Add Players" section is shown.
    @State private var showAddPlayersSection = false
    
    /// View model responsible for managing game-related data.
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// View model responsible for managing player-related data.
    @StateObject private var playerModel = PlayerModel()
    
    /// The team whose details and settings are being viewed.
    @State var selectedTeam: DBTeam
    
    /// Controls whether the team settings view is displayed.
    @State private var isTeamSettingsEnabled: Bool = false
    
    @State private var groupedGames: [(label: String, games: [IndexedFootage])]? = nil
    @State private var groupedFootage: [IndexedFootage] = []

    /// Toggles the visibility of the games settings view (e.g., filters or display preferences).
    @State private var isGamesSettingsEnabled: Bool = false
    
    @State private var showPlayersSheet: Bool = false

    /// Controls whether upcoming games should be shown in the list.
    @State private var showUpcomingGames = false

    /// Controls whether recent (past) games should be shown in the list.
    @State private var showRecentGames = true
    
    /// Defines the available filter options for displaying players in the UI.
    @State private var showPlayers = ["All Players", "Accepted Players", "Invited Players"]

    /// Tracks the currently selected index in the `showPlayers` filter array.
    @State private var showPlayersIndex = 0

    @State private var isLoadingFootage: Bool = false
    @State private var isLoadingRoster: Bool = false
    @State private var isLoadingMoreFootage: Bool = false
    @State private var hasTriggeredLoadFor: Set<String> = []

    var body: some View {
        VStack {
            Divider()
            
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
                                userType: .player
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
                .padding(.top, 15)
                .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                    Color.clear.frame(height: 75)
                }
            }
        }
        .navigationTitle(Text(selectedTeam.teamNickname))
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
            Color.clear.frame(height: 75)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        isTeamSettingsEnabled.toggle() // Toggle team settings visibility
                    }) {
                        Label("Settings", systemImage: "gear")
                    }.tint(.red)
                    
                    Button(action: {
                        showPlayersSheet.toggle()
                    }) {
                        Label("Players", systemImage: "person.2.circle")
                    }.tint(.red)
                    
                    Button(action: {
                        isGamesSettingsEnabled.toggle()
                    }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .tint(.red)
                }
            }
        }
        .sheet(isPresented: $isTeamSettingsEnabled) {
            // Sheet to modify team settings
            TeamSettingsView(userType: .player, team: selectedTeam, dismissOnRemove: .constant(false))
        }
        .sheet(isPresented: $isGamesSettingsEnabled) {
            NavigationStack {
                TeamSectionView(showUpcomingGames: $showUpcomingGames, showRecentGames: $showRecentGames, showPlayers: $showPlayers, showPlayersIndex: $showPlayersIndex, userType: .player)
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
        .sheet(isPresented: $showPlayersSheet) {
            NavigationStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .center) {
                        Text("Roster")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Team roster — your teammates")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                    
                    ScrollView {
                        VStack {
                            if isLoadingRoster {
                                VStack {
                                    ProgressView("Loading Roster…")
                                        .padding()
                                        .background(.white)
                                        .cornerRadius(12)
                                        .frame(maxWidth: .infinity)
                                }
                            } else {
                                if !playerModel.players.isEmpty {
                                    ForEach(playerModel.players, id: \.playerDocId) { player in
                                        VStack(alignment: .leading) {
                                            CustomUIFields.imageLabel(text: "\(player.firstName) \(player.lastName)", systemImage: "person.circle")
                                                .padding(.vertical, 5)
                                            
                                            Divider()
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    }
                                } else {
                                    VStack {
                                        Image(systemName: "person.2.slash.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                        
                                        Text("No teammates found at this time.").font(.headline).foregroundStyle(.secondary)
                                        Text("Try again later.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showPlayersSheet = false
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
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
            }
        }
        .onAppear {
            gameModel.setDependencies(dependencies)
            playerModel.setDependencies(dependencies)
            refreshData() // Refresh data when the view appears
        }
    }
    
    
    // MARK: - Function
    
    /// Function to refresh team data and load games and players
    private func refreshData() {
        Task {
            do {
                isLoadingFootage = true
                isLoadingRoster = true
                // Load games and players associated with the team
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
                isLoadingRoster = false
            } catch {
                isLoadingFootage = false
                isLoadingRoster = false
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
    PlayerMyTeamView(selectedTeam: team)
}
