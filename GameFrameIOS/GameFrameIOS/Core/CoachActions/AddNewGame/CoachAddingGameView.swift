//
//  CoachAddingGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import Firebase

/** This view allows the coach to add a new game by selecting teams, location, and feedback settings. */
struct CoachAddingGameView: View {
    // ViewModel for managing the data related to adding a new game
    @StateObject private var viewModel = AddNewGameModel()
    
    // Environment variable to dismiss the view and return to the previous screen
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    
    // Variables to store the hours and minutes for duration
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    // Options for reminder time before the event
    let timeOptions = [
        ("At time of event", 0),
        ("5 minutes before", 5),
        ("10 minutes before", 10),
        ("15 minutes before", 15),
        ("30 minutes before", 30),
        ("1 hour before", 60)
    ]
    
    // Options for feedback time before the event
    let feedbackBeforeTimeOptions = [
        ("None", 0),
        ("5 seconds", 5),
        ("10 seconds", 10),
        ("15 seconds", 15),
        ("20 seconds", 20),
        ("30 seconds", 30)
    ]
    
    // Options for feedback time after the event
    let feedbackAfterTimeOptions = [
        ("None", 0),
        ("5 seconds", 5),
        ("10 seconds", 10),
        ("15 seconds", 15),
        ("20 seconds", 20),
        ("30 seconds", 30)
    ]
    
    // Variables for storing the selected team information
    @State var selectedTeamName: String?
    @State var selectedTeamId: String?
    
    // Variables for storing the selected time options for reminders and feedback
    @State private var selectedTimeLabel = "5 minutes before"  // User-friendly label
    @State private var selectedTimeValue = 5  // Database-friendly time string
    @State private var feedbackBeforeTimeLabel = "10 seconds"
    @State private var feedbackAfterTimeLabel = "10 seconds"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Form {
                    
                    // Section for the game title and selecting team
                    Section {
                        TextField("Title", text: $viewModel.title).multilineTextAlignment(.leading)
                        HStack {
                            if viewModel.teamNames != [] {
                                // CustomPicker for selecting a team
                                CustomPicker(
                                    title: "Select Team",
                                    options: viewModel.teamNames.compactMap { $0.teamId },
                                    displayText: { teamId in
                                        viewModel.teamNames.first(where: { $0.teamId == teamId })?.name ?? "Unknown Team"
                                    },
                                    selectedOption: Binding(
                                        get: { selectedTeamId ?? (viewModel.teamNames.first?.teamId ?? "") },
                                        set: { selectedTeamId = $0 } // Update the selected team ID
                                    )
                                )
                            } else {
                                Text("Team")
                                Spacer()
                                Text(selectedTeamName ?? "").foregroundStyle(.secondary).multilineTextAlignment(.leading)
                            }
                        }
                        
                        // Section for selecting the game location
                        HStack {
                            Text("Location")
                            NavigationLink(destination: LocationView(location: $viewModel.location), label: {
                                HStack {
                                    Spacer()
                                    if let location = viewModel.location {
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
                            DatePicker("Start", selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
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
                        Toggle("Get Recording Reminder", isOn: $viewModel.recordingReminder)
                        if (viewModel.recordingReminder == true) {
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
                .task{
                    print("Loading current user...")
                    // Load the teams names if it is not passed as an argument when calling this view
                    if (selectedTeamName == nil || selectedTeamId == nil) {
                        try? await viewModel.loadTeamNames() // only load the team names if they are set to null
                        if let firstTeam = viewModel.teamNames.first {
                            selectedTeamId = firstTeam.teamId
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
                        if (viewModel.recordingReminder == true) {
                            // Retrieve the get recording reminder alert value, if there is one
                            if let selectedOption = timeOptions.first(where: { $0.0 == selectedTimeLabel }) {
                                viewModel.scheduledTimeReminder = selectedOption.1  // Store the database-friendly value
                                
                            }
                        } else {
                            viewModel.scheduledTimeReminder = 0
                        }
                        
                        // Retrieve the feedback time settings
                        if let selectedFeedbackBeforeOption = feedbackBeforeTimeOptions.first(where: { $0.0 == feedbackBeforeTimeLabel }) {
                            viewModel.timeBeforeFeedback = selectedFeedbackBeforeOption.1  // Store the database-friendly value
                        }
                        
                        if let selectedFeedbackAfterOption = feedbackAfterTimeOptions.first(where: { $0.0 == feedbackAfterTimeLabel }) {
                            viewModel.timeAfterFeedback = selectedFeedbackAfterOption.1  // Store the database-friendly value
                        }
                        
                        // Retrieve the duration
                        viewModel.duration = ((3600 * hours) + (60 * minutes))
                        
                        viewModel.teamId = selectedTeamId! // set the selected team id
                        
                        // Attempt to add the new game to the database
                        Task {
                            do {
                                let canDismiss = try await viewModel.addNewGame() // add new game to the database
                                if canDismiss {
                                    dismiss()  // Dismiss the full-screen cover
                                }
                                
                            } catch {
                                print("Error when adding a new game... \(error)")
                            }
                        }
                        
                    }) {
                        Text("Done")
                    }.disabled(viewModel.title == "" || (hours == 0 && minutes == 0) || selectedTeamId == nil)
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
}

#Preview {
    CoachAddingGameView(selectedTeamName: nil, selectedTeamId: nil)
}
