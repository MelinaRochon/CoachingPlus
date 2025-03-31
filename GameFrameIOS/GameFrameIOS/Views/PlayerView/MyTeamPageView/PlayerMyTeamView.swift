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
    @State var teamName: String = "";
    @State var teamId: String = "";
    @State private var teamDocId: String = "";

    @StateObject private var teamModel = TeamViewModel()
    
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
                        ForEach(teamModel.games, id: \.gameId) { game in
                            NavigationLink(destination: PlayerSpecificFootageView(gameId: game.gameId, teamDocId: teamDocId)) {
                                HStack (alignment: .top) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 110, height: 60)
                                        .cornerRadius(10)
                                    
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
                    }
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
            }.navigationTitle(Text(teamName))
            .navigationBarTitleDisplayMode(.large)
            .task {
                do {
                    try await teamModel.loadTeam(teamId: teamId)
                    self.teamDocId = teamModel.team?.id ?? ""
                    try await teamModel.loadGames(teamId: teamId)
                } catch {
                    print("Error occured when loading the team. Aborting")
                }
            }
            
        }
    }
}

#Preview {
    PlayerMyTeamView(teamName: "", teamId: "")
}
