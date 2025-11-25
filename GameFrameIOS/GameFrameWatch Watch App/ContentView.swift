//
//  ContentView.swift
//  GameFrameWatch Watch App
//
//  Created by Mélina Rochon on 2025-11-25.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityProvider
    
    @State private var startOfGame: Date? = nil
    @State private var startOfRecording: Date? = nil
    @State private var timeSinceBeginningOfGame: TimeInterval = 0
    
    @State private var timeSinceBeginningOfRecording: TimeInterval = 0
    @State private var isRecording: Bool = false
    @State private var timer: Timer? = nil
    @State private var gameTimer: Timer? = nil
    
    @StateObject private var recorder = WatchAudioRecorder.shared
    
    // Transcripts for testing
    @State private var feedbackIndex = 0
    @State private var testTranscript: [String] = [
        "Excellent positioning Charlotte — stayed in line with the defense.",
        "Strong passing accuracy under pressure.",
        "Needs to communicate more with teammates Charlotte.",
        "Improved ball control since last match.",
        "Tends to drift too far from assigned position.",
        "Showed great hustle to recover the ball.",
        "Should look up before making long passes Julia.",
        "Excellent awareness when switching play.",
        "Needs to track back faster on defense Willa.",
        "Great composure in one-on-one situations.",
        "Should press the opponent earlier Victoria.",
        "Effective use of space during counterattacks.",
        "Needs to work on first touch consistency.",
        "Impressive stamina Victoria — maintained intensity all game.",
        "Decision-making could be quicker in the final third.",
        "Strong tackling and defensive timing.",
        "Needs to anticipate through balls better.",
        "Showed good leadership and vocal presence.",
        "Be more patient when building out from the back.",
        "Great positioning for receiving passes.",
        "Needs to improve crossing accuracy.",
        "Kept possession well under pressure.",
        "Strong header technique during set pieces.",
        "Should be more aggressive in duels.",
        "Smart movement off the ball."
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer().frame(height: 20)
                    RecordingButtonView()
                    { newVal in
                        handleRecordingStateChange(recorder.isRecording)
                    }
                    Spacer().frame(height: 5)
                }.padding(.top, 5)
                
                ZStack {
                    // Timer text (visible only while recording)
                    Text(formatTimeInterval(recorder.currentDuration))
                        .font(.title2)
                        .monospacedDigit()
                        .padding(.horizontal, 5)
                        .opacity(recorder.isRecording ? 1.0 : 0.0)
                    
                    // “Press to record” text (hidden while recording)
                    Text("Press to record")
                        .font(.title3)
                        .padding(.horizontal, 5)
                        .opacity(recorder.isRecording ? 0.0 : 1.0)
                }
                .animation(.easeInOut(duration: 0.2), value: recorder.isRecording)
                
                VStack {
                    Text("Time since start of game")
                        .font(.caption2)
                    Text(formatTimeIntervalForGame(timeSinceBeginningOfGame))
                        .font(.caption)
                        .monospacedDigit()
                }.padding(.vertical, 5)
                
            }
            .task {
                startOfGame = Date()
                timeSinceBeginningOfGame = 0
                connectivity.startMonitoring() // start monitoring the heartbeats
                gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    if let start = startOfGame {
                        timeSinceBeginningOfGame = Date().timeIntervalSince(start)
                    }
                }
            }
        }
        .navigationTitle("GameFrame")
        .navigationBarTitleDisplayMode(.automatic)
    }
    
    private func formatTimeIntervalForGame(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "00:00:00"
    }
    
    private func formatTimeInterval(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let hundredths = Int((duration - floor(duration)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    
    private func handleRecordingStateChange(_ isRecording: Bool) {
        print("recording=\(recorder.isRecording)")
        
        if isRecording {
            //                            startRecording()
            guard let url = recorder.stopRecording() else {
                print("ERROR with audio url on watch os")
                return
            }
            let transcript = testTranscript[feedbackIndex]
            //            connectivity.sendRecordingToIOS(fileURL: url, recordingStart: recorder.recordingStartTime ?? Date(), recordingEnd: recorder.recordingEndTime ?? Date())
            connectivity.sendRecordingToIOS(fileURL: url, recordingStart: recorder.recordingStartTime ?? Date(), recordingEnd: recorder.recordingEndTime ?? Date(), transcript: transcript)
            
            recorder.resetValues()
            
            // 2️⃣ Increment for next time
            feedbackIndex += 1
            
            // 3️⃣ Optional: wrap around if you reach the end
            if feedbackIndex >= testTranscript.count {
                feedbackIndex = 0
            }
            
        } else {
            recorder.startRecording()
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
}
