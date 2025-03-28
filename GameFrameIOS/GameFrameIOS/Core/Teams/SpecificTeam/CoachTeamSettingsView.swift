//
//  CoachTeamSettingsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI

struct CoachTeamSettingsView: View {
    @StateObject private var viewModel = TeamViewModel()
    @State var teamId: String // The ID of the team being viewed
    @Environment(\.dismiss) var dismiss // Allows the user to go back

    @State private var showCopiedMessage = false // To show "Copied!" message

    var body: some View {
        NavigationView {
            VStack {
                if let team = viewModel.team {
                    
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
                    
                    // Team Details List
                    List {
                        // Section Title
                        Text("Team Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Team Nickname
                        HStack {
                            Text("Nickname")
                            Spacer()
                            Text(team.teamNickname ?? "N/A")
                                .foregroundColor(.secondary)
                        }

                        // Age Group
                        HStack {
                            Text("Age Group")
                            Spacer()
                            Text(team.ageGrp ?? "N/A")
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
                                .foregroundColor(.secondary)
                            
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
        .task {
            do {
                try await viewModel.loadTeam(teamId: teamId)
            } catch {
                print("Error loading team settings: \(error)")
            }
        }
    }
}

#Preview {
    CoachTeamSettingsView(teamId: "mockTeamId")
}
