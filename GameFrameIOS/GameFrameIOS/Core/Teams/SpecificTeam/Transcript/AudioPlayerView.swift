//
//  AudioPlayerView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import SwiftUI

struct AudioPlayerView: View {
    let audioURL: URL // Local file URL

    @StateObject private var audioPlayerVM = AudioPlayerViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                audioPlayerVM.playAudio(from: audioURL)
            }) {
                Image(systemName: audioPlayerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.blue)
            }

            Text(audioPlayerVM.isPlaying ? "Playing..." : "Paused")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}


//#Preview {
//    AudioPlayerView()
//}
