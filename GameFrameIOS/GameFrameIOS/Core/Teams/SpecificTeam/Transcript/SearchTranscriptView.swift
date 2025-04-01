//
//  SearchTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/** Shows all transcripts saved using a list */
struct SearchTranscriptView: View {
    @State private var searchText: String = ""
    
//    @State var gameId: String // scheduled game id is passed when this view is called
//    @State var teamDocId: String // scheduled game id is passed when this view is called
//    
//    @StateObject private var transcriptModel = TranscriptViewModel()
    
    @State var game: DBGame
    @State var team: DBTeam
    @State var transcripts: [keyMomentTranscript]?

    var body: some View {
        NavigationView {
            
            VStack {
                List {
                    if let recordings = transcripts {
                        if !recordings.isEmpty {
                            ForEach(recordings, id: \.id) { recording in
                                HStack(alignment: .top) {
                                    NavigationLink(destination:
                                                    CoachSpecificTranscriptView(game: game, team: team, transcript: recording)) {
                                        HStack(alignment: .top) {
                                            let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                                            Text(formatDuration(durationInSeconds)).bold().font(.headline)
                                            Spacer()
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
//        .task {
//            do {
//                print("Navigating with teamDocId: \(teamDocId), gameId: \(gameId)")
//                try await transcriptModel.loadAllTranscripts(gameId: gameId, teamDocId: teamDocId)
//            } catch {
//                print("Could not load transcripts. error: \(error)")
//            }
//        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    SearchTranscriptView(game: game, team: team, transcripts: [])
}
