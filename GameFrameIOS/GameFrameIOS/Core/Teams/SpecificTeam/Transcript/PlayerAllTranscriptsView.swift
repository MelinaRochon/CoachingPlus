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
    @State private var transcripts: [keyMomentTranscript]?
    
    /// Indicates whether the transcripts should be sorted by time (duration).
    /// - If `true`, transcripts are sorted by their `frameStart` time (chronological order).
    /// - If `false`, transcripts are sorted alphabetically by the transcript content.
    @State private var sortByTime: Bool = true

    /// Indicates whether the transcripts should be filtered by player.
    /// - If `true`, only transcripts related to the selected player (via `playerSelectedIndex`) will be shown.
    /// - If `false`, all transcripts are shown regardless of player association.
    @State private var sortByPlayer: Bool = false

    /// Holds a list of all player names paired with their corresponding player IDs.
    /// - Format: `(playerId, playerName)`
    /// - Used for filtering transcripts and displaying player names in pickers or filters.
    @State private var playersNames: [(String, String)] = []

    /// The index of the currently selected player in the `playersNames` array.
    /// - `0` typically represents a special "All players" option.
    /// - Used to filter transcripts to only those related to the selected player.
    @State private var playerSelectedIndex: Int = 0
    
    /// Holds the list of filtered transcripts.
    @State private var filteredTranscripts: [keyMomentTranscript] = []

    /// The view model responsible for managing player-related data and logic.
    /// - Declared as `@StateObject` to ensure it's created once and retained during the view’s lifecycle.
    /// - Used to fetch, store, and interact with players' data (e.g., names, selection, filtering).
    @StateObject private var playerModel = PlayerModel()
    
    /// A view model for managing and fetching the transcripts and key moments of the game.
    @StateObject private var transcriptModel = TranscriptModel()

    
    var body: some View {
        NavigationStack {
            List {
                // Checks if there are any transcripts available.
                if let recordings = transcripts {
                    if !recordings.isEmpty {
                        SearchTranscriptView(
                            transcripts: filteredTranscripts,
                            prefix: nil,
                            transcriptType: .transcript,
                            game: game,
                            team: team,
                            destinationBuilder: { recording in
                                AnyView(PlayerSpecificTranscriptView(game: game, team: team, transcript: recording))
                            }
                        )
                    } else {
                        Text("No transcripts found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .sheet(isPresented: $showFilterSelector, content: {
                /// The filter options sheet is presented when the user taps the filter button.
                /// This view provides an interface to filter the displayed transcripts.
                NavigationStack {
                    FilterTranscriptsListView(
                        sortByTime: $sortByTime,
                        sortByPlayer: $sortByPlayer,
                        playersNames: $playersNames,
                        playerSelectedIndex: $playerSelectedIndex,
                        userType: .player
                    )
                    .presentationDetents([.height(200)])
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("All Transcripts").font(.headline)
                        Text(game.title).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        showFilterSelector.toggle()
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search transcripts")
            .scrollContentBackground(.hidden)
            .overlay {
                if let recordings = transcripts {
                    if !recordings.isEmpty && filteredTranscripts.isEmpty && searchText != "" {
                        ContentUnavailableView {
                            Label("No Results", systemImage: "magnifyingglass")
                        } description: {
                            Text("Try to search for another transcript.")
                        }
                    }
                }
            }
            .onChange(of: searchText) {
                if let recordings = transcripts {
                    if !recordings.isEmpty && searchText != "" {
                        print("Filtering: \(searchText)")
                        self.filteredTranscripts = filterTranscripts(filteredTranscripts, game, with: searchText)
                    }
                    else {
                        self.filteredTranscripts = recordings
                        sortByPlayer = false
                        playerSelectedIndex = 0
                    }
                }
            }
            .onChange(of: sortByTime) {
                if sortByTime {
                    filteredTranscripts = filteredTranscripts.sorted(by: { $0.frameStart < $1.frameStart })
                } else {
                    // sort by alphabetical order
                    filteredTranscripts = filteredTranscripts.sorted(by: { $0.transcript < $1.transcript })
                }
            }
            .onAppear {
                
                Task {
                    do {
                        
                        let (tmpTranscripts, tmpKeyMom) = try await transcriptModel.getAllTranscriptsAndKeyMoments(gameId: game.gameId, teamDocId: team.id)
                        self.transcripts = tmpTranscripts
                        
                        if let recordings = tmpTranscripts {
                            self.filteredTranscripts = recordings
                            print(filteredTranscripts)
                        }


                        // Get all player's name
                        if let players = team.players {
                            playersNames = try await playerModel.getAllPlayersNames(players: players) ?? []
                        }
                    } catch {
                        print("Error. Aborting...")
                    }
                }
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    PlayerAllTranscriptsView(game: game, team: team)
}
