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
    
    // MARK: - State Properties

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss

    /// ViewModel to manage the list of teams
    @StateObject private var teamModel = TeamModel() // Fetches the list of teams

    /// State variables for managing user selections and app state
    /// This variable stores the ID of the team the user selects. It's optional to account for the case when no team is selected.
    @State private var selectedTeamId: String? = nil // Holds the selected team ID

    /// This variable holds the label for the selected recording type. It defaults to "Video", but the user can select a different type (e.g., Audio).
    @State private var selectedRecordingTypeLabel: String = "Video" // Default recording type is Video

    /// This variable tracks whether Apple Watch recording is enabled. It is a Boolean, where `true` means recording is enabled and `false` means it's not.
    @State private var selectedAppleWatchUseLabel: Bool = false // Indicates if Apple Watch recording is enabled

    /// This variable controls whether or not an alert should be displayed to the user. It is set to `true` if no teams are available, and `false` by default.
    @State private var showNoTeamsAlert = false  // State to manage alert visibility
    
    /// This variable is used to manage navigation to the "Create Team" view. When set to `true`, the view navigates to the team creation screen.
    @State private var navigateToCreateTeam = false // State variable for navigation

    /// This variable holds the list of teams the user is coaching. It's optional because it can be nil when no teams are fetched or assigned to the user.
    @State private var teamsCoaching: [DBTeam]?
    
    
    // MARK: - View

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
                                title: "Recording Types",
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
                
                // Uncomment when video recording is available!
                
//                if selectedRecordingTypeLabel == "Video" {
//                    NavigationLink(destination: CoachRecordingView()) {
//                        
//                        // Custom Styled 'Start Video Recording' button
//                        CustomUIFields.styledHStack(content: {
//                            Text("Start Video Recording").font(.title2).bold()
//                        }, background: selectedTeamId != nil ? .red : .gray)
//                        
//                    }.disabled(selectedTeamId == nil) // Disable button if no team is selected
//                } else
                if (selectedRecordingTypeLabel == "Audio Only"){
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
    
    
    // MARK: - Private functions

    /// Loads the list of teams the user is coaching and sets the default selection.
    private func loadTeams() {
        Task {
            do {
                // Fetch all teams the user is coaching asynchronously
                self.teamsCoaching = try await teamModel.loadAllTeams()
                
                if let teamsCoaching = teamsCoaching {
                    if let firstTeam = teamsCoaching.first {
                        // If there are teams available, select the first team by default
                        selectedTeamId = firstTeam.teamId
                    } else {
                        // If no teams are available, show an alert to inform the user
                        showNoTeamsAlert = true
                    }
                }
            } catch {
                // Handle errors that occur while loading teams
                print("Error when loading the team information for the CoachRecordingConfigView: \(error)")
            }
        }
    }
}

#Preview {
    CoachRecordingConfigView()
}
