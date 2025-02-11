//
//  PlayerAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerAllTeamsView: View {
    @State private var showCreateNewTeam = false // Switch to coach recording page
    @State var team: Team;
    var body: some View {
        NavigationView {
            VStack {
                
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: HStack {
                        Text("My Teams") // Section header text
                            
                        Spacer() // Push the button to the right
                        Button(action: addTeam) {
                            
                             // Open create new team form
                            Text("Add +")
                        }
                    }) {
                        NavigationLink(destination: CoachMyTeamView(teamName: "Team 1").navigationBarBackButtonHidden(true)) {
                            HStack {
                                Image(systemName: "tshirt")
                                Text("Team 1")
                            }
                        }
                        
                        NavigationLink(destination: CoachMyTeamView(teamName: "Team 2").navigationBarBackButtonHidden(true)) {
                            HStack {
                                Image(systemName: "tshirt")
                                Text("Team 2")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
                
            }
            .background(Color.white)
            .navigationTitle(Text("Teams"))
            
        }.fullScreenCover(isPresented: $showCreateNewTeam) {
            CoachCreateTeamView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
        }
    }
    
    private func addTeam() {
        withAnimation {
            showCreateNewTeam.toggle()
        }
    }
}

#Preview {
    PlayerAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
}
