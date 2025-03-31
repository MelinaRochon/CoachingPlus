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
//    @State private var showAlert = false

    @StateObject private var viewModel = AllTeamsViewModel()
    @State private var showCreateTeam: Bool = false // Toggle to create a team
    var body: some View {
        NavigationStack {
            VStack {
                Divider() // This adds a divider after the title
                
                    List {
                        Section(header: HStack {
                            Text("My Teams") // Section header text
                            Spacer() // Push the button to the right
                            Button{
                                showCreateTeam.toggle()
                            } label: {
                                Text("Add +")
                            }
                        }) {
                            if !viewModel.teams.isEmpty {
                                ForEach(viewModel.teams, id: \.name) { team in
                                    NavigationLink(destination: CoachMyTeamView(teamNickname: team.nickname, teamId: team.teamId, teamModel: TeamModel()))
                                    {
                                        HStack {
                                            Image(systemName: "tshirt") // TO DO - Will need to change the team's logo in the future
                                            Text(team.name)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle()) // Optional: Make the list style more simple
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
        .sheet(isPresented: $showCreateTeam, onDismiss: refreshTeams) {
            CoachCreateTeamView()
//                .gesture(DragGesture().onChanged { _ in
//                    showAlert = true
//                })
//                .alert("Drag Detected", isPresented: $showAlert) {
//                    Button("OK", role: .cancel) { }
//                }
        }

    }
    
    private func refreshTeams() {
        Task {
            do {
                try await viewModel.loadAllTeams()
                
            } catch {
                print("Error occured when refreshing teams. Aborting... \(error)")
            }
        }
    }
}

#Preview {
    CoachAllTeamsView()
}
