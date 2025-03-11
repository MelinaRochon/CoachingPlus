//
//  CoachAddingGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import Firebase

struct CoachAddingGameView: View {
    @State var newGame: Game
    
    @StateObject private var viewModel = AddNewGameModel()
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    @State var timeString = ""
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var timeBeforeFeedbackSec: Int = 0
    @State var timeAfterFeedbackSec: Int = 0

    // Define the list of options and corresponding values
    let timeOptions = [
        ("At time of event", 0),
        ("5 minutes before", 5),
        ("10 minutes before", 10),
        ("15 minutes before", 15),
        ("30 minutes before", 30),
        ("1 hour before", 60)
    ]
    
    let feedbackBeforeTimeOptions = [
        ("None", 0),
        ("5 seconds", 5),
        ("10 seconds", 10),
        ("15 seconds", 15),
        ("20 seconds", 20),
        ("30 seconds", 30)
    ]
    
    let feedbackAfterTimeOptions = [
        ("None", 0),
        ("5 seconds", 5),
        ("10 seconds", 10),
        ("15 seconds", 15),
        ("20 seconds", 20),
        ("30 seconds", 30)
    ]
    
    @State var selectedTeamName: String? = nil
    @State private var selectedTeamId: String? = nil


    @State private var selectedTimeLabel = "5 minutes before"  // User-friendly label
    @State private var selectedTimeValue = 5  // Database-friendly time string
    @State private var feedbackBeforeTimeLabel = "10 seconds"
    @State private var feedbackAfterTimeLabel = "10 seconds"
    
    private func formatTime() {
        var timeFormatter : DateFormatter {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "tr_TR") // your locale here
            return formatter
        }
        
        timeString = timeFormatter.string(from: newGame.duration)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Form {
                    Section {
                        HStack {
                            TextField("Title", text: $viewModel.title).multilineTextAlignment(.leading)
                        }
                        
                        HStack {
                            Picker("Replace team name", selection: $selectedTeamId) {
                                ForEach(viewModel.teamNames, id: \.teamId) { i in
                                    Text(i.name).tag(i.teamId as String?)
                                }
                            }
                        }
                        
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
                    
                    Section (header: Text("Scheduled Time")) {
                        
                        
                        HStack {
                            HStack {
                                DatePicker("Start", selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
                            }
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading){
                                    HStack (alignment: .center) {
                                        Text("Duration")
                                        
                                        Spacer()
                                        Picker("", selection: $hours){
                                            ForEach(0..<13, id: \.self) { i in
                                                Text("\(i)").tag(i)
                                            }
                                        }.pickerStyle(.wheel).frame(width: 60, height: 100)
                                            .clipped()
                                        Text("hours").bold()
                                        Picker("", selection: $minutes){
                                            ForEach(0..<60, id: \.self) { i in
                                                Text("\(i)").tag(i)
                                            }
                                        }.pickerStyle(WheelPickerStyle()).frame(width: 60, height: 100)
                                        Text("min").bold()
                                    }
                                }.frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                        }
                        
                    }
                    
                    Section(header: Text("Feedback Settings")) {
                        Picker("Before Feedback", selection: $feedbackBeforeTimeLabel) {
                            ForEach(feedbackBeforeTimeOptions, id: \.0) { option in
                                Text(option.0)
                            }
                        }
                        
                        HStack {
                            Picker("After Feedback", selection: $feedbackAfterTimeLabel) {
                                ForEach(feedbackAfterTimeOptions, id: \.0) { option in
                                    Text(option.0)
                                }
                            }
                        }
                    }
                    
                    Section(footer:
                                Text("Will send recording reminder at the scheduled time.")
                    ){
                        Toggle("Get Recording Reminder", isOn: $viewModel.recordingReminder)
                        if (viewModel.recordingReminder == true) {
                            HStack {
                                Picker("Alert", selection: $selectedTimeLabel) {
                                    ForEach(timeOptions, id: \.0) {option in
                                        Text(option.0)
                                    }
                                }
                            }
                        }
                    }
                }
                .task{
                    print("Loading current user...")
                    // Load the teams names if it is not passed as an argument when calling this view
                    try? await viewModel.loadTeamNames()
                    
                    if selectedTeamName == nil {
                        if let firstTeam = viewModel.teamNames.first {
                            selectedTeamId = firstTeam.teamId
                        }
                    }
                }
                
                
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { /* Action will need to be added -> complete team form */
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
                        print(selectedTeamId!)
                        
                        Task {
                            try await viewModel.addNewGame() // add new game to the database
                        }
                        
                        viewModel.test()
                    }) {
                        Text("Done")
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("New Game"))
            
        }
    }
    
    /// Convert user input (hours & minutes) into a Firestore Timestamp
    func convertToTimestamp(hours: Int, minutes: Int) -> Timestamp {
        let calendar = Calendar.current
        let now = Date()
        let newDate = calendar.date(byAdding: .hour, value: hours, to: now)!
            .addingTimeInterval(TimeInterval(minutes * 60))
        
        return Timestamp(date: newDate)
    }
}

#Preview {
    CoachAddingGameView(newGame: .init(title: "Game PSG VS Real Madrid", duration: Date(timeIntervalSinceNow: 3600), location: "Parc des Princes, Paris, France", scheduledTime: Date(), sport: "Soccer", timeBeforeFeedback: Date(timeIntervalSinceNow: 2000), timeAfterFeedback: Date(timeIntervalSinceNow: 2000), getRecordingReminder: true))
}
