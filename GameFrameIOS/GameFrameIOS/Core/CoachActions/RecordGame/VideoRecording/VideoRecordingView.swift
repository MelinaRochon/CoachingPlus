//
//  AuthorizationChecker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-09-17.
//

import SwiftUI
import UIKit
import AVFoundation
import AVKit
import Combine

struct VideoRecordingView: View {
    
    /// Url to the full game video recording
    @State private var videoURL: URL?
    
    /// Unique identifiers for the coach, game, team and full game video
    @State var gameId: String
    @State var teamId: String = ""
    @State private var fullGameId: String?

    @StateObject private var audioRecordingModel = AudioRecordingModel()
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @StateObject private var camera = CameraViewModel()
    
    @EnvironmentObject private var dependencies: DependencyContainer
    @EnvironmentObject private var connectivity: iPhoneConnectivityProvider

    @State private var pulse = false
    
    /// Audio session
    @State var session : AVAudioSession!
    
    /// Alerts for camera and audio access required
    @State private var audioPermissionAlert: Bool = false
    @State private var cameraPermissionAlert: Bool = false
    
    /// If the game is being recorded or not
    @State private var isRecording: Bool = false
    @State private var isSessionRunning = false

    /// Handles if the camera is covering entire screen or not
    @State private var isCameraExpanded = false
    
    /// Navigation state for transitioning back to the main page
    @Binding var savedRecording: Bool
    @State private var savingIsOn = false
    
    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @State private var gameStartTime: Date?
    @State var isUsingWatch: Bool

    var body: some View {
        NavigationView {
            ZStack {
                if !isSessionRunning || savingIsOn {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea() // fills the entire screen, behind nav bar
                    
                    if savingIsOn {
                        // Saving the game. Show progress view
                        ProgressView("Saving game...")
                            .foregroundStyle(.white)
                    }
                } else {
                    GeometryReader { geo in
                        let isLandscape = geo.size.width > geo.size.height
                        
                        // Need to record game in portrait mode
                        if isLandscape {
                            Color.black.opacity(0.8)
                                .ignoresSafeArea()
                                .overlay(
                                    VStack(spacing: 20) {
                                        Image(systemName: "rectangle.landscape.rotate")
                                            .font(.system(size: 80))
                                            .foregroundColor(.white)
                                            .symbolEffect(.bounce, options: .repeat(2)) // fun little animation (iOS 17+)
                                        Text("Please rotate your device")
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                        Text("Portrait mode is required to continue")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                    }
                                        .multilineTextAlignment(.center)
                                        .padding()
                                )
                                .transition(.opacity)
                                .animation(.easeInOut, value: isLandscape)
                        }
                        
                        VStack(spacing: 0) {
                            feedbackView
                                .frame(maxWidth: geo.size.width)
                                .frame(height: isRecording ? (isCameraExpanded ? 0 : geo.size.height * 0.8) : 0)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.4), value: isRecording)
                            cameraView
                                .frame(maxWidth: geo.size.width)
                                .frame(height: isRecording ? (isCameraExpanded ? geo.size.height : geo.size.height * 0.2) : geo.size.height)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.4), value: isRecording)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        isCameraExpanded.toggle()
                                    }
                                }
                                .ignoresSafeArea()
                        }
                        .opacity(!isLandscape ? 1 : 0)
                    }
                }
            }
            .task {
                // Create a full game recording
                if !cameraPermissionAlert && !audioPermissionAlert {
                    do {
                        if self.gameId.isEmpty {
                            // Load all recordings that are already there, if there are some
                            // Start by creating a new game
                            guard let gameDocId = try await audioRecordingModel.addUnknownGame(teamId: teamId) else {
                                print("Could not create an unknown game")
                                // TODO: Manage this throw error
                                return
                            }
                            self.gameId = gameDocId
                        }
                        
                        guard let fgRecordingId = try await fgVideoRecordingModel.createFGRecording(teamId: teamId, gameId: gameId) else {
                            // TODO: Do an error here if does not work
                            print("error. Could not get the recording id")
                            return
                        }
                        
                        self.fullGameId = fgRecordingId
                        
                        if isUsingWatch {
                            // Set the game session context in case watchOS is used to record audio feedback
                            let authUser = try dependencies.authenticationManager.getAuthenticatedUser()
                            dependencies.currentGameContext = GameSessionContext(
                                gameId: gameId,
                                teamId: teamId,
                                gameStartTime: self.gameStartTime ?? Date(),
                                players: audioRecordingModel.players,
                                uploadedBy: authUser.uid
                            )
                        }

                    } catch {
                        print("error")
                    }
                }
            }
        }
        .onAppear {
            
            // Check for the camera permission, otherwise show alert
            checkCameraPermission { granted in
                self.cameraPermissionAlert = !granted
            }
            
            // Check for the microphone permission, otherwise show alert
            requestMicrophonePermission { micGranted in
                self.audioPermissionAlert = !micGranted
            }
            
            // Configure the session if both permissions were granted
            if !cameraPermissionAlert && !audioPermissionAlert {
                camera.configure()
                DispatchQueue.global().async {
                    while !camera.session.isRunning {
                        usleep(10000) // 0.01 sec
                    }
                    DispatchQueue.main.async {
                        isSessionRunning = true
                    }
                }
                fgVideoRecordingModel.setDependencies(dependencies)
                audioRecordingModel.setDependencies(dependencies)
            }
        }
        .onDisappear {
            camera.stopSession()
        }
        .onReceive(recordingsPublisher) { newRecordings in
            DispatchQueue.main.async {
                if audioRecordingModel.recordings != newRecordings {
                    print("🎧 Updated recordings: \(newRecordings.count)")
                    
                    audioRecordingModel.recordings = newRecordings
                }
            }
        }

        .alert("Camera access is required", isPresented: $cameraPermissionAlert) {
            Button(role: .cancel) {
                // Open the settings
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
            }
        } message: {
            Text("To record video, please allow camera access in your device settings.")
        }
        .alert("Microphone access is required", isPresented: $audioPermissionAlert) {
            Button(role: .cancel) {
                // Open the settings
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
            }
        } message: {
            Text("To do an audio recording of a feedback, please allow microphone access in your device settings.")
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Subviews

    private var recordingsPublisher: AnyPublisher<[keyMomentTranscript], Never> {
        dependencies.currentGameRecordingsContext?.$recordings.eraseToAnyPublisher() ?? Just<[keyMomentTranscript]>([]).eraseToAnyPublisher()
    }


    private var feedbackView: some View {
        VStack {
            if !gameId.isEmpty && gameStartTime != nil {
                // Show the audio transcript view
                AudioRecordingView(
                    gameId: gameId,
                    teamId: teamId,
                    navigateToHome: .constant(false),
                    isUsingWatch: isUsingWatch,
                    showNavigationUI: false
                )
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .background(Color.white)
    }

    
    private var cameraView: some View {
        ZStack {
            // Camera to record game
            CameraPreview(session: camera.session)
                .onAppear {
                    camera.onRecordingFinished = { url in
                        saveVideoRecording(videoURL: url)
                    }
                }
            
            VStack {
                if camera.isRecording {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .scaleEffect(pulse ? 1.3 : 1.0)
                            .shadow(color: .red.opacity(0.7), radius: pulse ? 6 : 2)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                    pulse = true
                                }
                            }
                        
                        Text("REC")
                            .font(.headline)
                            .foregroundColor(.red)
                            .bold()
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding(.top, isCameraExpanded ? 56 : 16)
                    .onDisappear {
                        pulse = false // 🔴 Stop pulsing when the indicator disappears
                    }
                }
                Spacer()
            }
            
            Spacer()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VideoRecordingButtonView()
                    { isRecording in
                        handleRecordingStateChange(camera.isRecording)
                    }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func handleRecordingStateChange(_ isRecording: Bool) {        
        withAnimation(.easeInOut(duration: 0.4)) {
            isCameraExpanded = false // Reset camera view to normal
        }
        
        if isRecording {
            self.isRecording = false
        } else {
            self.isRecording = true

            // Set the game start time
            self.gameStartTime = Date()
            updateGameStartTime()
        }
        camera.toggleRecording()
    }
    
    private func updateGameStartTime() {
        Task {
            do {
                try await fgVideoRecordingModel.updateGameStartTime(gameId: gameId, teamId: teamId, startTime: Date())
                
                if isUsingWatch {
                    // Start the hearbeats on the watch side
                    connectivity.startHeartbeats()
                    
                    // Notify the game has started
                    connectivity.notifyWatchGameStarted(gameId: gameId)
                }
            } catch {
                print(error)
                return
            }
        }
    }
    
    private func saveVideoRecording(videoURL: URL) {
        Task {
            do {
                if isUsingWatch {
                    // End the game on the watch
                    connectivity.notifyWatchGameEnded()
                    
                    // Stop the heartbeats to let the watch know the game's over
                    connectivity.stopHeartbeats()
                }

                savingIsOn.toggle()
                
                // Save link to storage database
                if let fullGameId = fullGameId {
                    try await fgVideoRecordingModel.updateFGRecording(
                        endTime: Date(),
                        fgRecordingId: fullGameId,
                        gameId: gameId,
                        teamId: teamId,
                        localFile: videoURL
                    )
                }
                
                if isUsingWatch {
                    // Remove all recordings inside the GameRecordingsContext
                    dependencies.currentGameRecordingsContext = nil
                }
                
                // Remove all audio files saved locally
                removeAllAudioFilesLocally()
                
                // Go back to main page
                dismiss()
                savedRecording = true
            } catch {
                print("error", error.localizedDescription)
            }
        }
    }
    
    private func removeAllAudioFilesLocally() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent("audio/\(teamId)/\(gameId)")

        do {
            // Get all files in the directory
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)

            for fileURL in fileURLs {
                if fileURL.pathExtension == "m4a" {
                    do {
                        try fileManager.removeItem(at: fileURL)
                        print("✅ Deleted: \(fileURL.lastPathComponent)")
                    } catch {
                        print("❌ Failed to delete \(fileURL.lastPathComponent): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("⚠️ Could not list directory: \(error.localizedDescription)")
        }
    }
}
