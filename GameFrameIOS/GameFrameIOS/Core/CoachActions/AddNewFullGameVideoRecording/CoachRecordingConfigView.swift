//
//  CoachRecordingConfigView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import SwiftUI
import GameFrameIOSShared

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

    @Binding var showLandingPageView: Bool

    /// ViewModel to manage the list of teams
    @StateObject private var teamModel = TeamModel() // Fetches the list of teams
    @EnvironmentObject private var dependencies: DependencyContainer

    /// State variables for managing user selections and app state
    /// This variable stores the ID of the team the user selects. It's optional to account for the case when no team is selected.
    @State private var selectedTeamId: String? = nil // Holds the selected team ID

    /// This variable holds the label for the selected recording type. It defaults to "Video", but the user can select a different type (e.g., Audio).
    @State private var selectedRecordingTypeLabel: String = "Video"

    /// This variable tracks whether Apple Watch recording is enabled. It is a Boolean, where `true` means recording is enabled and `false` means it's not.
    @State private var selectedAppleWatchUseLabel: Bool = false // Indicates if Apple Watch recording is enabled

    /// This variable controls whether or not an alert should be displayed to the user. It is set to `true` if no teams are available, and `false` by default.
    @State private var showNoTeamsAlert = false  // State to manage alert visibility
    
    /// This variable is used to manage navigation to the "Create Team" view. When set to `true`, the view navigates to the team creation screen.
    @State private var navigateToCreateTeam = false // State variable for navigation

    /// This variable holds the list of teams the user is coaching. It's optional because it can be nil when no teams are fetched or assigned to the user.
    @State private var teamsCoaching: [DBTeam]?
    
    /// To dismiss the view when a game is done saving
    @State private var savedRecording: Bool = false
    
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
                
                if (selectedRecordingTypeLabel == "Audio Only"){
                    if let tid = selectedTeamId { // ✅ avoid force unwrap
                        NavigationLink(
                            destination: AudioRecordingView(
                                gameId: "",
                                teamId: tid,
                                navigateToHome: $savedRecording,
                                showNavigationUI: true
                            )
                        ) {
                            // Custom Styled 'Start Audio Recording' button
                            CustomUIFields.styledHStack(content: {
                                Text("Start Audio Recording").font(.title2).bold()
                            }, background: .black)
                        }
                    } else {
                        // Disabled look when no team is selected
                        CustomUIFields.styledHStack(content: {
                            Text("Start Audio Recording").font(.title2).bold()
                        }, background: .gray)
                        .disabled(true)
                    }
                } else if (selectedRecordingTypeLabel == "Video") {
                    if let tid = selectedTeamId {
                        NavigationLink(
                            destination: VideoRecordingView(
                                gameId: "", // new game to be created
                                teamId: tid,
                                savedRecording: $savedRecording
                            )
                        ) {
                            CustomUIFields.styledHStack(content: {
                                Text("Start Video Recording").font(.title2).bold()
                            }, background: .black)
                        }
                    } else {
                        // Disabled look when no team is selected
                        CustomUIFields.styledHStack(content: {
                            Text("Start Video Recording").font(.title2).bold()
                        }, background: .gray)
                        .disabled(true)
                    }
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
                teamModel.setDependencies(dependencies)
            }
            .onChange(of: savedRecording) {
                // Video recording of game was saved and added to database
                // Dismiss this view
                dismiss()
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
    CoachRecordingConfigView(showLandingPageView: .constant(false))
}
