//
//  SelectedScheduledGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import SwiftUI

struct SelectedScheduledGameView: View {
    @StateObject private var selecGameViewModel = SelectedGameModel()
    @StateObject private var recordingViewModel = FGVideoRecordingModel()
    
    @State var gameId: String // scheduled game id is passed when this view is called
    @State var teamDocId: String // scheduled game id is passed when this view is called
    
    @State private var hours: Int = 0;
    @State private var minutes: Int = 0;
    @State var recordReminder: Bool = false;
    @State private var canStartRecording: Bool = false // Controls start button visibility
    @State private var navigateToRecordingView = false // Track navigation state
    @State private var minsToStartGame: Int = 10; // How many minutes before a scheduled game can a coach start a recording
    @State private var selectedRecordingType: String = "Video" // Default selection
    
    var recordingOptions = [
        ("Video", "video.fill"),
        ("Audio Only", "waveform")
    ] // Dropdown choices with icons
    
    var body: some View {
        NavigationView {
            if let selectedGame = selecGameViewModel.selectedGame {
                VStack {
                    Text(selectedGame.game.title).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.bottom, 5).padding(.horizontal)
                    
                    // View the game details
                    VStack {
                        Text("Game Details").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                        
                        HStack {
                            Image(systemName: "person.2.fill").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(selectedGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(formatStartTime(selectedGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        HStack (alignment: .center) {
                            if let location = selectedGame.game.location {
                                // On click -> go to apple maps to that specific location
                                Button {
                                    if location.contains("Search Nearby") {
                                        let newLocation = location.components(separatedBy: "Search Nearby")
                                        
                                        if let url = URL(string: "maps://?q=\(newLocation.first)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                    } else {
                                        if let url = URL(string: "maps://?address=\(location)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "mappin.and.ellipse").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                                    Text(selectedGame.game.location ?? "None").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                }
                            }
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                        
                        HStack {
                            Image(systemName: "clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text("\(hours) h \(minutes) m").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                            // TO DO - If is not a scheduled game and there was a video recording, show the actual game duration!
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                    }.padding(.horizontal)
                    
                    if let userType = selecGameViewModel.userType {
                        
                        if (userType == "Coach") {
                            Divider()
                            
                            // View the game Settings
                            List {
                                Text("Game Settings").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                                HStack {
                                    Text("Duration")
                                    Spacer()
                                    Text("\(hours)h\(minutes)m").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("Time Before Feedback")
                                    Spacer()
                                    Text("\(selectedGame.game.timeBeforeFeedback) seconds").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("Time After Feedback")
                                    Spacer()
                                    Text("\(selectedGame.game.timeAfterFeedback) seconds").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Toggle("Recording Reminder:", isOn: $recordReminder).disabled(true)
                                if recordReminder == true {
                                    // show alert
                                    HStack {
                                        Text("Alert")
                                        Spacer()
                                        Text("\(selectedGame.game.scheduledTimeReminder) seconds").foregroundStyle(.secondary)
                                    }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.listStyle(.plain)
                        }
                    }
                    Spacer()
                }
            }
        }
        .task {
            do {
                try await selecGameViewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
                try await selecGameViewModel.getUserType()
                if let selectedGame = selecGameViewModel.selectedGame {
                    // Get the duration to be shown
                    let (dhours, dminutes) = convertSecondsToHoursMinutes(seconds: selectedGame.game.duration)
                    self.hours = dhours
                    self.minutes = dminutes
                    self.recordReminder = selectedGame.game.recordingReminder
                    
                    // Check if game starts within the next 10 minutes or is ongoing
                    if let startTime = selectedGame.game.startTime {
                        let currentTime = Date()
                        let timeDifference = startTime.timeIntervalSince(currentTime)
                        let gameEndTime = startTime.addingTimeInterval(TimeInterval(selectedGame.game.duration))
                        self.canStartRecording = (Int(timeDifference) <= minsToStartGame*60 && timeDifference >= 0) || (currentTime <= gameEndTime && currentTime >= startTime)
                        print(canStartRecording)
                    }
                }
                
            } catch {
                print("ERROR. \(error)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if canStartRecording {
                    Menu {
                        ForEach(recordingOptions, id: \ .0) { option, icon in
                            Button(action: {
                                selectedRecordingType = option
                                if selectedRecordingType == "Video" {
                                    startRecording()
                                }
                                navigateToRecordingView = true
                            }) {
                                Label(option, systemImage: icon)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Start").font(.subheadline)
                            Image(systemName: "waveform")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRecordingView) {
            CoachRecordingView().navigationBarBackButtonHidden(true)
        }
    }
    
    /** Function to start recording based on selection */
    private func startRecording() {
        guard let selectedGame = selecGameViewModel.selectedGame else {
            print("ERROR: No selected game available")
            return
        }
        
        let gameId = selectedGame.game.gameId
        let teamId = selectedGame.team.teamId
        
        Task {
            do {
                print("Starting \(selectedRecordingType) recording for Game ID: \(gameId), Team ID: \(teamId)")
                
                recordingViewModel.gameId = gameId
                try await recordingViewModel.createFGRecording(teamId: teamId)
                
                print("Recording successfully created in the database.")
                
            } catch {
                print("Error Creating Recording: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    SelectedScheduledGameView(gameId: "", teamDocId: "")
}
