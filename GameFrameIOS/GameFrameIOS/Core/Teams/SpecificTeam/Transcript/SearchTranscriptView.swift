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
    
    @State var gameId: String // scheduled game id is passed when this view is called
    @State var teamDocId: String // scheduled game id is passed when this view is called
    
    @StateObject private var transcriptModel = TranscriptViewModel()
    
    var body: some View {
        NavigationView {
            
            VStack {
                List {
                    if !transcriptModel.recordings.isEmpty {
                        ForEach(transcriptModel.recordings, id: \.id) { recording in
                            HStack(alignment: .top) {
                                NavigationLink(destination: CoachSpecificTranscriptView(gameId: gameId, teamDocId: teamDocId, recording: recording)) {
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
                .listStyle(PlainListStyle())// Simplifies list style
                .navigationTitle("All Transcripts").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search transcripts" )
                .scrollContentBackground(.hidden)
            }
        }.task {
            do {
                try await transcriptModel.loadAllTranscripts(gameId: gameId, teamDocId: teamDocId)
            } catch {
                print("Could not load transcripts. error: \(error)")
            }
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}

#Preview {
    SearchTranscriptView(gameId: "", teamDocId: "")
}
