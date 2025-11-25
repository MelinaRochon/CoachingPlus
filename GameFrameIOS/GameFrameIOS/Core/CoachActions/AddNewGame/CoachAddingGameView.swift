//
//  CoachAddingGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import Firebase
import GameFrameIOSShared

/**
 `CoachAddingGameView` is a SwiftUI view that allows soccer coaches to create a new game event.
 
 ## Features:
 - **Game Details:** Input a title, select a team, and specify the location.
 - **Scheduled Time:** Choose a start time and set a game duration.
 - **Feedback Settings:** Configure automatic feedback reminders before and after key events.
 - **Recording Reminder:** Enable or disable recording notifications before the game.
 - **Firestore Integration:** Saves the created game event to the Firebase Firestore database.
 
 This view interacts with `TeamModel` and `GameModel`, which handles data storage, team retrieval, and database operations.
 It includes form-based inputs and custom pickers for a streamlined user experience.
 
 ## Navigation:
 - **Back to Teams Page:** Users can dismiss the view with a cancel button.
 - **Save and Proceed:** Users can finalize game details and save them to the database.
 
 This view is designed with state management using `@StateObject` for handling game data and `@Environment(\.dismiss)`
 for navigation control.
 */
struct CoachAddingGameView: View {

    // MARK: - State Properties

    /// ViewModel for managing the data related to adding a new game
    @StateObject private var gameModel = GameModel()
    @EnvironmentObject private var dependencies: DependencyContainer

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
    @State private var gameStartTime: Date?

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
    
    /// Stores the team information
    @State var team: DBTeam
    
    @Binding var showErrorWhenSaving: Bool
            
    /// Variables for storing the selected time options for reminders and feedback
    @State private var selectedTimeLabel = "5 minutes before"  // User-friendly label
    @State private var feedbackBeforeTimeLabel = "10 seconds"
    @State private var feedbackAfterTimeLabel = "10 seconds"
    
    @State private var locationIsActive: Bool = false
    @State private var startTimeIsActive: Bool = false
    @State private var durationIsActive: Bool = false
    
    // MARK: - View

    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                CustomUIFields.customPageTitle("Adding a New Game", subTitle: "Enter the details of your upcoming game", divider: true)

                ScrollView {
                    VStack(alignment: .leading) {
                        VStack {
                            CustomTextField(label: "Game Title", text: $title)
                            CustomTextField(label: "Team", text: $team.teamNickname, disabled: true)
                            CustomNavigationLinkDropdown(
                                label: "Game Location",
                                placeholder: "Location",
                                valueText: {
                                    if let location = location {
                                        return "\(location.title) \(location.subtitle)"
                                    } else {
                                        return ""
                                    }
                                },
                                valueTextEmpty: "Enter Location",
                                icon: "mappin.and.ellipse",
                                iconColor: .gray,
                                isRequired: false,
                                isActive: $locationIsActive,
                                destination: LocationView(location: $location),
                                onSelect: {
                                    hideKeyboard()
                                    locationIsActive = true
                                }
                            )
                            
                            CustomUIFields.customDivider("Scheduled Time")
                                .padding(.top, 30)
                            
                            CustomNavigationLinkDropdown(
                                label: "Start Time",
                                placeholder: "Start",
                                valueText: {
                                    if let startTime = gameStartTime {
                                        return String(startTime.formatted(date: .abbreviated, time: .shortened))
                                    } else {
                                        return ""
                                    }
                                },
                                valueTextEmpty: "Select Date & Time",
                                icon: "calendar",
                                iconColor: .gray,
                                isActive: $startTimeIsActive,
                                destination: AddDateAndTimeView(
                                    date: $startTime,
                                    dateAtStart: $gameStartTime,
                                    title: "Select Your Game Start Time",
                                    subTitle: "Choose when the game begins so the app can schedule reminders and notify you before kickoff."
                                ),
                                onSelect: {
                                    hideKeyboard()
                                    startTimeIsActive = true
                                }
                            )
                            
                            CustomNavigationLinkDropdown(
                                label: "Game Duration",
                                placeholder: "Duration",
                                valueText: {
                                    if hours > 0 || minutes > 0 {
                                        return "\(hours) h \(minutes)m"
                                    } else {
                                        return ""
                                    }
                                },
                                valueTextEmpty: "Select Duration",
                                icon: "timer",
                                iconColor: .gray,
                                isActive: $durationIsActive,
                                destination: AddDurationView(
                                    hours: $hours,
                                    minutes: $minutes,
                                    title: "Configure Your Game Duration",
                                    subTitle: "The duration you set will be used to manage video recording and track feedback throughout the game."
                                ),
                                onSelect: {
                                    hideKeyboard()
                                    durationIsActive = true
                                }
                            )
                            
                            CustomUIFields.customDivider("Feedback Settings (Optional)")
                                .padding(.top, 30)
                            
                            CustomMenuDropdown(
                                label: "Before Feedback",
                                placeholder: "Time before feedback",
                                isRequired: false,
                                onSelect: {
                                    hideKeyboard()
                                },
                                options: AppData.feedbackBeforeTimeOptions.map { $0.0 },
                                selectedOption: $feedbackBeforeTimeLabel
                            )
                            
                            CustomMenuDropdown(
                                label: "After Feedback",
                                placeholder: "Time after feedback",
                                isRequired: false,
                                onSelect: {
                                    hideKeyboard()
                                },
                                options: AppData.feedbackAfterTimeOptions.map { $0.0 },
                                selectedOption: $feedbackAfterTimeLabel
                            )
                            
                            CustomUIFields.customDivider("Notification Settings (Optional)")
                                .padding(.top, 30)
                            
                            CustomToggleField(
                                label: "",
                                placeholder: "Get Recording Reminder",
                                isRequired: false,
                                onSelect: {
                                    hideKeyboard()
                                },
                                toggleIsOn: $recordingReminder,
                                icon: "bell.fill",
                                iconColor: .gray
                            )
                            
                            if (recordingReminder == true) {
                                // CustomPicker for selecting reminder time before the event
                                CustomMenuDropdown(
                                    label: "Get Notified",
                                    placeholder: "Remind me",
                                    isRequired: false,
                                    onSelect: {
                                        hideKeyboard()
                                    },
                                    options: AppData.timeOptions.map { $0.0 },
                                    selectedOption: $selectedTimeLabel
                                )
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .toolbarBackground(.clear, for: .bottomBar)
            .toolbar {
                // Cancel button in the toolbar to dismiss the view (Top Left)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.headline)
                        }
                    }
                }
                
                // Done button in the toolbar to save the game data
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { /* Action will need to be added -> complete team form */
                        // Save the selected settings for the game
                        if (recordingReminder == true) {
                            // Retrieve the get recording reminder alert value, if there is one
                            if let selectedOption = AppData.timeOptions.first(where: { $0.0 == selectedTimeLabel }) {
                                scheduledTimeReminder = selectedOption.1  // Store the database-friendly value
                            }
                        } else {
                            scheduledTimeReminder = 0
                        }
                        
                        // Retrieve the feedback time settings
                        if let selectedFeedbackBeforeOption = AppData.feedbackBeforeTimeOptions.first(where: { $0.0 == feedbackBeforeTimeLabel }) {
                            timeBeforeFeedback = selectedFeedbackBeforeOption.1  // Store the database-friendly value
                        }
                        
                        if let selectedFeedbackAfterOption = AppData.feedbackAfterTimeOptions.first(where: { $0.0 == feedbackAfterTimeLabel }) {
                            timeAfterFeedback = selectedFeedbackAfterOption.1  // Store the database-friendly value
                        }
                        
                        // Retrieve the duration
                        duration = ((3600 * hours) + (60 * minutes))
                                                
                        // Attempt to add the new game to the database
                        Task {
                            do {
                                let finalLocation = getFinalLocation()
                                let gameDTO = GameDTO(
                                    title: title, duration: duration,
                                    location: finalLocation,
                                    scheduledTimeReminder: scheduledTimeReminder,
                                    startTime: startTime,
                                    timeBeforeFeedback: timeBeforeFeedback,
                                    timeAfterFeedback: timeAfterFeedback,
                                    recordingReminder: recordingReminder,
                                    teamId: team.teamId
                                )

                                let canDismiss = try await gameModel.addNewGame(gameDTO: gameDTO) // add new game to the database
                                if canDismiss {
                                    dismiss()  // Dismiss the full-screen cover
                                }
                                
                            } catch {
                                showErrorWhenSaving = true
                                print("Error when adding a new game... \(error)")
                            }
                        }
                        
                    }) {
                        HStack {
                            Text("Add Game")
                                .font(.body).bold()
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(addGameIsValid ? Color.black : Color.secondary))

                    }
                    .disabled(!addGameIsValid)
                }
            }
            .onAppear {
                gameModel.setDependencies(dependencies)
            }
        }
    }
    
    
    // MARK: - Functions
    
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


// MARK: - Adding Game Validation


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
        && (gameStartTime != nil)
        && (hours != 0 || minutes != 0)
    }
}


#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    CoachAddingGameView(team: team, showErrorWhenSaving: .constant(false))
}
