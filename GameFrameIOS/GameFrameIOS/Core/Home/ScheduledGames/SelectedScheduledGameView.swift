//
//  SelectedScheduledGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import SwiftUI

/**
 `SelectedScheduledGameView` is a SwiftUI view that displays detailed information about a scheduled game.

 ## Features:
 - Displays the game title, team name, scheduled time, and location.
 - Allows navigation to Apple Maps to view the game location.
 - Shows game duration and feedback timing settings.
 - Coaches can view additional game settings such as feedback delays and recording reminders.
 - If the user is a coach and the game is about to start (within a predefined time) or is ongoing,
   a "Start Recording" button becomes available.
 - Supports both video and audio-only recording options.
 - Automatically determines if recording can begin based on the game’s start time.

 ## User Interactions:
 - **Coaches**: Can view game settings and start a recording.
 - **Players & Others**: Can only view game details.
 - Clicking on the game location will open Apple Maps with the given address.
 - Selecting a recording type (video/audio) initiates the recording process.

 ## Lifecycle:
 - Fetches user type on view load.
 - Determines whether the "Start Recording" button should be enabled.
 - Formats game duration into hours and minutes.
 - Displays an alert if an error occurs while fetching data.

 */
struct SelectedScheduledGameView: View {
    
    // MARK: - State Properties

    /// View model responsible for handling video/audio recording operations.
    @StateObject private var recordingViewModel = FGVideoRecordingModel()
    
    /// View model for fetching user details.
    @StateObject private var userModel = UserModel()

    /// Stores the game duration in hours.
    @State private var hours: Int = 0

    /// Stores the game duration in minutes.
    @State private var minutes: Int = 0
    
    /// Indicates whether the user has set a reminder for recording.
    @State private var recordReminder: Bool = false

    /// Determines whether the "Start Recording" button should be enabled.
    @State private var canStartRecording: Bool = false

    /// Controls navigation to the recording view.
    @State private var navigateToRecordingView = false

    /// Defines how many minutes before a scheduled game a coach can start recording.
    @State private var minsToStartGame: Int = 10

    /// Stores the selected recording type (e.g., "Video" or "Audio Only").
    @State private var selectedRecordingType: String = "Video"

    /// Stores the game information passed to this view.
    @State var selectedGame: HomeGameDTO?
    
    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: String? = nil
    
    // MARK: - View

    var body: some View {
        NavigationView {
            if let selectedGame = selectedGame {
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
                            
                            // TODO: If is not a scheduled game and there was a video recording, show the actual game duration!
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                    }.padding(.horizontal)
                    
                    if let userType = userType {
                        
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
                if userType == "Coach" {
                    if let selectedGame = selectedGame {
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
                }
            } catch {
                print("ERROR. \(error)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if canStartRecording {
                    Menu {
                        ForEach(AppData.recordingHomePageOptions, id: \ .0) { option, icon in
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
    
    
    // MARK: - Functions
    
    /**
     Function to start recording based on the selected game and recording type.
     Ensures that a game is selected before proceeding and then creates a recording entry in the database.
     */
    private func startRecording() {
        // Ensure there is a selected game before starting the recording
        guard let selectedGame = selectedGame else {
            print("ERROR: No selected game available")
            return
        }
        
        // Extract game and team IDs from the selected game
        let gameId = selectedGame.game.gameId
        let teamId = selectedGame.team.teamId
        
        // Perform the recording operation asynchronously
        Task {
            do {
                print("Starting \(selectedRecordingType) recording for Game ID: \(gameId), Team ID: \(teamId)")
                // Assign the game ID to the recording view model
                recordingViewModel.gameId = gameId
                
                // Attempt to create a recording entry in the database for the specified team
                try await recordingViewModel.createFGRecording(teamId: teamId)
                print("Recording successfully created in the database.")
            } catch {
                // Handle and log any errors that occur during recording creation
                print("Error Creating Recording: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    let game = HomeGameDTO(game: DBGame(gameId: "2oKD1iyUYXTFeWjelDz8", teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7"),
                           team: DBTeam(id: "6mpZlv7mGho5XaBN8Xcs", teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7", name: "Hornets", teamNickname: "HORNET", sport: "Soccer", gender: "Female", ageGrp: "U15", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"]))
    SelectedScheduledGameView(selectedGame: game)
}
