//
//  PlayerAllKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-18.
//

import SwiftUI

/// A view that displays all key moments recorded for a game, allowing players to browse and filter them.
///
/// ### Features:
/// - Displays the game title and team information.
/// - Integrates a search feature for filtering key moments.
/// - Allows filtering key moments through a filter selection sheet.
struct PlayerAllKeyMomentsView: View {
    
    /// The text entered by the user in the search bar.
    @State private var searchText: String = ""
    
    /// Controls the visibility of the filter selection sheet.
    @State private var showFilterSelector = false
    
    /// The game for which key moments are being displayed.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// A list of key moments retrieved for the given game.
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
                    }
                }.padding(.leading).padding(.trailing).padding(.top, 3)
                
                Divider().padding(.vertical, 2)
                
                // Embedded search and key moments list
                SearchKeyMomentsView(game: game, team: team, keyMoments: keyMoments, userType: "Player")
                
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
    
    PlayerAllKeyMomentsView(game: game, team: team, keyMoments: [])
}
