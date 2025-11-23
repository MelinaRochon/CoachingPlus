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
    
    /// The available segment options (Footage and Players).
    let segmentTypes = ["Footage", "Players"]
    
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
    @State private var groupedGames: [(label: String, games: [DBGame])]? = nil

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

    
    // MARK: - View
    
    var body: some View {
        VStack {
            Divider()
            
            // Segmented Picker to toggle between "Footage" and "Players" views
            Picker("Type of selection - Segmented", selection: $selectedSegmentIndex) {
                ForEach(segmentTypes.indices, id: \.self) { i in
                    Text(self.segmentTypes[i])
                }
            }
            .pickerStyle(.segmented)
            .padding(.leading)
            .padding(.trailing)
            
            // Main list that dynamically changes based on the selected segment
            if (selectedSegmentIndex == 0) {
                
                List {
                    // "Footage" section: Displays games related to the team
                    // Looping through games related to the team
                    if let groupedGames = groupedGames {
                        GroupedGamesList(
                            groupedGames: groupedGames,
                            selectedTeam: selectedTeam,
                            showUpcomingGames: showUpcomingGames,
                            showRecentGames: showRecentGames,
                            userType: .coach
                        )
                    } else {
                        Text("No saved footage.").font(.caption).foregroundStyle(.secondary)
                    }
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                
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
                        Text("No players found.").font(.caption).foregroundStyle(.secondary)
                    }
                }.listStyle(PlainListStyle()).padding(.top, 10) // Optional: Make the list style more simple
            }
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
            CoachAddingGameView(team: selectedTeam) // Adding a new game
        }
        .sheet(isPresented: $isTeamSettingsEnabled) {
            // Sheet to modify team settings
            TeamSettingsView(userType: .coach, team: selectedTeam, dismissOnRemove: $dismissOnRemove)
        }
        .sheet(isPresented: $isGamesSettingsEnabled) {
            NavigationStack {
                TeamSectionView(showUpcomingGames: $showUpcomingGames, showRecentGames: $showRecentGames, showPlayers: $showPlayers, showPlayersIndex: $showPlayersIndex, userType: .coach)
                    .presentationDetents([.medium])
                    .toolbar {
                        ToolbarItem {
                            Button (action: {
                                isGamesSettingsEnabled = false // Close the filter options
                            }) {
                                Text("Done")
                            }
                        }
                    }
                    .navigationTitle("Filtering Options")
                    .navigationBarTitleDisplayMode(.inline)
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
                self.selectedTeam = try await dependencies.teamManager.getTeam(teamId: selectedTeam.teamId)!
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
    CoachMyTeamView(selectedTeam: team)
}
