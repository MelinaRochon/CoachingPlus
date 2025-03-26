//
//  PlayerAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerAllTeamsView: View {
    @State private var showTextField = false // Controls visibility of text field
    @State private var groupCode: String = "" // Stores entered text
    @State private var showInitialView = true // Tracks if "Have a Group Code?" and "Enter Code" should be shown
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
                        }) {
                            ForEach(viewModel.teams, id: \.name) { team in
                                NavigationLink(destination: PlayerMyTeamView(teamName: team.name, teamId: team.teamId)
                                ) {
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
                
                Spacer()
                VStack {
                    // Show initial text & button if `showInitialView` is true
                    if showInitialView {
                        HStack {
                            Text("Have a Group Code?")
                                .font(.footnote)
                            
                            Button(action: {
                                withAnimation {
                                    showTextField = true  // Show input field
                                    showInitialView = false // Hide initial view
                                }
                            }) {
                                HStack {
                                    Text("Enter Code").font(.subheadline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(30)
                            }
                            .padding()
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Show text field & submit button when `showTextField` is true
                    if showTextField {
                        HStack {
                            TextField("Your Code", text: $groupCode)
                                .padding(.horizontal, 8)
                                .cornerRadius(40).frame(width: 190)
                                .frame(height: 40)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.black).autocapitalization(.none)

                            
                            Button(action: {
                                withAnimation {
                                    showTextField = false  // Hide input field
                                    showInitialView = true // Bring back initial text & button
                                }
                                print("Submitted Code: \(groupCode)") // Handle submission
                                // check accesscode entered
                                Task {
                                    do {
                                        try await viewModel.validateAccessCode(accessCode: groupCode)
                                        groupCode = "" // Reset input field

                                    } catch {
                                        print("Error when submitting a team's access code. \(error)")
                                    }
                                }
                                
                            }) {
                                HStack {
                                    Text("Submit").font(.subheadline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(30)
                                
                            }.padding(.horizontal, 8)
                        }
                        .padding()
                        .transition(.opacity) // Smooth fade-in/out effect
                    }
                }
                .padding(.bottom, 85)                
            }.transaction { $0.animation = nil }
        }
        .navigationTitle(Text("Teams"))
        .transaction { $0.animation = nil } // Prevents title animation
        .task {
            do {
                try await viewModel.loadAllTeams()
                
            } catch {
                print("Error. Aborting... \(error)")
            }
        }
    }
}

#Preview {
    PlayerAllTeamsView()
}
