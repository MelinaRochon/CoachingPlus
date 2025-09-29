//
//  PlayerAllKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-18.
//

import SwiftUI
import AVFoundation

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
