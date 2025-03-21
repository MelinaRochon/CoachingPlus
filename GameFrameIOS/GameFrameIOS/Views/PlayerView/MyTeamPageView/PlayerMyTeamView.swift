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

    @StateObject private var teamModel = TeamViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                List {
                        Section(header: HStack {
                            Text("This week") // Section header text
                        }) {
                            ForEach(teamModel.games, id: \.gameId) { game in
                                NavigationLink(destination: PlayerSpecificFootageView()) {
                                    HStack (alignment: .top) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            Text(game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
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
                    try await teamModel.loadTeam(name: teamName, teamId: teamId)
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
