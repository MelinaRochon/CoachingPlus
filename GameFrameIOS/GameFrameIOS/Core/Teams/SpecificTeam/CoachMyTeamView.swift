//
//  CoachMyTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

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
    
    /// The team whose settings are being viewed and modified.
    @State var selectedTeam: DBTeam
    
    // MARK: - View

    var body: some View {
        NavigationStack {
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
                List {
                    if (selectedSegmentIndex == 0) {
                        // "Footage" section: Displays games related to the team
                        Section(header:
                                    HStack {
                            Text("Games")
                            Spacer()
                            Button{
                                addGameEnabled.toggle() // Toggles the Add Game form visibility
                            } label: {
                                // Button to add a new game
                                HStack {
                                    Text("Add Game")
                                }
                                .foregroundColor(Color.blue)
                            }
                        }) {
                            // Looping through games related to the team
                            if !gameModel.games.isEmpty {
                                ForEach(gameModel.games, id: \.gameId) { game in
                                    
                                    // Navigation to specific game footage view
                                    NavigationLink(destination: CoachSpecificFootageView(game: game, team: selectedTeam)) {
                                        HStack (alignment: .top) {
                                            // Displaying the game preview image and information
                                            CustomUIFields.gameVideoPreviewStyle()
                                            
                                            VStack {
                                                // Game title and formatted start time
                                                Text(game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Text(formatStartTime(game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                // Indicating if the game is scheduled
                                                if let startTime = game.startTime {
                                                    let gameEndTime = startTime.addingTimeInterval(TimeInterval(game.duration))
                                                    if gameEndTime > Date() {
                                                        Text("Scheduled Game").font(.caption).bold().foregroundColor(Color.green).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("No saved footage.").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        // "Players" section: Displays players related to the team
                        Section(header:
                                    HStack {
                            Spacer()
                            Button{
                                addPlayerEnabled.toggle() // Toggles the Add Player form visibility
                            } label: {
                                // Open create new team form
                                HStack {
                                    Text("Add Player")
                                }.foregroundColor(Color.blue)
                            }
                        }){
                            // Looping through players related to the team
                            if !playerModel.players.isEmpty {
                                ForEach (playerModel.players, id: \.playerDocId) { player in
                                    // Navigation to specific player profile view
                                    NavigationLink(destination: CoachPlayerProfileView(playerDocId: player.playerDocId, userDocId: player.userDocId)) {
                                        HStack {
                                            // Displaying player name and status
                                            Text("\(player.firstName) \(player.lastName)")
                                            Spacer()
                                            Text(player.status).font(.footnote).foregroundStyle(.secondary).italic(true).padding(.trailing)
                                        }
                                    }
                                }
                            } else {
                                Text("No players found.").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
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
            .sheet(isPresented: $addPlayerEnabled, onDismiss: refreshData) {
                // Sheet to add a new player
                CoachAddPlayersView(team: selectedTeam) // passing the teamId as an argument
            }
            .sheet(isPresented: $addGameEnabled, onDismiss: refreshData) {
                // Sheet to add a new game
                CoachAddingGameView(team: selectedTeam) // Adding a new game
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
