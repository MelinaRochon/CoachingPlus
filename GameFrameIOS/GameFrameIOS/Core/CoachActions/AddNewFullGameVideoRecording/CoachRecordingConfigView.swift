//
//  CoachRecordingConfigView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation

import SwiftUI

/***
 This structure is the 'Coach Recording Configuration' form. It allows the coach to configure recording settings before starting a session.
 The coach can select a team, choose the recording type, and enable Apple Watch recording.
 
 Note: The form is designed to ensure a team is selected before proceeding.
 */
struct CoachRecordingConfigView: View {
    @Environment(\.dismiss) var dismiss // To go back to the main tab view
    
    @StateObject private var recordingViewModel = AddNewFGVideoRecordingModel()
    @StateObject private var gameViewModel = AddNewGameModel()
    @StateObject private var teamsViewModel = AllTeamsViewModel()
    
    @State private var currentTimestamp: Date = Date() // Stores the current time
    @State private var showCreateNewTeam = false
    @State private var selectedTeamId: String? = nil
    @State private var selectedRecordingTypeLabel: String = "Video"
    @State private var selectedAppleWatchUseLabel: Bool = false
    @State private var navigateToRecordingView = false // Navigation control
    
    let recordingOptions = ["Video", "Audio Only"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Recording Settings")) {
                        Picker("Select Team", selection: $selectedTeamId) {
                            ForEach(teamsViewModel.teams, id: \.teamId) { team in
                                HStack {
                                    Image(systemName: selectedTeamId == team.teamId ? "checkmark.circle.fill" : "tshirt")
                                        .foregroundColor(selectedTeamId == team.teamId ? .blue : .gray)
                                    Text(team.name)
                                }
                                .tag(team.teamId as String?)
                            }
                        }
                        
                        Picker("Recording Type", selection: $selectedRecordingTypeLabel) {
                            ForEach(recordingOptions, id: \ .self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Toggle("Use Apple Watch for Recording", isOn: $selectedAppleWatchUseLabel)
                    }
                }
                .navigationTitle("Start a Recording")
                .navigationBarTitleDisplayMode(.inline)
                
                Spacer()
                
                Button(action: {
                    gameViewModel.teamId = selectedTeamId!
                    Task{
                        do {
                            if selectedTeamId != nil {
                                let gameId = try await gameViewModel.addUnknownGame()
                                if (selectedRecordingTypeLabel == "Video"){
                                    recordingViewModel.gameId = gameId!
                                    let canWeDismiss = try await recordingViewModel.createFGRecording(teamId: selectedTeamId)
                                }
                                navigateToRecordingView = true // Navigate after game creation
                            }
                        } catch {
                            print("Error Creating Game")
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Start Recording")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTeamId != nil ? Color.blue : Color.gray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(selectedTeamId == nil)
                
                NavigationLink(destination: CoachRecordingView().navigationBarBackButtonHidden(true), isActive: $navigateToRecordingView) { EmptyView() }

            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack {
                            Text("Cancel")
                        }
                    }
                }
            }
            .task {
                if selectedTeamId == nil {
                    do {
                        
                        try await teamsViewModel.loadAllTeams()
                        if let firstTeam = teamsViewModel.teams.first {
                            selectedTeamId = firstTeam.teamId
                        }
                    } catch {
                        print("Error when loading the team information for the coachRecordingconfigView \(error)")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCreateNewTeam) {
            CoachCreateTeamView()
        }
    }
}

#Preview {
    CoachRecordingConfigView()
}
