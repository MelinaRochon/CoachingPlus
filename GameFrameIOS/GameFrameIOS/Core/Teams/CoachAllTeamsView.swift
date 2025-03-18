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
    @StateObject private var viewModel = AllTeamsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Divider() // This adds a divider after the title
                
                if !viewModel.teams.isEmpty {
                    List {
                        Section(header: HStack {
                            Text("My Teams") // Section header text
                            Spacer() // Push the button to the right
//                            Button(action: addTeam) {
//                                // Open create new team form
//                                Text("Add +")
//                            }
                            //Button(action: {
                                NavigationLink(destination: CoachCreateTeamView()){
                                    // Open create new team form
                                    Text("Add +")
                                }.navigationBarBackButtonHidden()
                            //}) {
                                
                            //}
                        }) {
                            
                            ForEach(viewModel.teams, id: \.name) { team in
                                NavigationLink(destination: CoachMyTeamView(teamName: team.name))
                                {
                                    HStack {
                                        Image(systemName: "tshirt") // TO DO - Will need to change the team's logo in the future
                                        Text(team.name)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                }
            }
            .navigationTitle(Text("Teams"))
            .task {
                do {
                    try await viewModel.loadAllTeams()
                    
                } catch {
                    print("Error. Aborting... \(error)")
                }
            }
        }
//        .fullScreenCover(isPresented: $showCreateNewTeam) {
//            CoachCreateTeamView()
//        }
    }
    
    private func addTeam() {
        withAnimation {
            showCreateNewTeam.toggle()
        }
    }
}

#Preview {
    CoachAllTeamsView()
}
