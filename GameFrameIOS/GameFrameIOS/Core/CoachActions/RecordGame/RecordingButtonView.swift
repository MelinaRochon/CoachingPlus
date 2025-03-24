//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

struct AudioRecordingView: View {
    @State private var isRecording = false
    @Namespace private var animation

    var body: some View {
        //        NavigationView {
        VStack(alignment: .center) {
            
            ZStack {
                // Outer Circle (Button Background)
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 100, height: 100)
                ZStack {
                    // Inner Recording Shape (Morphing Circle/Square)
                    Circle()
                        .fill(.white)
                        .frame(width: 90, height: 90)
                    ZStack {
                        RoundedRectangle(cornerRadius: isRecording ? 10 : 50)
                            .matchedGeometryEffect(id: "recordShape", in: animation)
                            .frame(width: isRecording ? 50 : 80, height: isRecording ? 50 : 80)
                            .foregroundColor(.red)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isRecording)
                }
            }
            .scaleEffect(isRecording ? 1.1 : 1.0) // Pulsing effect
            .animation(isRecording ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isRecording)
            .onTapGesture {
                isRecording.toggle()
            }
            
            Text(isRecording ? "Stop Recording" : "Start Recording")
                .font(.headline)
                .padding(.top, 10)
        }
    }
//    }
}

#Preview {
    AudioRecordingView()
}
