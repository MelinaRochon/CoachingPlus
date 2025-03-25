//
//  CoachMyTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***This structure shows all the footages and players related to the selected team. **/
struct CoachMyTeamView: View {
    @State private var selectedSegmentIndex = 0
    @State private var showAddPlayersSection = false
    let segmentTypes = ["Footage", "Players"]
    @State var teamNickname: String = "";
    @State var teamId: String = "";
    @State private var teamDocId: String = "";
    
    @State private var addPlayerEnabled = false;
    @State private var addGameEnabled = false;

    @StateObject private var teamModel = TeamViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
//                if let team = teamModel.team {
//                    Text(team.name).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.horizontal)
//                }
                
                Divider()
                
                Picker("Type of selection - Segmented", selection: $selectedSegmentIndex) {
                    ForEach(segmentTypes.indices, id: \.self) { i in
                        Text(self.segmentTypes[i])
                    }
                }.pickerStyle(.segmented)
                    .padding(.leading).padding(.trailing)//.padding(.bottom)
                
                List {
                    if (selectedSegmentIndex == 0) {
                        Section(header:
                                    HStack {
                            Text("Games")
                            Spacer()
                            Button{
                                addGameEnabled.toggle()
                            } label: {
                                // Open create new team form
                                HStack {
                                    Text("Add")
                                    Image(systemName: "calendar.badge.plus")
                                }.foregroundColor(Color.red)
                            }
                        }) {
                            ForEach(teamModel.games, id: \.gameId) { game in
                                NavigationLink(destination: CoachSpecificFootageView(gameId: game.gameId, teamDocId: teamDocId)) {
                                    HStack (alignment: .top) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            
                                            Text(game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
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
                        }
                    } else {
                        Section(header:
                                    HStack {
                            Spacer()
                            Button{
                                addPlayerEnabled.toggle()
                            } label: {
                                // Open create new team form
                                HStack {
                                    Text("Add")
                                    Image(systemName: "person.crop.circle.badge.plus")
                                }.foregroundColor(Color.red)
                            }
                        }){
                            ForEach (teamModel.players, id: \.playerDocId) { player in
                                NavigationLink(destination: CoachPlayerProfileView(playerDocId: player.playerDocId, userDocId: player.userDocId)) {
                                    HStack {
                                        Text("\(player.firstName) \(player.lastName)")
                                        Spacer()
                                        Text(player.status).font(.footnote).foregroundStyle(.secondary).italic(true).padding(.trailing)
                                    }
                                }
                            }
                        }
                    }
                    
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
            }
            .navigationTitle(Text(teamNickname))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                refreshData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Settings button - Coach can modify the settings of the team
                    Button(action: {
                        // TO DO - Add team settings here
                    }) {
                        Label("Settings", systemImage: "gear").foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $addPlayerEnabled, onDismiss: refreshData) {
                CoachAddPlayersView(teamId: teamId) // passing the teamId as an argument
            }
            .sheet(isPresented: $addGameEnabled, onDismiss: refreshData) {
                CoachAddingGameView(selectedTeamName: teamNickname, selectedTeamId: teamId) // Adding a new game
            }
        }
    }
    
    private func refreshData() {
        Task {
            do {
                try await teamModel.loadTeam(teamId: teamId)
                self.teamDocId = teamModel.team?.id ?? ""
                try await teamModel.loadGames(teamId: teamId)
                try await teamModel.loadPlayers(teamId: teamId)

            } catch {
                print("Error occurred when getting the team games data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CoachMyTeamView(teamNickname: "", teamId: "")
}
