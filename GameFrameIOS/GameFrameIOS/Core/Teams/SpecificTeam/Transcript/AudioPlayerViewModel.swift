//
//  AudioPlayerViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import Foundation
import AVFoundation
import Combine

class AudioPlayerViewModel: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var lastURL: URL?

    @Published var isPlaying: Bool = false
    @Published var progress: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 1 // Duration in seconds
    
    private var timer: Timer?

    func playAudio(from url: URL) {
            // Check if the audio is already loaded and it's the same file
            if let player = audioPlayer, lastURL == url {
                if isPlaying {
                    pauseAudio()
                } else {
                    player.play()
                    isPlaying = true
                    startTimer()
                }
            } else {
                // New audio file or not yet loaded
                do {
                    lastURL = url
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.currentTime = progress // Resume from last known position
                    audioPlayer?.play()
                    isPlaying = true
                    totalDuration = audioPlayer?.duration ?? 1
                    startTimer()
                } catch {
                    print("❌ Failed to play audio: \(error.localizedDescription)")
                }
            }
        }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        progress = time
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    private func startTimer() {
        stopTimer() // Ensure no duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = self.audioPlayer else { return }
            self.progress = player.currentTime
            if !player.isPlaying {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
