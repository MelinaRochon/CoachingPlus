//
//  PlayerAllTranscriptsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/// `PlayerAllTranscriptsView` displays a list of all transcripts for a specific game.
/// Players can search, filter, and view detailed transcripts related to their team and game.
struct PlayerAllTranscriptsView: View {
    
    /// Search text entered by the user to filter transcripts.
    @State private var searchText: String = ""
    
    /// Controls whether the filter selector sheet is shown.
    @State private var showFilterSelector = false

    /// The game associated with the transcripts.
    @State var game: DBGame
    
    /// The team participating in the game.
    @State var team: DBTeam
    
    /// List of transcripts for the game.
    @State var transcripts: [keyMomentTranscript]?
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                
                // Header section displaying game and team details.
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(game.title).font(.title2)
                        Spacer()
                        
                        // Button to toggle filter options.
                        Button (action: {
                            showFilterSelector.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 20, height: 20)
                        }
                    }
                    
                    // Displays the team name and game start time.
                    HStack {
                        VStack(alignment: .leading) {
                            Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                            if let startTime = game.startTime {
                                Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        // Edit Icon
                        // TODO: - Implement button functionnality in next release
//                        Button(action: {}) {
//                            Image(systemName: "pencil.and.outline")
//                                .foregroundColor(.blue) // Adjust color
//                        }
                        // Share Icon
                        // TODO: - Implement button functionnality in next release
//                        Button(action: {}) {
//                            Image(systemName: "square.and.arrow.up")
//                                .foregroundColor(.blue) // Adjust color
//                        }
                    }
                }.padding(.leading).padding(.trailing).padding(.top, 3)
                
                Divider().padding(.vertical, 2)
                
                /// Displays the search and transcript list view.
                SearchTranscriptView(game: game, team: team, transcripts: transcripts)
            }
            // Sheet to display filter options.
            .sheet(isPresented: $showFilterSelector, content: {
                FilterTranscriptsListView().presentationDetents([.medium])
            })
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    PlayerAllTranscriptsView(game: game, team: team, transcripts: [])
}
