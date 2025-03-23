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
    @State private var selectedTeam: String? = nil
    @State private var selectedRecordingTypeLabel: String = "Video"
    @State private var selectedAppleWatchUseLabel: Bool = false
    
    let teamOptions = ["Team 1", "Team 2", "Team 3"]
    let recordingOptions = ["Video", "Audio Only"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Recording Settings")) {
//                        Picker("Select Team", selection: $selectedTeam) {
//                            ForEach(teamsViewModel.teams, id: \.teamId) { team in
//                                HStack {
//                                    Image(systemName: selectedTeam == team ? "checkmark.circle.fill" : "tshirt")
//                                        .foregroundColor(selectedTeam == team ? .blue : .gray)
//                                    Text(team)
//                                }
//                                .tag(team as String?)
//                            }
//                        }
                        
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
                //.navigationBarTitleDisplayMode(.inline)
                
                Spacer()
                
                Button(action: {
                    currentTimestamp = Date()
                    
                    gameViewModel.title = "Unknown Game"
                    gameViewModel.duration = 0
                    gameViewModel.scheduledTimeReminder = 0
                    gameViewModel.startTime = currentTimestamp
                    gameViewModel.timeBeforeFeedback = 0
                    gameViewModel.timeAfterFeedback = 0
                    gameViewModel.recordingReminder = false
                    gameViewModel.teamId = "A4013599-0BAE-495A-9FB2-342B67C071F6"
                    
                    Task{
                        do {
                            let canWeDismiss: () = try await gameViewModel.addNewGame()
                        } catch {
                            print("Error Creating Game")
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    gameViewModel.test()
                    
                    if (selectedRecordingTypeLabel == "Video"){
                        recordingViewModel.startTime = currentTimestamp
                        
                        Task{
                            do {
                                let canWeDismiss = try await recordingViewModel.createFGRecording(gameId: "FXy9YF11Gt1HgQLbbDiZ")
                            } catch {
                                print("Error Creating Recording")
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        recordingViewModel.test()
                    }
                    
                }) {
                    Text("Start Recording")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTeam != nil ? Color.blue : Color.gray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(selectedTeam == nil)
                
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
        }
        .fullScreenCover(isPresented: $showCreateNewTeam) {
            CoachCreateTeamView()
        }
    }
}

#Preview {
    CoachRecordingConfigView()
}
