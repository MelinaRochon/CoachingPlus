//
//  VideoPlayerView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import SwiftUI
import AVKit

// Simple SwiftUI video player
struct VideoPlayerView: View {
    let url: URL

    var body: some View {
        FullscreenVideoPlayer(player: AVPlayer(url: url))
    }
}


struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
