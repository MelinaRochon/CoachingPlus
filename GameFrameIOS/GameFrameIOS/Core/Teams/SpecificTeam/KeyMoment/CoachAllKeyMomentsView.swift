//
//  CoachAllKeymomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI
import AVFoundation
import GameFrameIOSShared

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
    @EnvironmentObject private var dependencies: DependencyContainer
    
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
    
    /// The view model responsible for managing player-related data and logic.
    /// - Declared as `@StateObject` to ensure it's created once and retained during the view’s lifecycle.
    /// - Used to fetch, store, and interact with players' data (e.g., names, selection, filtering).
    @StateObject private var playerModel = PlayerModel()

    @State private var isLoadingKeyMoments: Bool = false

    
    var body: some View {
        NavigationStack {
            VStack {
                
                if isLoadingKeyMoments {
                    ProgressView("Loading key moments…")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CustomUIFields.customDivider("Key Moments")
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                    
                    if let recordings = keyMoments, !recordings.isEmpty {
                        ScrollView {
                            SearchKeyMomentsView(
                                keyMoments: filteredKeyMoments,
                                prefix: nil,
                                game: game,
                                team: team,
                                videoUrl: videoUrl,
                                destinationBuilder: { recording in
                                    AnyView(CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: recording!, videoUrl: videoUrl))
                                }
                            )
                        }
                    } else {
                        VStack(alignment: .center) {
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                            
                            Text("No key moments found at this time.").font(.headline).foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)

                    }
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("All Key Moments").font(.headline)
                        Text(game.title).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
                        isLoadingKeyMoments = true
                        print("Filtering: \(searchText)")
                        self.filteredKeyMoments = filterTranscripts(filteredKeyMoments, game, with: searchText)
                        isLoadingKeyMoments = false
                    }
                    else {
                        self.filteredKeyMoments = recordings
                        sortByPlayer = false
                        playerSelectedIndex = 0
                    }
                }
            }
            .onAppear {
                transcriptModel.setDependencies(dependencies)
                playerModel.setDependencies(dependencies)
            }
            .onChange(of: sortByPlayer) {
                sortKeyMomentsByPlayer()
            }
            .onChange(of: playerSelectedIndex) {
                sortKeyMomentsByPlayer()
            }
            .onChange(of: sortByTime) {
                if sortByTime {
                    print("BEFORE SORT by time is now: \(filteredKeyMoments)")

                    filteredKeyMoments = filteredKeyMoments.sorted(by: { $0.frameStart < $1.frameStart })
                    print("AFTER sort by time is now: \(filteredKeyMoments)")
                } else {
                    // sort by alphabetical order
                    filteredKeyMoments = filteredKeyMoments.sorted(by: { $0.transcript < $1.transcript })
                }
            }
           
            // Show filters
            .sheet(isPresented: $showFilterSelector, content: {
                NavigationStack {
                    FilterTranscriptsListView(
                        sortByTime: $sortByTime,
                        sortByPlayer: $sortByPlayer,
                        playersNames: $playersNames,
                        playerSelectedIndex: $playerSelectedIndex,
                        userType: .coach
                    )
                    .presentationDetents([.height(340)])
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", systemImage: "xmark") {
                                showFilterSelector = false
                            }
                        }
                    }
                }
            })
        }
        .task {
            isLoadingKeyMoments = true
            do {
                // Get all key moments
                let tmpKeyMoments = try await transcriptModel.getAllTranscripts(gameId: game.gameId, teamDocId: team.id)
                
                self.keyMoments = tmpKeyMoments
                self.filteredKeyMoments = keyMoments ?? []
                
                // Get all player's name
                if let players = team.players {
                    playersNames = try await playerModel.getAllPlayersNames(players: players) ?? []
                }

            } catch {
                print("Error. Aborting...")
            }
            isLoadingKeyMoments = false
        }
    }
    
    /// Filters the list of transcripts (`filteredTranscripts`) based on the currently selected player,
    /// only if `sortByPlayer` is enabled. If no player filtering is requested, all transcripts are returned.
    private func sortKeyMomentsByPlayer() {
        if let recordings = keyMoments {
            if !recordings.isEmpty {
                if sortByPlayer {
                    // Filter transcripts to include only those with feedback for the selected player
                    filteredKeyMoments = recordings.filter { transcript in
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
                    filteredKeyMoments = recordings
                }
            }
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
