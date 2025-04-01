//
//  CoachTeamSettingsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI

/// A view that allows the coach to view and manage the settings of a specific team.
struct CoachTeamSettingsView: View {
    /// The model for managing team data, passed as an observed object to track changes.
//    @ObservedObject var teamModel: TeamModel
    
    /// Temporary storage for the list of players associated with the team.
    @State var players: [User_Status] = []
    
    /// Environment value to dismiss the current view and return to the previous one.
    @Environment(\.dismiss) var dismiss // Allows the user to go back

    /// State to track whether the "Copied!" message should be shown when the access code is copied.
    @State private var showCopiedMessage = false // To show "Copied!" message

    @State var team: DBTeam
    
    var body: some View {
        // Navigation view that allows for navigation between views and displaying a toolbar.
        NavigationView {
            VStack {
                // Check if the team data is available and unwrap it.
                    // Team Name Title
                    Text(team.name)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    // List displaying the various team settings (nickname, age group, sport, gender, access code).
                    List {
                        // Section Title
                        Text("Team Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Team Nickname
                        HStack {
                            Text("Nickname")
                            Spacer()
                            Text(team.teamNickname)
                                .foregroundColor(.secondary)
                        }

                        // Age Group
                        HStack {
                            Text("Age Group")
                            Spacer()
                            Text(team.ageGrp)
                                .foregroundColor(.secondary)
                        }

                        // Sport
                        HStack {
                            Text("Sport")
                            Spacer()
                            Text(team.sport)
                                .foregroundColor(.secondary)
                        }

                        // Gender
                        HStack {
                            Text("Gender")
                            Spacer()
                            Text(team.gender.capitalized)
                                .foregroundColor(.secondary)
                        }

                        // Access Code with Copy Button & Tooltip
                        HStack {
                            Text("Access Code")
                            Spacer()
                            Text(team.accessCode ?? "N/A")
                                .foregroundColor(.secondary).padding(.trailing, 5)
                            
                            // Copy Button
                            Button(action: {
                                UIPasteboard.general.string = team.accessCode ?? ""
                                showCopiedMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showCopiedMessage = false
                                }
                            }) {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section(header: Text("Players")) {
                            if !players.isEmpty {
                                ForEach(players, id: \.playerDocId) { player in
                                    HStack {
                                        Image(systemName: "person")
                                            .foregroundColor(.blue)
                                        
                                        Text("\(player.firstName) \(player.lastName)")
                                    }
                                }
                            } else {
                                Text("No players found.").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    // Show "Copied!" message
                    if showCopiedMessage {
                        Text("Copied!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .transition(.opacity)
                            .padding(.top, 5)
                    }
                    
                    Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done").font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    CoachTeamSettingsView(players: [], team: team)
}
