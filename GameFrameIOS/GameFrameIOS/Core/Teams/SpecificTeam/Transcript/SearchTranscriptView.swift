//
//  SearchTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/// A view that displays all saved transcripts in a list format.
struct SearchTranscriptView: View {
    /// The text entered by the user to search for transcripts.
    @State private var searchText: String = ""
    
    /// The game associated with the transcripts.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// A list of transcripts related to the game.
    @State var transcripts: [keyMomentTranscript]?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Checks if there are any transcripts available.
                    if let recordings = transcripts {
                        if !recordings.isEmpty {
                            ForEach(recordings, id: \.id) { recording in
                                HStack(alignment: .top) {
                                    /// Navigation to `CoachSpecificTranscriptView` when a transcript is selected.
                                    NavigationLink(destination:
                                                    CoachSpecificTranscriptView(game: game, team: team, transcript: recording)) {
                                        HStack(alignment: .top) {
                                            
                                            // Calculates the duration of the transcript.
                                            let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                                            Text(formatDuration(durationInSeconds)).bold().font(.headline)
                                            Spacer()
                                            
                                            // Displays the transcript.
                                            Text("Transcript: \(recording.transcript)")
                                                .font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                                                .padding(.top, 4)
                                            
                                            Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                                        }.tag(recording.id as Int)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())// Simplifies list style
                .navigationTitle("All Transcripts").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search transcripts" )
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    SearchTranscriptView(game: game, team: team, transcripts: [])
}
