//
//  AudioPlayerViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import Foundation
import AVFoundation

class AudioPlayerViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    @Published var isPlaying: Bool = false

    func playAudio(from url: URL) {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("❌ Failed to play audio: \(error.localizedDescription)")
            }
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }
}
