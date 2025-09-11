//
//  AudioPlayerView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import SwiftUI

struct AudioPlayerView: View {
    let audioURL: URL
    
    /// Progress of the video playback (slider value).
    @State private var progress: Double = 0.0
        
    /// Total duration of the video clip (default: 180s).
    @State private var totalDuration: Double = 180

    @StateObject private var audioPlayerVM = AudioPlayerViewModel()

    var body: some View {
        VStack (alignment: .leading){

            // Audio Frame
            HStack {
                VStack(alignment: .leading) {
                    Button(action: {
                        audioPlayerVM.playAudio(from: audioURL)
                    }) {
                        Image(systemName: audioPlayerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                    }
                    Text("").font(.caption)
                }
                
                VStack(alignment: .leading) {
                    
                    // Progress Slider
                    Slider(
                        value: Binding(
                            get: { audioPlayerVM.progress },
                            set: { newValue in
                                audioPlayerVM.seek(to: newValue)
                            }
                        ),
                        in: 0...audioPlayerVM.totalDuration,
                        onEditingChanged: { editing in
                            if !editing && audioPlayerVM.isPlaying {
                                audioPlayerVM.seek(to: audioPlayerVM.progress)
                            }
                        }
                    )
                    .tint(.gray)
                    .frame(height: 30)
                    
                    // Time Labels (Start Time & Remaining Time)
                    HStack {
                        Text(formatTime(audioPlayerVM.progress)) // Current time
                            .font(.caption)
                        Spacer()
                        Text("-\(formatTime(audioPlayerVM.totalDuration - audioPlayerVM.progress))") // Remaining time
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal).padding(.bottom)
        }
    }
    
    /// **Formats a given time value (in seconds) into a `minutes:seconds` string.**
    ///
    /// - Parameter time: The total time in seconds.
    /// - Returns: A formatted string representing the time in `MM:SS` format.
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


//#Preview {
//    NavigationStack{
//        AudioPlayerView(audioURL: URL(fileURLWithPath: "/Users/melina_rochon/Library/Developer/CoreSimulator/Devices/15DEA0CA-D265-4BFA-A9B7-B3F1328B49DF/data/Containers/Data/Application/5535542C-735F-40A8-B633-260D7D98FF1C/Documents/downloaded_audio.m4a"))
//    }
//}
