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
            /// Navigation to `CoachSpecificTranscriptView` when a transcript is selected.
            NavigationLink(destination: destinationBuilder(recording)) {
                VStack {
                    transcriptRow(for: recording)
                    Divider()
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    @ViewBuilder
    private func transcriptRow(for recording: keyMomentTranscript) -> some View {
        HStack {
            Image(systemName: "waveform.and.mic")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.horizontal, 5)
            
            if let gameStartTime = game.startTime {
                VStack(spacing: 4) {
                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                    Text(formatDuration(durationInSeconds))
                        .bold()
                        .font(.headline)
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(recording.transcript)")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .foregroundColor(Color.black)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.leading)
                .padding(.trailing, 5)
            
        }
        .padding(.vertical, 5)        
    }
}
