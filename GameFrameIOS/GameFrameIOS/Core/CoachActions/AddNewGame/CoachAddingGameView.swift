//
//  CoachAddingGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import Firebase

/**
 `CoachAddingGameView` is a SwiftUI view that allows soccer coaches to create a new game event.
 
 ## Features:
 - **Game Details:** Input a title, select a team, and specify the location.
 - **Scheduled Time:** Choose a start time and set a game duration.
 - **Feedback Settings:** Configure automatic feedback reminders before and after key events.
 - **Recording Reminder:** Enable or disable recording notifications before the game.
 - **Firestore Integration:** Saves the created game event to the Firebase Firestore database.
 
 This view interacts with `AddNewGameModel`, which handles data storage, team retrieval, and database operations.
 It includes form-based inputs and custom pickers for a streamlined user experience.
 
 ## Navigation:
 - **Back to Teams Page:** Users can dismiss the view with a cancel button.
 - **Save and Proceed:** Users can finalize game details and save them to the database.
 
 This view is designed with state management using `@StateObject` for handling game data and `@Environment(\.dismiss)`
 for navigation control.
 */
struct CoachAddingGameView: View {
    /// The model for managing team data, passed as an observed object to track changes.
    @ObservedObject var teamModel: TeamModel

    /// ViewModel for managing the data related to adding a new game
    @StateObject private var gameModel = GameModel()
    
    /// Holds the unique identifier for the team associated with the game.
    @State private var teamId = ""

    /// Stores the title or name of the game (e.g., match name or event title).
    @State private var title = ""
    
    /// Represents the duration of the game in seconds. It defines how long the game lasts.
    @State private var duration: Int = 0
    
    /// Stores the location of the game. It could contain the title (name) and subtitle (address or further details) of the location.
    @State private var location: LocationResult?
    
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
    
    /// Environment variable to dismiss the view and return to the previous screen
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    
    /// Variables to store the hours and minutes for duration
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    /// Options for reminder time before the event
    let timeOptions = [("At time of event", 0), ("5 minutes before", 5), ("10 minutes before", 10), ("15 minutes before", 15), ("30 minutes before", 30), ("1 hour before", 60)]
    
    /// Options for feedback time before the event
    let feedbackBeforeTimeOptions = [("None", 0), ("5 seconds", 5), ("10 seconds", 10), ("15 seconds", 15), ("20 seconds", 20), ("30 seconds", 30)]
    
    /// Options for feedback time after the event
    let feedbackAfterTimeOptions = [("None", 0), ("5 seconds", 5), ("10 seconds", 10), ("15 seconds", 15), ("20 seconds", 20), ("30 seconds", 30)]
        
    /// Variables for storing the selected time options for reminders and feedback
    @State private var selectedTimeLabel = "5 minutes before"  // User-friendly label
    @State private var feedbackBeforeTimeLabel = "10 seconds"
    @State private var feedbackAfterTimeLabel = "10 seconds"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Form {
                    
                    // Section for the game title and selecting team
                    Section {
                        TextField("Title", text: $title).multilineTextAlignment(.leading)
                        HStack {
                            Text("Team")
                            Spacer()
                            if let team = teamModel.team {
                                Text(team.teamNickname).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                            }
                        }
                        
                        // Section for selecting the game location
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
                    
                    // Section for feedback settings
                    Section(header: Text("Feedback Settings")) {
                        // CustomPicker for selecting feedback before the event
                        CustomPicker(
                            title: "Before Feedback",
                            options: feedbackBeforeTimeOptions.map { $0.0 },
                            displayText: { $0 },
                            selectedOption: $feedbackBeforeTimeLabel
                        )
                        
                        // CustomPicker for selecting feedback after the event
                        CustomPicker(
                            title: "After Feedback",
                            options: feedbackAfterTimeOptions.map { $0.0 },
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
                                options: timeOptions.map { $0.0 },
                                displayText: { $0 },
                                selectedOption: $selectedTimeLabel
                            )
                        }
                    }
                }
            }.toolbar {
                // Cancel button in the toolbar to dismiss the view (Top Left)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        Text("Cancel")
                    }
                }
                
                // Done button in the toolbar to save the game data
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { /* Action will need to be added -> complete team form */
                        // Save the selected settings for the game
                        if (recordingReminder == true) {
                            // Retrieve the get recording reminder alert value, if there is one
                            if let selectedOption = timeOptions.first(where: { $0.0 == selectedTimeLabel }) {
                                scheduledTimeReminder = selectedOption.1  // Store the database-friendly value
                                
                            }
                        } else {
                            scheduledTimeReminder = 0
                        }
                        
                        // Retrieve the feedback time settings
                        if let selectedFeedbackBeforeOption = feedbackBeforeTimeOptions.first(where: { $0.0 == feedbackBeforeTimeLabel }) {
                            timeBeforeFeedback = selectedFeedbackBeforeOption.1  // Store the database-friendly value
                        }
                        
                        if let selectedFeedbackAfterOption = feedbackAfterTimeOptions.first(where: { $0.0 == feedbackAfterTimeLabel }) {
                            timeAfterFeedback = selectedFeedbackAfterOption.1  // Store the database-friendly value
                        }
                        
                        // Retrieve the duration
                        duration = ((3600 * hours) + (60 * minutes))
                        
                        if let team = teamModel.team {
                            teamId = team.teamId
                        } // set the selected team id
                        
                        // Attempt to add the new game to the database
                        Task {
                            do {
                                let finalLocation = getFinalLocation()
                                let gameDTO = GameDTO(title: title, duration: duration, location: finalLocation, scheduledTimeReminder: scheduledTimeReminder, startTime: startTime, timeBeforeFeedback: timeBeforeFeedback, timeAfterFeedback: timeAfterFeedback, recordingReminder: recordingReminder, teamId: teamId)

                                let canDismiss = try await gameModel.addNewGame(gameDTO: gameDTO) // add new game to the database
                                if canDismiss {
                                    dismiss()  // Dismiss the full-screen cover
                                }
                                
                            } catch {
                                print("Error when adding a new game... \(error)")
                            }
                        }
                        
                    }) {
                        Text("Done")
                    }
                    .disabled(!addGameIsValid)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("New Game"))
        }
    }
    
    
    /// Converts the given number of hours and minutes to a Firestore `Timestamp` object.
    ///
    /// This function takes the current date and time, adds the specified number of hours and minutes to it,
    /// and then returns a `Timestamp` representing the resulting date and time. The timestamp is used for storing
    /// dates and times in Firestore, ensuring compatibility with Firestore's date storage format.
    ///
    /// - Parameters:
    ///   - hours: The number of hours to add to the current date and time.
    ///   - minutes: The number of minutes to add to the current date and time.
    /// - Returns: A `Timestamp` object representing the calculated future date and time.
    func convertToTimestamp(hours: Int, minutes: Int) -> Timestamp {
        // Get the current calendar and the current date and time
        let calendar = Calendar.current
        let now = Date()
        
        // Add the specified number of hours to the current date
        let newDate = calendar.date(byAdding: .hour, value: hours, to: now)!
        // Add the specified number of minutes to the new date
            .addingTimeInterval(TimeInterval(minutes * 60))
        
        // Return the calculated date as a Firestore Timestamp
        return Timestamp(date: newDate)
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
}


/// Extension to conform to the `GameProtocol` for `CoachAddingGameView`.
///
/// This computed property checks if the game input is valid:
/// - The `title` of the game should not be empty.
/// - Either the `hours` or `minutes` should be non-zero, indicating a valid game duration.
///
/// Returns `true` if both conditions are met, otherwise `false`.
extension CoachAddingGameView: GameProtocol {
    var addGameIsValid: Bool {
        return !title.isEmpty
        && (hours != 0 || minutes != 0)
    }
}


#Preview {
    CoachAddingGameView(teamModel: TeamModel())
}
