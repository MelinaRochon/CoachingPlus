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
    //    @StateObject private var viewModel = AllTeamsViewModel()
    
    @StateObject private var teamModel = TeamModel()
    
    @State private var teams: [DBTeam]?
    @State private var showErrorAccessCode: Bool = false
    @State private var showError: Bool = false
 
    var body: some View {
        NavigationView {
            VStack {
                
                Divider() // This adds a divider after the title
//                if !teams.isEmpty {
                    List {
                        Section(header: HStack {
                            Text("My Teams") // Section header text
                            Spacer() // Push the button to the right
                        }) {
                            if let teams = teams {
                                if !teams.isEmpty {
                                    ForEach(teams, id: \.name) { team in
                                        NavigationLink(destination: PlayerMyTeamView(selectedTeam: team)
                                        ) {
                                            HStack {
                                                Image(systemName: "tshirt") // TO DO - Will need to change the team's logo in the future
                                                Text(team.name)
                                            }
                                        }
                                    }
                                } else {
                                    Text("No teams found.").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle()) // Optional: Make the list style more simple
//                }
                
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
                                        let tmpTeam = try await teamModel.validateTeamAccessCode(accessCode: groupCode)
                                        do {
                                            let newTeam = try await teamModel.addingPlayerToTeam(team: tmpTeam)
//                                            if var teams = teams {
                                            teams!.append(newTeam!)
//                                            }
                                            groupCode = "" // Reset input field
                                        } catch {
                                            print("Error when adding user to team. \(error)")
                                            showError = true
                                        }
                                        
                                        
                                    } catch {
                                        showErrorAccessCode = true
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
                                
                            }
                            .padding(.horizontal, 8)
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
                self.teams = try await teamModel.loadAllTeams()
            } catch {
                print("Error. Aborting... \(error)")
            }
        }
        .alert("Invalid access code entered", isPresented: $showErrorAccessCode) {
            Button("OK", role: .cancel) {
                groupCode = "" // Reset input field
            }
        }
        .alert("Error when trying to add team. Please try again later", isPresented: $showError) {
            Button("OK", role: .cancel) {
                groupCode = "" // Reset input field
            }
        }
    }
}

#Preview {
    PlayerAllTeamsView()
}
