//
//  PlayerMyTeamView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

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
    
    /// View model responsible for managing player-related data.
    @StateObject private var playerModel = PlayerModel()
    
    /// The team whose details and settings are being viewed.
    @State var selectedTeam: DBTeam
    
    /// Controls whether the team settings view is displayed.
    @State private var isTeamSettingsEnabled: Bool = false
    
    @State private var groupedGames: [(label: String, games: [DBGame])]? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                List {
                    
                    if let groupedGames = groupedGames {
                        GroupedGamesList(
                            groupedGames: groupedGames,
                            selectedTeam: selectedTeam,
                            destinationBuilder: { game in
                                AnyView(PlayerSpecificFootageView(game: game, team: selectedTeam))
                            },
                            showUpcomingGames: true,
                            showRecentGames: true
                        )
                    } else {
                        Text("No saved footage.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            }
            .navigationTitle(Text(selectedTeam.teamNickname))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshData() // Refresh data when the view appears
            }
            .toolbar {
                // Toolbar item for accessing team settings
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isTeamSettingsEnabled.toggle() // Toggle team settings visibility
                    }) {
                        Label("Settings", systemImage: "gear").foregroundStyle(.red) // Settings icon with label
                    }
                }
            }
            .sheet(isPresented: $isTeamSettingsEnabled) {
                // Sheet to modify team settings
                CoachTeamSettingsView(players: playerModel.players, team: selectedTeam)
            }
        }
    }
    
    
    // MARK: - Function
    
    /// Function to refresh team data and load games and players
    private func refreshData() {
        Task {
            do {
                // Load games and players associated with the team
                try await gameModel.getAllGames(teamId: selectedTeam.teamId)
                self.groupedGames = groupGamesByWeek(gameModel.games)
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
                // Print error message if data fetching fails
                print("Error occurred when getting the team games data: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    PlayerMyTeamView(selectedTeam: team)
}
