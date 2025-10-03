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
    @State private var transcripts: [keyMomentTranscript]?
    
    @StateObject private var transcriptModel = TranscriptModel()

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

    var body: some View {
        NavigationStack {
            VStack {
                if let recordings = transcripts {
                    List {
                        // Checks if there are any transcripts available.
                        
                        if !recordings.isEmpty {
                            SearchTranscriptView(
                                transcripts: filteredTranscripts,
                                prefix: nil,
                                transcriptType: .transcript,
                                game: game,
                                team: team,
                                destinationBuilder: { recording in
                                    AnyView(CoachSpecificTranscriptView(game: game, team: team, transcript: recording))
                                }
                            )
                        } else {
                            Text("No transcripts found.").font(.caption).foregroundStyle(.secondary)
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                } else {
                    CustomUIFields.loadingSpinner("Loading transcripts...")
                }
            }
            // Show filters
            .sheet(isPresented: $showFilterSelector, content: {
                /// The filter options sheet is presented when the user taps the filter button.
                /// This view provides an interface to filter the displayed transcripts.
                NavigationStack {
                    FilterTranscriptsListView(
                        sortByTime: $sortByTime,
                        sortByPlayer: $sortByPlayer,
                        playersNames: $playersNames,
                        playerSelectedIndex: $playerSelectedIndex,
                        userType: .coach
                    )
                    .presentationDetents([.medium])
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
            .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                Color.clear.frame(height: 75)
            }
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
            .onChange(of: sortByPlayer) {
                sortTranscriptByPlayer()
            }
            .onChange(of: playerSelectedIndex) {
                sortTranscriptByPlayer()
            }
            .onChange(of: sortByTime) {
                if sortByTime {
                    filteredTranscripts = filteredTranscripts.sorted(by: { $0.frameStart < $1.frameStart })
                } else {
                    // sort by alphabetical order
                    filteredTranscripts = filteredTranscripts.sorted(by: { $0.transcript < $1.transcript })
                }
            }
        }.task {
            do {
                let tmpTranscripts = try await transcriptModel.getAllTranscripts(gameId: game.gameId, teamDocId: team.id)
                self.transcripts = tmpTranscripts
                self.filteredTranscripts = transcripts ?? []
                                
                // Get all player's name
                if let players = team.players {
                    playersNames = try await playerModel.getAllPlayersNames(players: players) ?? []
                }
            } catch {
                print("Error. Aborting...")
            }
        }
    }
    
    
    /// Filters the list of transcripts (`filteredTranscripts`) based on the currently selected player,
    /// only if `sortByPlayer` is enabled. If no player filtering is requested, all transcripts are returned.
    private func sortTranscriptByPlayer() {
        if let recordings = transcripts {
            if !recordings.isEmpty {
                if sortByPlayer {
                    // Filter transcripts to include only those with feedback for the selected player
                    filteredTranscripts = recordings.filter { transcript in
                        guard let feedbackPlayers = transcript.feedbackFor else { return false }
                        
                        // If the first player (index 0) is selected, assume "All players" option
                        if playerSelectedIndex == 0 {
                            // Get the list of all player IDs
                            let selectedPlayerIds = playersNames.map { $0.0 }
                            
                            // Return true if at least one player in the transcript matches a selected player
                            return feedbackPlayers.contains { player in
                                selectedPlayerIds.contains(player.playerId)
                            }
                        }
                        
                        // For a specific player selection, get the selected player's ID
                        let selectedPlayerId = playersNames[playerSelectedIndex].0
                        // Return true if the selected player is associated with this transcript
                        return feedbackPlayers.contains { $0.playerId == selectedPlayerId }
                    }
                }
                else {
                    // If filtering is not active, use the original unfiltered list
                    filteredTranscripts = recordings
                }
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    NavigationStack {
        CoachAllTranscriptsView(game: game, team: team)
    }
}
