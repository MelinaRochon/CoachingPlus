//
//  SearchKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI
import AVFoundation
import GameFrameIOSShared

/// A view that displays a searchable list of key moments for a given game.
///
/// ### Features:
/// - Displays a list of key moments with timestamps and transcript previews.
/// - Allows users to search for key moments.
/// - Navigates to the detailed key moment view when a moment is selected.
struct SearchKeyMomentsView: View {
    
    let keyMoments: [keyMomentTranscript]
    let prefix: Int?
    let game: DBGame
    let team: DBTeam
    @State private var thumbnails: [String: UIImage] = [:]
    @State var videoUrl: URL
    
    let destinationBuilder: (keyMomentTranscript?) -> AnyView
    
    var body: some View {
        
        let recordings = prefix.map { Array(keyMoments.prefix($0)) } ?? keyMoments
        ForEach(recordings, id: \.id) { recording in
            NavigationLink(destination: destinationBuilder(recording)) {
                VStack {
                    HStack {
                        if let image = thumbnails[recording.keyMomentId] {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 60)
                                .clipped()
                                .cornerRadius(10)
                        } else {
                            Rectangle()
                                .fill(Color(uiColor: .systemFill))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                                .overlay(
                                    Image(systemName: "video.slash")
                                        .font(.title)   // size of icon
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        keyMomentRow(for: recording)
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.leading)
                            .padding(.trailing, 5)
                    }
                    Divider()
                }
                .padding(.horizontal, 15)
            }
        }
        .task {
            // Get the thumbail for each key moments
            for keyMoment in keyMoments {
                // TODO: Add time before feedback? possibly for the thumbnail
                if let gameStartTime = game.startTime {
                    let startTime = keyMoment.frameStart.timeIntervalSince(gameStartTime)
                    generateThumbnail(for: videoUrl, key: keyMoment.keyMomentId, sec: startTime)
                }
            }
        }
    }
    
    
    /// Generates a thumbnail image from a video at a specified time.
    /// - Parameters:
    ///   - url: The URL of the video file.
    ///   - key: A unique key used to store the generated thumbnail in a dictionary (optional, can be used to identify the thumbnail).
    ///   - sec: The time in seconds within the video where the thumbnail should be captured.
    /// - Returns: None. The thumbnail is stored asynchronously in the `thumbnails` dictionary.
    private func generateThumbnail(for url: URL, key: String, sec: Double) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: sec, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    thumbnails[key] = uiImage
                }
            } catch {
                print("❌ Failed to generate thumbnail for \(key): \(error.localizedDescription)")
            }
        }
    }
    
    
    /// Creates a view representing a single key moment row in the list of key moments.
    /// - Parameter recording: A `keyMomentTranscript` object containing the key moment's details (start time and transcript).
    /// - Returns: A SwiftUI view displaying the key moment's relative time and transcript text.
    @ViewBuilder
    private func keyMomentRow(for recording: keyMomentTranscript) -> some View {
        
        VStack {
            if let startTime = game.startTime {
                HStack {
                    let durationInSeconds = recording.frameStart.timeIntervalSince(startTime)
                    Text(formatDuration(durationInSeconds))
                        .bold()
                        .font(.headline)
                        .foregroundStyle(.black)
                    Spacer()
                }
            }
            Text(recording.transcript)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .foregroundStyle(.black)
        }
    }
}
