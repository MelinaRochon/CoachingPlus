//
//  VideoRecordingButtonView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import SwiftUI

struct VideoRecordingButtonView: View {
    /// State variable to track whether recording is in progress.
    @State private var isRecording = false
    
    /// Namespace used for matched geometry effect during animation.
    @Namespace private var animation
    
    /// Callback to notify parent view of the current recording state.
    var onRecordingStateChange: (Bool) -> Void  // Callback to notify parent

    @State private var showStopAlert = false

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.clear)
                    .frame(maxWidth: 177, maxHeight: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.black.opacity(0.6), lineWidth: 4)
                    )
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.red)
                        .frame(maxWidth: 175, maxHeight: 30)
                    HStack {
                        Text(isRecording ? "End Game" : "Start Recording")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.trailing, 5)
                        
                        Image(systemName: isRecording ? "video.fill.badge.checkmark" : "video.fill").frame(width: 14, height: 14).foregroundColor(Color.white)
                    }
                    .padding()
                }
            }
            .scaleEffect(isRecording ? 1.1 : 1.0) // Pulsing effect
            .shadow(color: isRecording ? .red.opacity(0.5) : .clear, radius: 6, x: 0, y: 0)
            .onTapGesture {
                if isRecording {
                    // Show alert BEFORE stopping recording
                    showStopAlert = true
                } else {
                    // Start recording immediately
                    isRecording = true
                    onRecordingStateChange(true)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isRecording)
            .alert("Ending Game", isPresented: $showStopAlert) {
                Button("Cancel", role: .cancel) {
                    // Do nothing — stay recording
                }
                Button("Yes", role: .destructive) {
                    // User confirmed stop
                    isRecording = false
                    onRecordingStateChange(false)
                }
            } message: {
                Text("Are you sure you want to end this game? You cannot undo this action.")
            }
            .animation(.easeInOut(duration: 0.6), value: isRecording)
        }
    }
}
