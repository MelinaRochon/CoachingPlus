//
//  AudioRecordingContentView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-05.
//

import SwiftUI

struct AudioRecordingContentView: View {
    @ObservedObject var audioRecordingModel: AudioRecordingModel
    @ObservedObject var gameModel: GameModel
    @Binding var isRecording: Bool
    @Binding var audios: [URL]
    @Binding var gameStartTime: Date
    var onRecordingStateChange: (Bool) -> Void

    var body: some View {
        VStack {
            if !audioRecordingModel.recordings.isEmpty {
                ScrollViewReader { proxy in
                    List {
                        Section(header: Text("Transcripts added")) {
                            ForEach(audioRecordingModel.recordings, id: \.id) { recording in
                                RecordingRowView(recording: recording,
                                                 players: audioRecordingModel.players,
                                                 gameStart: gameStartTime)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(.easeInOut(duration: 0.5),
                               value: audioRecordingModel.recordings.count)
                    .onChange(of: audioRecordingModel.recordings.count) { newCount in
                        scrollToBottom(proxy: proxy, newCount: newCount)
                    }
                }
            }
            
            Spacer()
            Divider()
            
            VStack {
                Spacer().frame(height: 20)
                RecordingButtonView { isRecording in
                    onRecordingStateChange(isRecording)
                }
                Spacer().frame(height: 5)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, newCount: Int) {
        guard let lastItem = audioRecordingModel.recordings.last else { return }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.8)) {
                proxy.scrollTo(lastItem.id, anchor: .bottom)
            }
        }
    }
}
