//
//  GameDetailsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI
import GameFrameIOSShared


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
    @State var userType: UserType
    
    @State private var gameName: String = ""
    
    @State private var isEditing: Bool = false
    
    @State private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    @State private var removeGame: Bool = false
    @Binding var dismissOnRemove: Bool
    
    @Binding var gameTitle: String

    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    // Displays the game title in a large, bold font.
                    if !isEditing {
                        Text(selectedGame.title)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                            .padding(.horizontal, 15)
                        
                        // View the game details
                        VStack {
                            
                            CustomUIFields.customDivider("Game Details")
                                .padding(.top, 15)
                            
                            label(text: team.name, systemImage: "person.2.fill", textStyle: .secondary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            
                            // Displays the scheduled game time.
                            label(text: formatStartTime(selectedGame.startTime), systemImage: "calendar.badge.clock")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            
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
                                        label(text: location, systemImage: "mappin.and.ellipse")
                                    }
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                            
                            // Displays the duration of the game.
                            label(text: "\(hours) h \(minutes) m", systemImage: "clock")
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            // TODO: - If is not a scheduled game and there was a video recording, show the actual game duration!
                        }
                        .padding(.horizontal, 15)
                        
                        if userType == .coach {
                            // View the game Settings
                            VStack {
                                CustomUIFields.customDivider("Game Settings")
                                    .padding(.top, 15)
                                
                                gameSettingsSection
                            }
                            .padding(.horizontal, 15)
                        }
                        Spacer()
                    } else {
                        listOfGameDetail
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button  {
                        withAnimation {
                            isEditing = false
                        }
                        gameName = selectedGame.title
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }

                if userType == .coach {
                    
                    if isEditing {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save", systemImage: "checkmark") {
                                withAnimation {
                                    isEditing = false
                                }
                                saveGameName()
                                selectedGame.title = gameName
                            }
                            .disabled(gameName == selectedGame.title || gameName.isEmpty)
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Text("Edit")
                            }
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
        .onAppear {
            gameModel.setDependencies(dependencies)
        }
    }
    
    
    var gameSettingsSection: some View {
        VStack {
            HStack {
                Text("Time Before Feedback")
                Spacer()
                Text("\(selectedGame.timeBeforeFeedback) seconds")
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                Text("Time After Feedback")
                Spacer()
                Text("\(selectedGame.timeAfterFeedback) seconds")
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 5)
            
            Divider()
            
            Toggle("Recording Reminder:", isOn: $recordReminder)
                .foregroundStyle(.primary)
                .disabled(true)
            
            Divider()
            
            if recordReminder == true {
                // show alert
                HStack {
                    Text("Alert")
                    Spacer()
                    Text("\(selectedGame.scheduledTimeReminder) seconds")
                }
                .foregroundStyle(.primary)
                .padding(.vertical, 5)
                
                Divider()
            }
        }
        .font(.callout)
    }
    
    
    var listOfGameDetail: some View {
        VStack {
            CustomUIFields.customTitle("Editing Game Details", subTitle: "Please update your game title below.")
            
            VStack {
                CustomTextField(label: "Game Title", text: $gameName)
                CustomTextField(label: "Team Name", text: $team.name, disabled: true)
                CustomText(label: "Start Time", text: formatStartTime(selectedGame.startTime), isRequired: true, disabled: true)
                if let location = selectedGame.location {
                    CustomText(label: "Game Location", text: location, disabled: true)
                }
                
                let duration = "\(hours) h \(minutes) m"
                CustomText(label: "Game Duration", text: duration, isRequired: true, disabled: true)
                   
                CustomUIFields.customDivider("Game Settings")
                    .padding(.top, 15)

                gameSettingsSection
            }
            .padding(.horizontal, 15)
        }
    }
    
    
    private func saveGameName() {
        Task {
            do {
                gameTitle = gameName
                try await gameModel.updateGameTitle(gameId: selectedGame.gameId, teamDocId: team.id, title: gameName)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    /// A reusable SwiftUI view that displays a horizontal label with a red SF Symbol icon and text.
    ///
    /// - Parameters:
    ///   - text: The text to display next to the icon.
    ///   - systemImage: The name of the SF Symbol to use as the icon.
    ///
    /// - Returns: A `View` containing an `HStack` with a red icon and a label.
    @ViewBuilder
    private func label(text: String, systemImage: String, textStyle: Color = .black) -> some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .foregroundStyle(.red)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.subheadline)
                .foregroundColor(textStyle)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    @Previewable @State var title = "Hello, World!"
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    
    GameDetailsView(selectedGame: game, team: team, userType: .player, dismissOnRemove: .constant(false), gameTitle: $title)
}

extension GameDetailsView: GameSaveSettingsProtocol {
    var saveGameSettingsIfValid: Bool {
        return gameName != "" && !gameName.isEmpty
        && gameName != selectedGame.title
    }
}
