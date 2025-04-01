//
//  CoachAllKeymomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/// **Displays all recorded key moments from a specific game for coaches.**
///
/// ### Features:
/// - Displays game and team details.
/// - Allows searching and filtering key moments.
/// - Provides options to edit and share key moments.
/// - Integrates the `SearchKeyMomentsView` for listing moments.
struct CoachAllKeyMomentsView: View {
    
    /// Stores the text entered in the search bar.
    @State private var searchText: String = ""
    
    /// Controls whether the filter selection modal is displayed.
    @State private var showFilterSelector = false
    
    /// The game for which key moments are displayed.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// List of key moments recorded for the game.
    @State var keyMoments: [keyMomentTranscript]?
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(game.title)
                            .font(.title2)
                        Spacer()
                        Button (action: {
                            showFilterSelector.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 20, height: 20)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                            if let startTime = game.startTime {
                                Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        // Edit Icon
                        Button(action: {}) {
                            Image(systemName: "pencil.and.outline")
                                .foregroundColor(.blue) // Adjust color
                        }
                        // Share Icon
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue) // Adjust color
                        }
                    }
                }.padding(.leading).padding(.trailing).padding(.top, 3)
                
                Divider().padding(.vertical, 2)
                
                SearchKeyMomentsView(game: game, team: team, keyMoments: keyMoments, userType: "Coach")
                
                
            }// Show filters
            .sheet(isPresented: $showFilterSelector, content: {
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
    
    CoachAllKeyMomentsView(game: game, team: team, keyMoments: [])
}
