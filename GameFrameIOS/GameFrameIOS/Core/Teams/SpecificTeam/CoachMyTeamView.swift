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
    @State var teamName: String = "";
    @State var teamId: String = "";
    @State private var teamDocId: String = "";
    
    @State private var addPlayerEnabled = false;
    @StateObject private var teamModel = TeamViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                Picker("Type of selection - Segmented", selection: $selectedSegmentIndex) {
                    ForEach(segmentTypes.indices, id: \.self) { i in
                        Text(self.segmentTypes[i])
                    }
                }.pickerStyle(.segmented)
                    .padding(.leading).padding(.trailing).padding(.bottom)
                
                List {
                    if (selectedSegmentIndex == 0) {
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
                                Text("Add +")
                            }
                            //.navigationBarBackButtonHidden()
                        }){
                            ForEach (teamModel.players, id: \.playerDocId) { player in
                                //if let userId = player.userId {
                                NavigationLink(destination: CoachPlayerProfileView(playerDocId: player.playerDocId, userDocId: player.userDocId)) {
                                    HStack {
                                        Text("\(player.firstName) \(player.lastName)")
                                        Spacer()
                                        Text(player.status).font(.footnote).foregroundStyle(.secondary).italic(true).padding(.trailing)

                                    }
                                }

                                //}
                            }
                        }
                    }
                    
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                
            }
            .navigationTitle(Text(teamName))
            .navigationBarTitleDisplayMode(.large)
            .task {
                do {
                    try await teamModel.loadTeam(name: teamName, teamId: teamId)
                    self.teamDocId = teamModel.team!.id
                } catch {
                    print("Error occured when loading the team. Aborting")
                }
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
            }.fullScreenCover(isPresented: $addPlayerEnabled) {
                CoachAddPlayersView(teamId: teamId) // passing the teamId as an argument
            }
        }
    }
}

#Preview {
    CoachMyTeamView(teamName: "", teamId: "")
}
