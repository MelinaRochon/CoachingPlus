//
//  CoachAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***
 This structure shows all the Teams listed on the coache's profile. The coach can create a new team along with accessing the desired team through
 this page.
 The player also has a similar Teams page, showing all teams that they are registered in.
 */
struct CoachAllTeamsView: View {
    @State private var showCreateNewTeam = false // Switch to coach recording page
    @State var team: Team;
    var body: some View {
        NavigationStack {
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
                //.background(Color.white) // Set background color to white for the List
                
            }
            //.background(Color.white)
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
    CoachAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
}
