//
//  SelectedScheduledGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import SwiftUI
import GameFrameIOSShared

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
    
    /// View model responsible for handling game operations.
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

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
    @State private var navigateToAudioRecordingView = false

    /// Defines how many minutes before a scheduled game a coach can start recording.
    @State private var minsToStartGame: Int = 10

    /// Stores the selected recording type (e.g., "Video" or "Audio Only").
    @State private var selectedRecordingType: String = "Video"

    /// Stores the game information passed to this view.
    @State var selectedGame: HomeGameDTO?
    
    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: UserType? = nil

    @State private var isEditing: Bool = false
    
    /// Stores the title or name of the game (e.g., match name or event title).
    @State private var title: String = ""
        
    /// Represents the duration of the game in seconds. It defines how long the game lasts.
    @State private var duration: Int = 0
    
    /// Stores the location of the game. It could contain the title (name) and subtitle (address or further details) of the location.
    @State private var location: LocationResult?
    
    @State private var gameLocation: String?
    
    /// Represents the scheduled time reminder in minutes before the game starts. Used to alert coaches/players before the match.
    @State private var scheduledTimeReminder: Int = 0
    
    /// Represents the start time of the game. Initially set to the current date and time.
    @State private var startTime: Date = Date()
    
    /// Represents the time (in seconds) before feedback is collected during or after the game./
    @State private var timeBeforeFeedback: Int = 0
    
    /// Represents the time (in seconds) after feedback collection is complete, possibly for cooldown or post-game activities.
    @State private var timeAfterFeedback: Int = 0
    
    /// A boolean that indicates whether the recording reminder is enabled for the game. It can toggle to alert the user about the recording status.
    @State private var recordingReminder: Bool = false
                    
    /// Variables for storing the selected time options for reminders and feedback
    @State private var selectedTimeLabel = "5 minutes before"  // User-friendly label
    @State private var feedbackBeforeTimeLabel = "10 seconds"
    @State private var feedbackAfterTimeLabel = "10 seconds"
    
    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @State private var confirmationDeleteGame: Bool = false
        
    /// To dismiss the view when a game is done saving
    @State private var savedRecording: Bool = false

    // MARK: - View

    var body: some View {
        NavigationStack {
            if let selectedGame = selectedGame {
                VStack {
                    if !isEditing {
                        Text(title).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.bottom, 5).padding(.horizontal)
                        
                        // View the game details
                        VStack {
                            Text("Game Details").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                            label(text: selectedGame.team.name, systemImage: "person.2.fill").foregroundStyle(.secondary)
                            label(text: formatStartTime(startTime), systemImage: "calendar.badge.clock")

                            HStack (alignment: .center) {
                                if let location = gameLocation {
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
                                        Text(location).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                    }
                                }
                            }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                            
                            label(text: "\(hours) h \(minutes) m", systemImage: "clock") // TODO: If is not a scheduled game and there was a video recording, show the actual game duration!
                            
                        }.padding(.horizontal)
                        Divider()
                        
                        if let userType = userType {
                            if (userType == .coach) {
                                // View the game Settings
                                List {
                                    Text("Game Settings").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                                    HStack {
                                        Text("Duration")
                                        Spacer()
                                        Text("\(hours) h \(minutes) m").foregroundStyle(.secondary)
                                    }.font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    HStack {
                                        Text("Time Before Feedback")
                                        Spacer()
                                        Text("\(timeBeforeFeedback) seconds").foregroundStyle(.secondary)
                                    }.font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    HStack {
                                        Text("Time After Feedback")
                                        Spacer()
                                        Text("\(timeAfterFeedback) seconds").foregroundStyle(.secondary)
                                    }.font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    Toggle("Recording Reminder:", isOn: $recordingReminder).font(.subheadline).disabled(true)
                                    if recordingReminder == true {
                                        // show alert
                                        HStack {
                                            Text("Alert")
                                            Spacer()
                                            Text("\(selectedTimeLabel)").foregroundStyle(.secondary)
                                        }.font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }.listStyle(.plain)
                            }
                        }
                    }
                    Spacer()
                }
                .fullScreenCover(isPresented: $isEditing) {
                    NavigationView {
                        EditScheduledGameView(
                            onCancel: {
                                resetValues()
                                location = convertToLocation(locationString: selectedGame.game.location)
                                gameLocation = getFinalLocation()
                                withAnimation {
                                    isEditing = false
                                }
                            },
                            onSave: {
                                savingScheduledGame()
                                withAnimation {
                                    isEditing = false
                                }
                            },
                            onDeleteGame: {
                                Task {
                                    do {
                                        isEditing.toggle()
                                        try await gameModel.removeGame(
                                            gameId: selectedGame.game.gameId,
                                            teamDocId: selectedGame.team.id,
                                            teamId: selectedGame.team.teamId
                                        )
                                        dismiss()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            },
                            selectedGame: selectedGame,
                            location: $location,
                            title: $title,
                            startTime: $startTime,
                            hours: $hours,
                            minutes: $minutes,
                            recordingReminder: $recordReminder,
                            selectedTimeLabel: $selectedTimeLabel,
                            feedbackBeforeTimeLabel: $feedbackBeforeTimeLabel,
                            feedbackAfterTimeLabel: $feedbackAfterTimeLabel
                        )
                    }
                }
                .onAppear {
                    gameModel.setDependencies(dependencies)
                    recordingViewModel.setDependencies(dependencies)
                }
            }
        }
        .task {
            do {
                if let selectedGame = selectedGame {
                    // Check if game starts within the next 10 minutes or is ongoing
                    updateCanStartRecording(gameStartTime: selectedGame.game.startTime, gameDuration: selectedGame.game.duration)
                    
                    if location == nil {
                        location = convertToLocation(locationString: selectedGame.game.location)
                    }
                    gameLocation = getFinalLocation()
                }
                resetValues()
            } catch {
                print("ERROR. \(error)")
            }
        }
        .toolbar(content: {
            if userType == .coach {
                ToolbarItem(placement: .topBarTrailing) {
                    if !isEditing {
                        Button {
                            withAnimation {
                                isEditing = true
                            }
                        } label: {
                            Text("Edit")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if canStartRecording {
                        Menu {
                            ForEach(AppData.recordingHomePageOptions, id: \ .0) { option, icon in
                                Button(action: {
                                    selectedRecordingType = option
                                    if selectedRecordingType == "Video" {
                                        navigateToRecordingView = true
                                    } else {
                                        navigateToAudioRecordingView = true
                                    }
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
        })
        .fullScreenCover(isPresented: $navigateToRecordingView) {
            if let game = selectedGame {
                VideoRecordingView(
                    gameId: game.game.gameId,
                    teamId: game.team.teamId,
                    savedRecording: $savedRecording,
                    isUsingWatch: false // TODO: Add a toggle when adding a scheduled game to use watch
                )
            }
        }
        .fullScreenCover(isPresented: $navigateToAudioRecordingView) {
            if let game = selectedGame {
                AudioRecordingView(
                    gameId: game.game.gameId,
                    teamId: game.team.teamId,
                    navigateToHome: $savedRecording,
                    isUsingWatch: false, // TODO: Add a toggle when adding a scheduled game to use watch
                    showNavigationUI: true
                )
            }
        }
        .onChange(of: savedRecording) {
            // Video recording of game was saved and added to database
            // Dismiss this view
            dismiss()
        }
    }
    
    private func updateCanStartRecording(gameStartTime: Date?, gameDuration: Int?) {
        if let duration = gameDuration, let startTime = gameStartTime {
            // Check if game starts within the next 10 minutes or is ongoing
            let currentTime = Date()
            let timeDifference = startTime.timeIntervalSince(currentTime)
            let gameEndTime = startTime.addingTimeInterval(TimeInterval(duration))
            self.canStartRecording = (Int(timeDifference) <= minsToStartGame*60 && timeDifference >= 0) || (currentTime <= gameEndTime && currentTime >= startTime)
            
            print(canStartRecording)
        }
    }
    
    
    // MARK: - Functions
    
    /// Resets form fields back to the values of the currently selected game.
    private func resetValues() {
        if let selectedGame = selectedGame {
            title = selectedGame.game.title
            startTime = selectedGame.game.startTime ?? Date()
            duration = selectedGame.game.duration
            
            // Get the duration of the game
            let (dhours, dminutes) = convertSecondsToHoursMinutes(seconds: selectedGame.game.duration)
            self.hours = dhours
            self.minutes = dminutes
            self.recordingReminder = selectedGame.game.recordingReminder
            
            if userType == .coach {
                // Retrieve the feedback time settings
                timeBeforeFeedback = selectedGame.game.timeBeforeFeedback
                timeAfterFeedback = selectedGame.game.timeAfterFeedback
                scheduledTimeReminder = selectedGame.game.scheduledTimeReminder
                
                feedbackBeforeTimeLabel = "\(timeBeforeFeedback) seconds"
                if let selectedFeedbackBeforeOption = AppData.feedbackBeforeTimeOptions.first(where: { $0.0 == feedbackBeforeTimeLabel }) {
                    timeBeforeFeedback = selectedFeedbackBeforeOption.1  // Store the database-friendly value
                }
                
                feedbackAfterTimeLabel = "\(timeAfterFeedback) seconds"
                if let selectedFeedbackAfterOption = AppData.feedbackAfterTimeOptions.first(where: { $0.0 == feedbackAfterTimeLabel }) {
                    timeAfterFeedback = selectedFeedbackAfterOption.1  // Store the database-friendly value
                }
                
                selectedTimeLabel = labelForReminder(scheduledTimeReminder)
                
                if (recordingReminder == true) {
                    // Retrieve the get recording reminder alert value, if there is one
                    if let selectedOption = AppData.timeOptions.first(where: { $0.0 == selectedTimeLabel }) {
                        scheduledTimeReminder = selectedOption.1  // Store the database-friendly value
                    }
                } else {
                    scheduledTimeReminder = 0
                }
            }
        }
    }
    
    
    /// Saves updates to a scheduled game by comparing current form values
    /// with the existing game and only sending changes to the database.
    private func savingScheduledGame() {
        Task {
            do {
                if var selectedGame = selectedGame {
                    
                    // Retrieve the duration
                    duration = ((3600 * hours) + (60 * minutes))
                    
                    let finalLocation = getFinalLocation()
                    var gameTitle: String? = title
                    var gameStartTime: Date? = startTime
                    var gameDuration: Int? = ((3600 * hours) + (60 * minutes))
                    if let selectedFeedbackBeforeOption = AppData.feedbackBeforeTimeOptions.first(where: { $0.0 == feedbackBeforeTimeLabel }) {
                        timeBeforeFeedback = selectedFeedbackBeforeOption.1  // Store the database-friendly value
                    }
                    var gameTimeBeforeFeedback: Int? = timeBeforeFeedback

                    if let selectedFeedbackAfterOption = AppData.feedbackAfterTimeOptions.first(where: { $0.0 == feedbackAfterTimeLabel }) {
                        timeAfterFeedback = selectedFeedbackAfterOption.1  // Store the database-friendly value
                    }
                    var gameTimeAfterFeedback: Int? = timeAfterFeedback
                    
                    if (recordingReminder == true) {
                        // Retrieve the get recording reminder alert value, if there is one
                        if let selectedOption = AppData.timeOptions.first(where: { $0.0 == selectedTimeLabel }) {
                            scheduledTimeReminder = selectedOption.1  // Store the database-friendly value
                            
                        }
                    } else {
                        scheduledTimeReminder = 0
                    }
                    var gameRecordingReminder: Bool? = recordingReminder
                    var gameScheduledTimeReminder: Int? = scheduledTimeReminder
                    
                    var gameLocationString: String? = finalLocation

                    if title == selectedGame.game.title {
                        gameTitle = nil
                    } else {
                        selectedGame.game.title = title
                    }
                    
                    if startTime == selectedGame.game.startTime {
                        gameStartTime = nil
                    } else {
                        selectedGame.game.startTime = startTime
                    }
                    
                    updateCanStartRecording(gameStartTime: gameStartTime, gameDuration: gameDuration)
                    
                    if duration == selectedGame.game.duration {
                        gameDuration = nil
                    } else {
                        selectedGame.game.duration = duration
                    }
                    
                    if timeBeforeFeedback == selectedGame.game.timeBeforeFeedback {
                        gameTimeBeforeFeedback = nil
                    } else {
                        selectedGame.game.timeBeforeFeedback = timeBeforeFeedback
                    }
                    
                    if timeAfterFeedback == selectedGame.game.timeAfterFeedback {
                        gameTimeAfterFeedback = nil
                    } else {
                        selectedGame.game.timeAfterFeedback = timeAfterFeedback
                    }
                    
                    if recordingReminder == selectedGame.game.recordingReminder {
                        gameRecordingReminder = nil
                    } else {
                        selectedGame.game.recordingReminder = recordingReminder
                    }
                    
                    if let finalLocation = finalLocation {
                        if let selectedGameLocation = selectedGame.game.location {
                            if finalLocation.trimmingCharacters(in: .whitespacesAndNewlines) == selectedGameLocation.trimmingCharacters(in: .whitespacesAndNewlines) {
                                gameLocationString = nil
                            } else {
                                gameLocation = finalLocation
                                location = convertToLocation(locationString: finalLocation)
                                selectedGame.game.location = finalLocation
                            }
                        } else {
                            gameLocation = finalLocation
                            location = convertToLocation(locationString: finalLocation)
                            selectedGame.game.location = finalLocation
                        }
                    } else {
                        gameLocationString = nil
                    }

                    if scheduledTimeReminder == selectedGame.game.scheduledTimeReminder {
                        gameScheduledTimeReminder = nil
                    } else {
                        selectedGame.game.scheduledTimeReminder = scheduledTimeReminder
                    }
                    
                    try await gameModel.updateScheduledGameSettings(
                        gameId: selectedGame.game.gameId,
                        teamDocId: selectedGame.team.id,
                        title: gameTitle,
                        startTime: gameStartTime,
                        duration: gameDuration,
                        timeBeforeFeedback: gameTimeBeforeFeedback,
                        timeAfterFeedback: gameTimeAfterFeedback,
                        recordingReminder: gameRecordingReminder,
                        location: gameLocationString,
                        scheduledTimeReminder: gameScheduledTimeReminder
                    )
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
        
    
    /// Returns the finalized location as a string, combining the title and subtitle of the location.
    ///
    /// - If the `location` is `nil`, prints a message indicating no location was entered and returns `nil`.
    /// - If the `location` exists, concatenates its `title` and `subtitle` to create a full location string and returns it.
    ///
    /// - Returns: A `String?` representing the finalized location, or `nil` if no location is available.
    func getFinalLocation() -> String? {
        if location == nil {
            print("No location entered. Proceeding...")
            return nil
        } else {
            // finalise the location
            return (location!.title + " " + location!.subtitle)
        }
    }
    
    
    /// Converts a raw location string into a `LocationResult`.
    /// - If the string contains "Search Nearby", the part before it becomes the title and the subtitle is "Search Nearby".
    /// - Otherwise, the whole string is the title and the subtitle is empty.
    /// - Returns `nil` if the input is `nil`.
    private func convertToLocation(locationString: String?) -> LocationResult? {
        if let finalLocation = locationString {
            if let range = finalLocation.range(of: "Search Nearby") {
                let title = String(finalLocation[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                return LocationResult(title: title, subtitle: "Search Nearby")
            }
            return LocationResult(title: finalLocation, subtitle: "")
        } else {
            return nil
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
    private func label(text: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .foregroundStyle(.red)
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading) // Default text color
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

#Preview {
    let game = HomeGameDTO(id: "2oKD1iyUYXTFeWjelDz8", game: DBGame(gameId: "2oKD1iyUYXTFeWjelDz8", teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7"),
                           team: DBTeam(id: "6mpZlv7mGho5XaBN8Xcs", teamId: "E152008E-1833-4D1A-A7CF-4BB3229351B7", name: "Hornets", teamNickname: "HORNET", sport: "Soccer", gender: "Female", ageGrp: "U15", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"]))
    SelectedScheduledGameView(selectedGame: game)
}



struct EditScheduledGameView: View {
    var onCancel: () -> Void
    var onSave: () -> Void
    var onDeleteGame: () -> Void
    var selectedGame: HomeGameDTO
    
    @Binding var location: LocationResult?
    @Binding var title: String
    @Binding var startTime: Date
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var recordingReminder: Bool
                    
    @Binding var selectedTimeLabel: String
    @Binding var feedbackBeforeTimeLabel: String
    @Binding var feedbackAfterTimeLabel: String

    @State private var confirmationDeleteGame: Bool = false

    var body: some View {
        coachEditScheduledGame
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: onSave)
                }
            }
    }
    
    var coachEditScheduledGame: some View {
        List {
            Section(header: Text("Game Details")) {
                
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("Title", text: $title).multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Team Name")
                    Spacer()
                    Text(selectedGame.team.name).multilineTextAlignment(.trailing)
                }
                .foregroundStyle(.secondary)
                .disabled(true)
                
                HStack {
                    Text("Location")
                    NavigationLink(destination: LocationView(location: $location), label: {
                        HStack {
                            Spacer()
                            if let location = location {
                                Text("\(location.title) \(location.subtitle)").multilineTextAlignment(.trailing)
                            } else {
                                Text("Enter location").foregroundStyle(.secondary)
                            }
                        }
                    }).isDetailLink(true)
                }
            }
            
            // Section for scheduled time, including start time and duration
            Section (header: Text("Scheduled Time")) {
                HStack {
                    DatePicker("Start", selection: $startTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                HStack {
                    Text("Duration")
                    Spacer()
                    // Picker for selecting the number of hours for game duration
                    Picker("", selection: $hours){
                        ForEach(0..<13, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }.pickerStyle(.wheel).frame(width: 60, height: 100)
                        .clipped()
                    Text("hours").bold()
                    
                    // Picker for selecting the number of minutes for game duration
                    Picker("", selection: $minutes){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }.pickerStyle(.wheel).frame(width: 60, height: 100)
                    Text("min").bold()
                }
            }
            
            Section(header: Text("Feedback Settings")) {
                // CustomPicker for selecting feedback before the event
                CustomPicker(
                    title: "Before Feedback",
                    options: AppData.feedbackBeforeTimeOptions.map { $0.0 },
                    displayText: { $0 },
                    selectedOption: $feedbackBeforeTimeLabel
                )
                
                // CustomPicker for selecting feedback after the event
                CustomPicker(
                    title: "After Feedback",
                    options: AppData.feedbackAfterTimeOptions.map { $0.0 },
                    displayText: { $0 },
                    selectedOption: $feedbackAfterTimeLabel
                )
            }
            
            // Section for reminder settings
            Section(footer:
                        Text("Will send recording reminder at the scheduled time.")
            ){
                Toggle("Get Recording Reminder", isOn: $recordingReminder)
                if (recordingReminder == true) {
                    // CustomPicker for selecting reminder time before the event
                    CustomPicker(
                        title: "Reminder",
                        options: AppData.timeOptions.map { $0.0 },
                        displayText: { $0 },
                        selectedOption: $selectedTimeLabel
                    )
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    confirmationDeleteGame.toggle()
                }) {
                    Text("Delete scheduled game")
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this scheduled game?",
                isPresented: $confirmationDeleteGame,
                titleVisibility: .visible
            ) {
                //                    Button(role: .destructive, action: {
//                                        Task {
//                                            do {
//                                                isEditing.toggle()
//                                                try await gameModel.removeGame(gameId: selectedGame.game.gameId, teamDocId: selectedGame.team.id, teamId: selectedGame.team.teamId)
//                                                dismiss()
//                                            } catch {
//                                                print(error.localizedDescription)
//                                            }
//                                        }
                //                    }) {
                //                        Text("Delete")
                //                    }
                Button(role: .destructive, action: onDeleteGame) {
                    Text("Delete")
                }
                
            }
        }
    }
    
}
