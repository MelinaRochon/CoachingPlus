//
//  PlayerMyTeamView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/***This structure shows all the footages and players related to the selected team. **/
struct PlayerMyTeamView: View {
    @State private var selectedSegmentIndex = 0
    @State private var showAddPlayersSection = false
//    @State var teamName: String = "";
//    @State var teamId: String = "";
//    @State private var teamDocId: String = "";

//    @StateObject private var teamModel = TeamViewModel()
    /// View model for managing game data.
    @StateObject private var gameModel = GameModel()

    /// View model for managing player data.
    @StateObject private var playerModel = PlayerModel()
    
    /// The team whose settings are being viewed and modified.
    @State var selectedTeam: DBTeam

    /// Toggles visibility for the team settings view.
    @State private var isTeamSettingsEnabled: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                List {
//                        Section(header: HStack {
//                            Text("This week") // Section header text
//                        }) {
//                            ForEach(teamModel.games, id: \.gameId) { game in
//                                NavigationLink(destination: PlayerSpecificFootageView()) {
//                                    HStack (alignment: .top) {
//                                        Rectangle()
//                                            .fill(Color.gray.opacity(0.3))
//                                            .frame(width: 110, height: 60)
//                                            .cornerRadius(10)
//                                        
//                                        VStack {
//                                            Text(game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
//                                            
//                                            Text(game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
//                                        }
//                                    }
//                                }
//                            }
//                            
//                        }
                    Section(header:
                                HStack {
                        Text("Games")
                        Spacer()
                    }) {
                        // Looping through games related to the team
                        if !gameModel.games.isEmpty {
                            ForEach(gameModel.games, id: \.gameId) { game in
                                NavigationLink(destination: PlayerSpecificFootageView(game: game, team: selectedTeam)) {
                                    HStack (alignment: .top) {
                                        // Displaying the game preview image and information
                                        CustomUIFields.gameVideoPreviewStyle()
                                        
                                        VStack {
                                            Text(game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(formatStartTime(game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            if let startTime = game.startTime {
                                                let gameEndTime = startTime.addingTimeInterval(TimeInterval(game.duration))
                                                if gameEndTime > Date() {
                                                    // scheduled Game
                                                    //                                                    Button("Scheduled Game")
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

//            .task {
//                do {
//                    try await teamModel.loadTeam(teamId: teamId)
//                    self.teamDocId = teamModel.team?.id ?? ""
//                    try await teamModel.loadGames(teamId: teamId)
//                } catch {
//                    print("Error occured when loading the team. Aborting")
//                }
//            }
            
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
    PlayerMyTeamView(selectedTeam: team)
}
