//
//  SearchKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

struct SearchKeyMomentsView: View {
    @State private var searchText: String = ""

    @State var gameId: String // scheduled game id is passed when this view is called
    @State var teamDocId: String // scheduled game id is passed when this view is called

    @StateObject private var transcriptModel = TranscriptViewModel()

    
    var body: some View {
        NavigationView {
            VStack {
                List  {
                    if !transcriptModel.keyMoments.isEmpty{
                        ForEach(transcriptModel.keyMoments, id: \.id) { keyMoment in
                            HStack(alignment: .top) {
                                NavigationLink(destination: CoachSpecificKeyMomentView(gameId: gameId, teamDocId: teamDocId, recording: keyMoment)) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 110, height: 60)
                                        .cornerRadius(10)
                                    
                                    VStack {
                                        if let startTime = transcriptModel.gameStartTime {
                                            HStack {
                                                let durationInSeconds = keyMoment.frameStart.timeIntervalSince(startTime)
                                                Text(formatDuration(durationInSeconds)).bold().font(.headline)
                                                Spacer()
                                                Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                            }
                                        }
                                        Text("Transcript: \(keyMoment.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).lineLimit(3)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .navigationTitle("All Key Moments").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search key moments" )
            }
        }.task {
            do {
                try await transcriptModel.getGameStartTime(gameId: gameId, teamDocId: teamDocId)
                try await transcriptModel.loadFirstThreeTranscripts(gameId: gameId, teamDocId: teamDocId)
            } catch {
                print("Problem when loading the key moments: \(error)")
            }
        }
    }
}

#Preview {
    SearchKeyMomentsView(gameId: "", teamDocId: "")
}
