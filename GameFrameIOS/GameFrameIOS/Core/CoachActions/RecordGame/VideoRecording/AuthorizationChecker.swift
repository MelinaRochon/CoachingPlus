//
//  AuthorizationChecker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-09-17.
//

import SwiftUI
import UIKit
import AVFoundation

struct VideoPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var videoURL: URL?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoPickerView

        init(_ parent: VideoPickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.movie"]   // 🎥 video
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct VideoRecordingView: View {
    
    let coachId: String

    @State private var showingCamera = false
    @State private var videoURL: URL?
    
    // Unique identifiers for the game and team
    @State private var gameId: String = ""
    @State var teamId: String = ""
    
    @State private var fullGameId: String?

    @Binding var showLandingPageView: Bool
    @State private var recordingIsDone: Bool = false

    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    var body: some View {
        NavigationView {
            VStack {
                
                // TODO: Add key moments & integrate watch component here
                if let url = videoURL {
                    VideoPlayerView(url: url)   // 🔽 Custom player
                        .frame(height: 300)
                }
                                
                Button("Record Video") {
                    showingCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink(destination: CoachMainTabView(showLandingPageView: $showLandingPageView, coachId: coachId), isActive: $recordingIsDone) { EmptyView() }
                
            }.sheet(isPresented: $showingCamera) {
                VideoPickerView(videoURL: $videoURL)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveVideoRecording()
                    } label: {
                        Text("End Recording")
                    }
                }
            }
            .task {
                // Create a full game recording
                do {
                    // Load all recordings that are already there, if there are some
                    // Start by creating a new game
                    let gameDocId = try await audioRecordingModel.addUnknownGame(teamId: teamId) // gameDocId
                    self.gameId = gameDocId ?? ""

                    let fgRecordingId = try await fgVideoRecordingModel.createFGRecording(teamId: teamId, gameId: gameDocId!)
                    if let fgRecordingId = fgRecordingId {
                        self.fullGameId = fgRecordingId
                    } else {
                        // TODO: Do an error here if does not work
                        print("error. Could not get the recording id")
                    }
                } catch {
                    print("error")
                }
            }
            .onAppear {
                fgVideoRecordingModel.setDependencies(dependencies)
                audioRecordingModel.setDependencies(dependencies)
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    private func saveVideoRecording() {
        Task {
            do {
                // Update full game recording details
                // Update the link
                print("videoURL: \(videoURL ?? URL(string: "")!)")
                
                // Save link to storage database
                if let videoURL = videoURL, let fullGameId = fullGameId {
                    try await fgVideoRecordingModel.updateFGRecording(endTime: Date(), fgRecordingId: fullGameId, gameId: gameId, teamId: teamId, localFile: videoURL)
                }
                
                // Go back to main page
                recordingIsDone.toggle()
            } catch {
                print("error", error.localizedDescription)
            }
        }
    }
}

// Simple SwiftUI video player
import AVKit

struct VideoPlayerView: View {
    let url: URL

    var body: some View {
        FullscreenVideoPlayer(player: AVPlayer(url: url))
    }
}


struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
