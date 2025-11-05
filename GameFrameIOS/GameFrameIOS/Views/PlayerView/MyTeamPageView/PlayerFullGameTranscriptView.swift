//
//  PlayerFullGameTranscriptView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-18.
//

import SwiftUI
import AVKit

/// **Note** To be added in a future release
struct PlayerFullGameTranscriptView: View {
    /// Local URL of the downloaded video file to be played.
    @State private var videoURL: URL?
    
    /// Firestore document ID of the team associated with the game.
    @State var teamDocId: String
    
    /// Unique identifier of the game for which the video transcript is fetched.
    @State var gameId: String
    
    @State var recordStartTime: Date?
    @State var gameTitle: String
    
    /// Whether the associated video file has been successfully downloaded and is ready for playback.
    @State private var videoFileRetrieved: Bool = false
    
    /// Model responsible for managing full-game video recording retrieval from Firestore/Storage.
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                   Text("Full Game Transcript").bold()
                       .frame(maxWidth: .infinity, alignment: .center)

                if videoFileRetrieved {
                    let localAudioURL = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent("downloaded_video.mov")
                    let ratio = videoAspectRatio(for: localAudioURL)
                    VideoPlayerView(url: localAudioURL)
                        .aspectRatio(ratio, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        .onAppear {
                            AVAudioSession.sharedInstance().setPlaybackCategory()
                        }
                    
                    VStack(alignment: .leading) {
                        Text(gameTitle).font(.title3)
                        if let gameStartTime = recordStartTime {
                            Text(formatStartTime(gameStartTime)).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Spacer()
            }
            
            if !videoFileRetrieved {
                CustomUIFields.loadingSpinner("Loading full game...") //.frame(alignment: .center)
            }
        }
        .task {
            do {
                // Get full game transcript video url
                guard let videoUrl = try await fgVideoRecordingModel.getFGRecordingVideoUrl(teamDocId: teamDocId, gameId: gameId) else {
                    print("❌ Unable to get video url")
                    return
                }
                let storageRef = StorageManager.shared.getAudioURL(path: videoUrl)
                
                let localURL = FileManager.default
                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("downloaded_video.mov")
                
                storageRef.write(toFile: localURL) { url, error in
                    if let error = error {
                        print("❌ Failed to download full Game video: \(error.localizedDescription)")
                    } else {
                        print("✅ Full Game video downloaded to: \(url?.path ?? "")")
                        // You can now use this local file (e.g., to play it)
                        videoFileRetrieved = true
                    }
                }
            } catch {
                print("unable to get full game transcript: \(error)")
                
            }
        }
        .onAppear {
            fgVideoRecordingModel.setDependencies(dependencies)
        }
    }
}
