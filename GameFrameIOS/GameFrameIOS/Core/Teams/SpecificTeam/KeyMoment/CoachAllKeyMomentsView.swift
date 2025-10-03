//
//  CoachAllKeymomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI
import AVFoundation

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
    @State private var keyMoments: [keyMomentTranscript]?
    
    @State var videoUrl: URL
    
    /// Holds the list of filtered key moments.
    @State private var filteredKeyMoments: [keyMomentTranscript] = []
    
    @StateObject private var transcriptModel = TranscriptModel()

    
    var body: some View {
        NavigationStack {
            VStack {
                if let recordings = keyMoments {
                    List {
                        if !recordings.isEmpty {
                            SearchKeyMomentsView(
                                game: game,
                                team: team,
                                keyMoments: recordings,
                                userType: "Coach",
                                prefix: nil,
                                destinationBuilder: { recording in
                                    AnyView(CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: recording!, videoUrl: videoUrl))
                                },
                                videoUrl: videoUrl
                            )
                        } else {
                            Text("No key moments found.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    CustomUIFields.loadingSpinner("Loading key moments...")
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("All Key Moments").font(.headline)
                        Text(game.title).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                Color.clear.frame(height: 75)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search key moments")
            .scrollContentBackground(.hidden)
            .overlay {
                if let recordings = keyMoments {
                    if !recordings.isEmpty && filteredKeyMoments.isEmpty && searchText != "" {
                        ContentUnavailableView {
                            Label("No Results", systemImage: "magnifyingglass")
                        } description: {
                            Text("Try to search for another key moment.")
                        }
                    }
                }
            }
            .onChange(of: searchText) {
                if let recordings = keyMoments {
                    if !recordings.isEmpty && searchText != "" {
                        print("Filtering: \(searchText)")
                        self.filteredKeyMoments = filterTranscripts(filteredKeyMoments, game, with: searchText)
                    }
                    else {
                        self.filteredKeyMoments = recordings
                    }
                }
            }
            .task {
                do {
                    let tmpKeyMoments = try await transcriptModel.getAllTranscripts(gameId: game.gameId, teamDocId: team.id)
                    self.keyMoments = tmpKeyMoments
                    self.filteredKeyMoments = keyMoments ?? []
                                
                } catch {
                    print("Error. Aborting...")
                }
            }

           
            // Show filters
//            .sheet(isPresented: $showFilterSelector, content: {
//                NavigationStack {
//                    FilterTranscriptsListView()
//                        .presentationDetents([.medium])
//                        .toolbar {
//                            ToolbarItem {
//                                Button (action: {
//                                    showFilterSelector = false // Close the filter options
//                                }) {
//                                    Text("Done")
//                                }
//                            }
//                        }
//                        .navigationTitle("Filter Options")
//                        .navigationBarTitleDisplayMode(.inline)
//                }
//            })
        }
    }
    

}

//#Preview {
//    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
//    
//    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
//    
//    CoachAllKeyMomentsView(game: game, team: team, keyMoments: [])
//}
