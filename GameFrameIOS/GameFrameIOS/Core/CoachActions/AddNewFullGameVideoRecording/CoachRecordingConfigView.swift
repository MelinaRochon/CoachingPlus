//
//  CoachRecordingConfigView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation

import SwiftUI

/***
 A view that allows a coach to configure recording settings before starting a session.
 
 ### Features:
 - Select a team from a list.
 - Choose between video or audio recording.
 - Optionally enable Apple Watch for recording.
 - Ensures that a team is selected before proceeding.
 
 This form ensures that the necessary configurations are made before launching the recording process.
 */
struct CoachRecordingConfigView: View {
    // Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    // ViewModel to manage the list of teams
    @StateObject private var teamModel = TeamModel() // Fetches the list of teams

    
    // State variables for managing user selections and app state
    @State private var selectedTeamId: String? = nil // Holds the selected team ID
    @State private var selectedRecordingTypeLabel: String = "Video" // Default recording type is Video
    @State private var selectedAppleWatchUseLabel: Bool = false // Indicates if Apple Watch recording is enabled
    @State private var showNoTeamsAlert = false  // State to manage alert visibility
    @State private var navigateToCreateTeam = false // State variable for navigation
    
    @State private var teamsCoaching: [DBTeam]?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if let teams = teamsCoaching {
                        // Recording Settings Section
                        Section(header: Text("Recording Settings")) {
                            // Team Selection Picker
                            CustomPicker(
                                title: "Select Team",
                                options: teams.compactMap { $0.teamId },
                                displayText: { teamId in
                                    // Display the team name corresponding to the selected team ID
                                    teams.first(where: { $0.teamId == teamId })?.name ?? "Unknown Team"
                                },
                                selectedOption: Binding(
                                    get: { selectedTeamId ?? (teams.first?.teamId ?? "") }, // Default to the first team
                                    set: { selectedTeamId = $0 } // Update the selected team ID
                                )
                            )
                            
                            // Recording Type Picker (Video or Audio)
                            CustomPicker(
                                title: "Recording Typess",
                                options: AppData.recordingOptions, // List of recording options (e.g., "Video", "Audio Only")
                                displayText: { $0 }, // Display text for each option (directly using the string)
                                selectedOption: $selectedRecordingTypeLabel
                            ).pickerStyle(SegmentedPickerStyle())
                            
                            // Apple Watch Recording Toggle
                            Toggle("Use Apple Watch for Recording", isOn: $selectedAppleWatchUseLabel)
                        }
                    }
                }
                .navigationTitle("Start a Recording")
                .navigationBarTitleDisplayMode(.inline)
                
                // Button to start the recording (Video or Audio)
                if selectedRecordingTypeLabel == "Video" {
                    NavigationLink(destination: CoachRecordingView()) {
                        
                        // Custom Styled 'Start Video Recording' button
                        CustomUIFields.styledHStack(content: {
                            Text("Start Video Recording").font(.title2).bold()
                        }, background: selectedTeamId != nil ? .red : .gray)
                        
                    }.disabled(selectedTeamId == nil) // Disable button if no team is selected
                } else {
                    NavigationLink(destination: AudioRecordingView(teamId: selectedTeamId!, errorWrapper: .constant(nil))) {
                        
                        // Custom Styled 'Start Audio Recording' button
                        CustomUIFields.styledHStack(content: {
                            Text("Start Audio Recording").font(.title2).bold()
                        }, background: selectedTeamId != nil ? .red : .gray)
                        
                    }.disabled(selectedTeamId == nil) // Disable button if no team is selected
                }
                Spacer()
                
                NavigationLink(destination: CoachMainTabView(showLandingPageView: .constant(false)), isActive: $navigateToCreateTeam) {
                    EmptyView()
                }
            }.toolbar {
                // Cancel Button (Top Left)
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the view
                    }) {
                        HStack {
                            Text("Cancel")
                        }
                    }
                }
            }
            .alert("A team must be added first to add a new game.", isPresented: $showNoTeamsAlert) {
                Button(role: .cancel) {
                    navigateToCreateTeam = true // Trigger navigation after alert
                } label: {
                    Text("OK")
                }
            }
            .onAppear {
                loadTeams()
            }
        }
    }
    
    private func loadTeams() {
        Task {
            // Load Teams on View Appear
            do {
                self.teamsCoaching = try await teamModel.loadAllTeams()
                if let teamsCoaching = teamsCoaching {
                    if let firstTeam = teamsCoaching.first {
                        selectedTeamId = firstTeam.teamId
                    } else {
                        // No teams
                        showNoTeamsAlert = true
                    }
                }
            } catch {
                print("Error when loading the team information for the coachRecordingconfigView \(error)")
            }
        }
    }
}

#Preview {
    CoachRecordingConfigView()
}
