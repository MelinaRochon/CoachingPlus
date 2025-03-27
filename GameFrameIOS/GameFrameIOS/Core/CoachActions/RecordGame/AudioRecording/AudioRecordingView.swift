//
//  AudioRecordingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

struct AudioRecordingView: View {
    @StateObject private var audioRecordingModel = AudioRecordingViewModel()

    @State private var recordingStartTime: Date?
    @State private var gameId: String = ""
    @State var teamId: String = ""
    @State private var showStopRecordingAlert: Bool = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationView {
            VStack {
                if !audioRecordingModel.recordings.isEmpty {
                    ScrollViewReader { proxy in
                        
                        List {
                            Section(header: Text("Transcripts added")) {
                                ForEach(audioRecordingModel.recordings, id: \.id) { recording in
                                    HStack (alignment: .center) {
                                        let durationInSeconds = recording.frameEnd.timeIntervalSince(recording.frameStart)
                                        
                                        Text(formatDuration(durationInSeconds)).bold().font(.headline)
                                        Text("Transcript: \(recording.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3)
                                        Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                                    }.tag(recording.id as Int)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .animation(.easeInOut(duration: 0.5), value: audioRecordingModel.recordings.count)
                        .onChange(of: audioRecordingModel.recordings.count) { newCount in
                            scrollToBottom(proxy: proxy, newCount: newCount)
                        }
                    }
                }
                // Audio Recording Button
                Spacer()
                Divider()
                VStack {
                    Spacer().frame(height: 20)
                    RecordingButtonView
                    { isRecording in
                        handleRecordingStateChange(isRecording)
                    }
                    Spacer().frame(height: 5)

                }
                NavigationLink(destination: CoachMainTabView(showLandingPageView: .constant(false)), isActive: $navigateToHome) { EmptyView()
                }

            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showStopRecordingAlert.toggle()
                    } label: {
                        Text("End Recording")
                    }.alert("Are you sure you want to stop recording?", isPresented: $showStopRecordingAlert) {
                        Button(role: .cancel) {
                            // Handle the cancelation
                        } label: {
                            Text("Cancel")
                        }
                        Button("End Recording") {
                            // Handle the end recording
                            // Update the game's duration, add the end time
                            // Let the user see a page after with the game's detail that he can edit?
                            Task {
                                do {
                                    try await audioRecordingModel.endAudioRecordingGame(teamId: teamId, gameId: gameId)
                                    // Go back to the main page
                                    navigateToHome = true

                                } catch {
                                    print("Error when ending recording. ")
                                }
                            }
                        }
                    }
                }
            }
            .task {
                do {
                    // Load all recordings that are already there, if there are some
                    // Start by creating a new game
                    let gameDocId = try await audioRecordingModel.addUnknownGame(teamId: teamId) // gameDocId
                    self.gameId = gameDocId ?? ""
                    print("ib aydui recording... gameId: \(gameId), teamId: \(teamId)")
                } catch {
                    print("Error when loading the audio recording transcripts. Error: \(error)")
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    func handleRecordingStateChange(_ isRecording: Bool) {
        if isRecording {
            // Start Recording: Capture start time
            recordingStartTime = Date()
        } else {
            // Stop Recording: Save to recordings
            if let startTime = recordingStartTime {
                let endTime = Date()
                audioRecordingModel.gameId = gameId
                audioRecordingModel.teamId = teamId

                Task {
                    do {
                        
                        try await audioRecordingModel.addRecording(recordingStart: startTime, recordingEnd: endTime)
                    } catch {
                        print("Error...")
                    }
                }
            }
            
            // Reset the recording start and end times
            recordingStartTime = nil
        }
    }
    
    // Scroll to bottom helper function
        private func scrollToBottom(proxy: ScrollViewProxy, newCount: Int) {
            guard let lastItem = audioRecordingModel.recordings.last else { return }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.8)) { // Smooth scrolling
                    proxy.scrollTo(lastItem.id, anchor: .bottom)
                }
            }
        }
    
    func stopRecordingManually() {
        handleRecordingStateChange(false)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    AudioRecordingView(teamId: "")
}
