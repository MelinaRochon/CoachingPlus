//
//  CoachAllTranscriptsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/**
 `CoachAllTranscriptsView` is a SwiftUI view that presents the details of all transcripts for a scheduled game.
 It displays the game title, team information, and a list of transcripts, along with options to filter and share information.
 */
struct CoachAllTranscriptsView: View {
    
    /// A state variable to hold the search text entered by the user for filtering transcripts.
    @State private var searchText: String = ""
    
    /// A state variable to control whether the filter selector is shown or not.
    @State private var showFilterSelector = false
    
    /// The game for which the transcripts are displayed. It contains information about the scheduled game.
    @State var game: DBGame
    
    /// The team associated with the game. This is used to display team-specific information.
    @State var team: DBTeam
    
    /// An optional list of transcripts related to the game and team.
    /// This holds the data that will be displayed in the view.
    @State var transcripts: [keyMomentTranscript]?
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                
                // Game title and filter button
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(game.title).font(.title2)
                        Spacer()
                        Button (action: {
                            showFilterSelector.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 20, height: 20)
                        }
                    }
                    
                    // Team name and game start time display
                    HStack {
                        VStack(alignment: .leading) {
                            Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                            if let startTime = game.startTime {
                                Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        
                        /// Edit button (currently with no functionality assigned).
                        // TODO: - Future release, action for button will be implemented
//                        Button(action: {}) {
//                            Image(systemName: "pencil.and.outline")
//                                .foregroundColor(.blue) // Adjust color
//                        }
                        
                        /// Share button (currently with no functionality assigned).
                        // TODO: - Future release, action for button will be implemented
//                        Button(action: {}) {
//                            Image(systemName: "square.and.arrow.up")
//                                .foregroundColor(.blue) // Adjust color
//                        }
                    }
                }.padding(.leading).padding(.trailing).padding(.top, 3)
                
                Divider().padding(.vertical, 2)
                
                /// `SearchTranscriptView` is used to display and manage the list of transcripts.
                /// It takes the game, team, and the transcripts list to filter and show relevant transcripts.
                SearchTranscriptView(game: game, team: team, transcripts: transcripts)
                
            }
            // Show filters
            .sheet(isPresented: $showFilterSelector, content: {
                /// The filter options sheet is presented when the user taps the filter button.
                /// This view provides an interface to filter the displayed transcripts.
                NavigationStack {
                    FilterTranscriptsListView()
                        .presentationDetents([.medium])
                        .toolbar {
                            ToolbarItem {
                                Button (action: {
                                    showFilterSelector = false // Close the filter options
                                }) {
                                    Text("Done")
                                }
                            }
                        }
                        .navigationTitle("Filter Options")
                        .navigationBarTitleDisplayMode(.inline)
                }
            })
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    CoachAllTranscriptsView(game: game, team: team, transcripts: [])
}
