//
//  SelectedRecentGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import SwiftUI

/** This file defines the `SelectedRecentGameView` view, which displays detailed information
  about a selected recent game, such as the game title, team name, and start time.
  It uses the `selectedGame` to pass the game data and displays it within a navigation view.
  The user can also start a recording via the toolbar button.
 */

/// This view displays details about a selected recent game including the game title, team name, and start time.
struct SelectedRecentGameView: View {
    
    // MARK: - State Properties

    /// View model responsible for handling video recording logic
    @StateObject private var recordingViewModel = FGVideoRecordingModel()

    /// Stores the currently selected game (if any)
    @State var selectedGame: HomeGameDTO?

    /// Determines whether the start recording button should be visible
    @State private var canStartRecording: Bool = false

    /// Stores the selected recording type (e.g., "Video" by default)
    @State private var selectedRecordingType: String = "Video"

    /// Tracks whether the user should navigate to the recording view
    @State private var navigateToRecordingView = false

    /// Stores the selected hours for a time-related input (e.g., recording duration)
    @State private var hours: Int = 0

    /// Stores the selected minutes for a time-related input (e.g., recording duration)
    @State private var minutes: Int = 0
    
    @State var userType: String
    
    // MARK: - View

    var body: some View {
        NavigationView {
            VStack {
                if let selectedGame = selectedGame {
                    VStack {
                        Text(selectedGame.game.title).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.bottom, 5).padding(.horizontal)
                        
                        // View game details
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
                        
                        if !canStartRecording {
                            VStack {
                                if userType == "Coach" {
                                    NavigationLink(destination: CoachSpecificFootageView(gameId: selectedGame.game.gameId, teamDocId: selectedGame.team.id)) {
                                        navigationLabel()
                                    }

                                } else {
                                    NavigationLink(destination: PlayerSpecificFootageView(gameId: selectedGame.game.gameId, teamDocId: selectedGame.team.id)) {
                                        navigationLabel()
                                    }
                                }
                            }.padding(.horizontal).padding(.top)
                        }
                    }
                }
            
                Spacer()
            }
        }
        .task {
            if let selectedGame = selectedGame {
                // Get the duration to be shown
                let (dhours, dminutes) = convertSecondsToHoursMinutes(seconds: selectedGame.game.duration)
                self.hours = dhours
                self.minutes = dminutes

                if let startTime = selectedGame.game.startTime {
                    let currentTime = Date()
                    let timeDifference = startTime.timeIntervalSince(currentTime)
                    let gameEndTime = startTime.addingTimeInterval(TimeInterval(selectedGame.game.duration))
                    self.canStartRecording = (currentTime <= gameEndTime && currentTime >= startTime)
                    print(canStartRecording)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if canStartRecording {
                    // Start the recording
                    Menu {
                        ForEach(AppData.recordingHomePageOptions, id: \ .0) { option, icon in
                            Button(action: {
                                selectedRecordingType = option
                                if selectedRecordingType == "Video" {
                                    // startRecording()
                                }
                                navigateToRecordingView = true
                            }) {
                                Label(option, systemImage: icon)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Record").font(.subheadline)
                            Image(systemName: "record.circle")
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
    
    
    /// Creates a custom navigation label with text and an arrow icon for navigation.
    /// - Returns: A `HStack` containing a text label and a right arrow icon, styled with padding, background, and shadow.
    private func navigationLabel() -> some View {
        HStack {
            Text("View Game Footage").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline).foregroundColor(.red)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.red)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
    }
}


#Preview {
    // For testing purpose
    let date: Date = Date(timeIntervalSince1970: 150000)
    let game = HomeGameDTO(game: DBGame(gameId: "2oKD1iyUYXTFeWjelDz8", title: "Test vs Done", duration: 1400, scheduledTimeReminder: 10, startTime: date, timeBeforeFeedback: 10, timeAfterFeedback: 10, recordingReminder: true, teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7"),
                           team: DBTeam(id: "6mpZlv7mGho5XaBN8Xcs", teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7", name: "Hornets", teamNickname: "HORNET", sport: "Soccer", gender: "Female", ageGrp: "U15", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"]))
    SelectedRecentGameView(selectedGame: game, userType: "Player")
}
