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
    //@State private var path = NavigationPath() // Stores the navigation history
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                List {
                        Section(header: HStack {
                            Text("This week") // Section header text
                        }) {
                            NavigationLink(destination: PlayerSpecificFootageView()) {
                                HStack (alignment: .top) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 110, height: 60)
                                        .cornerRadius(10)
                                    
                                    VStack {
                                        Text("Game A vs C").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            
                        }
                        
                        Section(header: HStack {
                            Text("Last 30 days") // Section header text
                        }) {
                            HStack (alignment: .top) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game A vs B").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            HStack (alignment: .top) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                    //.background(Color.white) // Set background color to white for the List
                  
            }.navigationTitle(Text(teamName))
            
            
        }
    }
}

#Preview {
    PlayerMyTeamView(teamName: "Team 1")
}
