//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

struct RecordingButtonView: View {
    @State private var isRecording = false
    @Namespace private var animation
    var onRecordingStateChange: (Bool) -> Void  // Callback to notify parent

    var body: some View {
        VStack(alignment: .center) {
            
            ZStack {
                // Outer Circle (Button Background)
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 75, height: 75)
                ZStack {
                    // Inner Recording Shape (Morphing Circle/Square)
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                    ZStack {
                        RoundedRectangle(cornerRadius: isRecording ? 10 : 50)
                            .matchedGeometryEffect(id: "recordShape", in: animation)
                            .frame(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60)
                            .foregroundColor(.red)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRecording)
                }
            }
            .scaleEffect(isRecording ? 1.1 : 1.0) // Pulsing effect
            .animation(isRecording ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isRecording)
            .onTapGesture {
                isRecording.toggle()
                onRecordingStateChange(isRecording) // Notify parent view
            }
        }
    }
}
