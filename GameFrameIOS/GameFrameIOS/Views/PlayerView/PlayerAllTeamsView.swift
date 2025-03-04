//
//  PlayerAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerAllTeamsView: View {
    @State var team: Team;
    @State private var showTextField = false // Controls visibility of text field
    @State private var groupCode: String = "" // Stores entered text
    @State private var showInitialView = true // Tracks if "Have a Group Code?" and "Enter Code" should be shown

    var body: some View {
        NavigationView {
            VStack {
                
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: HStack {
                        Text("My Teams") // Section header text
                        
                        Spacer() // Push the button to the right
                    }) {
                        NavigationLink(destination: PlayerMyTeamView(teamName: "Team 1")
                                       //                            .navigationBarBackButtonHidden(true)
                        ) {
                            HStack {
                                Image(systemName: "tshirt")
                                Text("Team 1")
                            }
                        }
                        
                        NavigationLink(destination: PlayerMyTeamView(teamName: "Team 2")
                                       //                            .navigationBarBackButtonHidden(true)
                        ) {
                            HStack {
                                Image(systemName: "tshirt")
                                Text("Team 2")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                //.background(Color.white) // Set background color to white for the List
                
                
                
                VStack(spacing: 8) {
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
                                    Text("Enter Code")
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(40)
                            }
                            .padding()
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Show text field & submit button when `showTextField` is true
                    if showTextField {
                        HStack {
                            TextField("Your Code", text: $groupCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 16)
                                .cornerRadius(40)
                            
                            Button(action: {
                                withAnimation {
                                    showTextField = false  // Hide input field
                                    showInitialView = true // Bring back initial text & button
                                    groupCode = "" // Reset input field
                                }
                                print("Submitted Code: \(groupCode)") // Handle submission
                            }) {
                                Text("Submit")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(40)
                            }
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity) // Smooth fade-in/out effect
                    }
                }
                .padding(.bottom, 86)
                
            }.transaction { $0.animation = nil }
        }
        //.background(Color.white)
        .navigationTitle(Text("Teams"))
        .transaction { $0.animation = nil } // Prevents title animation
    }
}

#Preview {
    PlayerAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
}
