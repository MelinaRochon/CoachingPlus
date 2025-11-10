//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

/** This file defines a custom SwiftUI view called `RecordingButtonView` that represents a button
  used for starting and stopping audio recordings. The button has a dynamic appearance, changing
  shape and size based on the recording state (i.e., recording or not recording).

  ## Purpose:
  The `RecordingButtonView` is used in the UI to provide an interactive button that allows
  users to toggle audio recording. The button provides visual feedback when recording starts
  and stops, using animations to make the user experience more intuitive and engaging.

  ## Key Features:
  - The button's appearance changes when recording starts or stops (size, shape, color).
  - Pulsing animation effect to visually indicate the recording state.
  - Callback function (`onRecordingStateChange`) to notify the parent view of the recording state.
**Note**: This is the audio recording button view
 */
struct RecordingButtonView: View {
    /// State variable to track whether recording is in progress.
    @State private var isRecording = false
    
    /// Namespace used for matched geometry effect during animation.
    @Namespace private var animation
    
    /// Callback to notify parent view of the current recording state.
    var onRecordingStateChange: (Bool) -> Void  // Callback to notify parent

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                // Outer Circle (Button Background)
                ZStack {
                    // Inner Recording Shape (Morphing Circle/Square)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 75, height: 75)
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.8), lineWidth: 2)
                        )
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 2)
                        )
                    ZStack {
                        RoundedRectangle(cornerRadius: isRecording ? 10 : 50)
                            .matchedGeometryEffect(id: "recordShape", in: animation)
                            .frame(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60)
                            .foregroundColor(.red)
                    }
                }
            }
            .scaleEffect(isRecording ? 1.1 : 1.0) // Pulsing effect
            .animation(isRecording ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isRecording) // animation effect when the button changes to make it seem more user friendly
            .onTapGesture {
                isRecording.toggle() // recording is on/off
                onRecordingStateChange(isRecording) // Notify parent view
            }
        }
    }
}
