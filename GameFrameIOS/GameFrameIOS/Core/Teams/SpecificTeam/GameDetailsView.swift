//
//  GameDetailsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI


/// A view displaying the details of a specific game, including its schedule, duration, location, and settings.
///
/// ## Features:
/// - Displays game title, team name, scheduled time, and location.
/// - Opens Apple Maps to the game’s location when clicked.
/// - Shows game duration and related settings.
/// - Coaches can view additional game settings such as feedback timing and recording reminders.
struct GameDetailsView: View {
    
    /// Environment property to dismiss the view and return to the previous screen.
    @Environment(\.dismiss) var dismiss

    /// Stores the duration of the game in hours.
    @State private var hours: Int = 0

    /// Stores the duration of the game in minutes.
    @State private var minutes: Int = 0

    /// Indicates whether a recording reminder is enabled for the game.
    @State private var recordReminder: Bool = false

    /// The selected game whose details are being displayed.
    @State var selectedGame: DBGame

    /// The team participating in the game.
    @State var team: DBTeam

    /// The user type (e.g., "Coach", "Player"), determining access to certain settings.
    @State var userType: String
    
    @State private var gameName: String = ""
    
    @State private var isEditing: Bool = false
    
    @State private var gameModel = GameModel()

    var body: some View {
        
        NavigationView {
            VStack {
                // Displays the game title in a large, bold font.
                if !isEditing {
                    Text(selectedGame.title).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.bottom, 5).padding(.horizontal)
                }
                    
                    // View the game details
                VStack {
                    Text("Game Details").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                    if !isEditing {
                        HStack {
                            Image(systemName: "person.2.fill").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        // Displays the scheduled game time.
                        HStack {
                            Image(systemName: "calendar.badge.clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(formatStartTime(selectedGame.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        // Displays the game location with a button to open Apple Maps.
                        HStack (alignment: .center) {
                            if let location = selectedGame.location {
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
                                    Text(selectedGame.location ?? "None").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                }
                            }
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                        
                        // Displays the duration of the game.
                        HStack {
                            Image(systemName: "clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text("\(hours) h \(minutes) m").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                            // TODO: - If is not a scheduled game and there was a video recording, show the actual game duration!
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                    } else {
                        HStack {
                            Text("Game Title")
                            Spacer()
                            TextField("Game Title", text: $gameName).foregroundStyle(.primary).multilineTextAlignment(.trailing)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }.padding(.horizontal)
                
                
                if (userType == "Coach" && !isEditing) {
                    Divider()
                    // View the game Settings
                    List {
                        Text("Game Settings").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(hours) h \(minutes) m").foregroundStyle(.secondary)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Text("Time Before Feedback")
                            Spacer()
                            Text("\(selectedGame.timeBeforeFeedback) seconds").foregroundStyle(.secondary)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Text("Time After Feedback")
                            Spacer()
                            Text("\(selectedGame.timeAfterFeedback) seconds").foregroundStyle(.secondary)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        Toggle("Recording Reminder:", isOn: $recordReminder).disabled(true)
                        if recordReminder == true {
                            // show alert
                            HStack {
                                Text("Alert")
                                Spacer()
                                Text("\(selectedGame.scheduledTimeReminder) seconds").foregroundStyle(.secondary)
                            }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }.listStyle(.plain)
                }
                Spacer()
            }
            .toolbar {
                if userType == "Coach" {
                    ToolbarItem(placement: .topBarLeading) {
                        if !isEditing {
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Text("Edit").font(.subheadline)
                            }
                            
                        } else {
                            Button {
                                withAnimation {
                                    isEditing = false
                                }
                                gameName = selectedGame.title
                            } label: {
                                Text("Cancel").font(.subheadline)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing && userType == "Coach" {
                        Button {
                            withAnimation {
                                isEditing = false
                            }
                            
                            saveGameName()
                            selectedGame.title = gameName
                        } label: {
                            Text("Save").font(.subheadline)
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done").font(.subheadline)
                        }
                    }
                }
            }
        }
        .task {
            // Convert the game duration from seconds to hours and minutes.
            let (dhours, dminutes) = convertSecondsToHoursMinutes(seconds: selectedGame.duration)
            self.hours = dhours
            self.minutes = dminutes
            
            // Set the recording reminder flag.
            self.recordReminder = selectedGame.recordingReminder
            gameName = selectedGame.title
        }
    }
    
    
    
    private func saveGameName() {
        Task {
            do {
                try await gameModel.updateGameTitle(gameId: selectedGame.gameId, teamDocId: team.id, title: gameName)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    
    GameDetailsView(selectedGame: game, team: team, userType: "Player")
}
