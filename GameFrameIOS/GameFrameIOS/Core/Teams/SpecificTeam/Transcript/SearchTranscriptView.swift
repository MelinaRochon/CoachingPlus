//
//  SearchTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI
import GameFrameIOSShared

/// A view that displays all saved transcripts in a list format.
struct SearchTranscriptView: View {
    let transcripts: [keyMomentTranscript]
    let prefix: Int?
    let transcriptType: TranscriptTypeEnum
    let game: DBGame
    let team: DBTeam
    let destinationBuilder: (keyMomentTranscript?) -> AnyView
        
    var body: some View {
        // Iterate through each games
        // Safely unwrap prefix to get the first N games, or return the full list if nil.
        let recordings = prefix.map { Array(transcripts.prefix($0)) } ?? transcripts
        ForEach(recordings, id: \.id) { recording in
            HStack(alignment: .center) {
                /// Navigation to `CoachSpecificTranscriptView` when a transcript is selected.
                NavigationLink(destination: destinationBuilder(recording)) {
                    transcriptRow(for: recording)
                }
            }
        }
    }
    
    @ViewBuilder
    private func transcriptRow(for recording: keyMomentTranscript) -> some View {
        HStack(alignment: .center) {
            if let gameStartTime = game.startTime {
                let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                Text(formatDuration(durationInSeconds))
                    .bold()
                    .font(.headline)
                    .frame(width: 80)
                    .multilineTextAlignment(.leading)
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("\(recording.transcript)")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2)
                        .lineLimit(2)
                        .padding(.top, 0)
                    
                    if let feedback = recording.feedbackFor {
                        if let players = team.players {
                            if players.count == feedback.count {
                                Text("All").font(.caption)
                                    .foregroundStyle(.red)
                            } else {
                                let names = feedback.map { $0.firstName + " " + $0.lastName }.joined(separator: ", ")
                                Text(names)
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
        }
    }
}
