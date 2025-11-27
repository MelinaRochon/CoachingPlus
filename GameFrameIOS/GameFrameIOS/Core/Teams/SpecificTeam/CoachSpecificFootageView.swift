//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import AVFoundation
import GameFrameIOSShared

/**
 `CoachSpecificFootageView` is a SwiftUI view designed for soccer coaches to review game footage,
 transcripts, and key moments after a match.

 ## Overview:
 This view provides a structured interface for coaches to:
 - View basic game details such as title, team name, and start time.
 - Access the full game transcript.
 - Browse and review key moments recorded during the match.
 - See individual transcripts of specific game segments.
 - Open a detailed game information view.
  
 The view dynamically loads game-related data, including transcripts and key moments, when it appears.

 ## Main Components:
 1. **Game Details Section**
    - Displays the game title, team nickname, and start time.
    - Includes a button to view additional game details in a modal.

 2. **Full Game Transcript Section**
    - Provides access to a complete game transcript via `CoachFullGameTranscriptView`.

 3. **Key Moments Section**
    - Shows a list of recorded key moments, each linked to `CoachSpecificKeyMomentView`.
    - If no key moments are found, a placeholder message is displayed.

 4. **Transcripts Section**
    - Lists individual transcripts of specific moments, with navigation to `CoachSpecificTranscriptView`.
    - Displays a message if no transcripts are available.

 5. **Data Fetching & State Management**
    - Uses `TranscriptModel` to asynchronously fetch transcripts and key moments.
    - Tracks whether key moments and transcripts exist using state variables (`keyMomentsFound`, `transcriptsFound`).
 
 This view is designed to be navigable and user-friendly, allowing coaches to quickly access and analyze game footage and feedback.
 */
struct CoachSpecificFootageView: View {
    
    /// ViewModel for handling transcript-related data operations.
    @StateObject private var transcriptModel = TranscriptModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// The start time of the game, used for timestamp calculations.
    @State private var gameStartTime: Date?
    
    /// Controls whether the game details view is presented.
    @State private var isGameDetailsEnabled: Bool = false
    
    /// Flags indicating whether key moments and transcripts were found.
    @State private var keyMomentsFound: Bool = false
    @State private var transcriptsFound: Bool = false
    
    /// The game and team associated with this footage.
    @State var game: DBGame
    @State var team: DBTeam
    
    /// Stores retrieved transcripts and key moments.
    @State private var transcripts: [keyMomentTranscript]?
    @State private var keyMoments: [keyMomentTranscript]?
    
    @StateObject var gameModel: GameModel

    @State private var dismissOnRemove: Bool = false
    
    /// Cache of thumbnails for key moments, keyed by keyMomentId
    @State private var thumbnails: [String: UIImage] = [:]
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @State private var videoURL: URL?
    
    @State private var isLoadingKeyMoments: Bool = false
    @State private var isLoadingTranscripts: Bool = false
    
    @State private var isLoadingContent: Bool = false

    private var isStillLoading: Bool {
        isLoadingContent || transcripts == nil || keyMoments == nil
    }
    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @State private var gameName: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(game.title).font(Font.title.bold()).padding(.horizontal, 15)
                        if let gameStartTime = gameStartTime {
                            Text(formatStartTime(gameStartTime)).font(.subheadline).foregroundStyle(.secondary).padding(.horizontal, 15)
                        }

                        Divider()
                    }
                }
                
                if isLoadingContent {
                    VStack {
                        ProgressView("Loading feedback...")
                            .padding()
                            .background(.white)
                            .cornerRadius(12)
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                            if let videoURL = videoURL {
                                // Full Game Recording Section
                                Section(header: VStack {
                                    CustomUIFields.customDivider("Full Game Recording")
                                        .padding(.top, 15)
                                }.background(Color(.systemBackground))) {
                                    VStack {
                                        NavigationLink(destination: CoachFullGameTranscriptView(teamDocId: team.id,
                                                                                                gameId: game.gameId,
                                                                                                recordStartTime: game.startTime,
                                                                                                gameTitle: game.title)
                                        ) {
                                            HStack {
                                                Image(systemName: "video.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.red)
                                                    .padding(.horizontal, 5)
                                                
                                                Text("Game Name")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(2)
                                                    .foregroundStyle(.black)
                                                Spacer()
                                                
                                                HStack {
                                                    Text("Watch")
                                                        .foregroundStyle(.gray)
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                                        .padding(.trailing, 5)
                                                }
                                            }
                                            .font(.callout)
                                            .frame(height: 40)
                                            .padding(.horizontal)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                                
                                if let keyMoments = keyMoments, !keyMoments.isEmpty {
                                    // Key moments section
                                    Section(header:
                                                CustomDividerWithNavigationLink(
                                                    title: "Key Moments",
                                                    subTitle: "See all",
                                                    subTitleColor: .red,
                                                    icon: "arrow.right"
                                                ) {
                                                    CoachAllKeyMomentsView(game: game, team: team, videoUrl: videoURL)
                                                }
                                        .background(Color(.systemBackground))
                                    ) {
                                        ForEach(keyMoments, id: \.id) { keyMoment in
                                            VStack {
                                                NavigationLink(destination: CoachSpecificKeyMomentView(game: game,
                                                                                                       team: team,
                                                                                                       specificKeyMoment: keyMoment,
                                                                                                       videoUrl: videoURL)
                                                ) {
                                                    HStack {
                                                        if let image = thumbnails[keyMoment.keyMomentId] {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 110, height: 60)
                                                                .clipped()
                                                                .cornerRadius(10)
                                                        } else {
                                                            Rectangle()
                                                                .fill(Color(uiColor: .systemFill))
                                                                .frame(width: 110, height: 60)
                                                                .cornerRadius(10)
                                                                .overlay(
                                                                    Image(systemName: "video.slash")
                                                                        .font(.title)   // size of icon
                                                                        .foregroundColor(.gray)
                                                                )
                                                        }
                                                        
                                                        VStack {
                                                            if let gameStartTime = gameStartTime {
                                                                let durationInSeconds = keyMoment.frameStart.timeIntervalSince(gameStartTime)
                                                                Text(formatDuration(durationInSeconds))
                                                                    .font(.headline)
                                                                    .bold()
                                                                    .foregroundStyle(.black)
                                                                    .multilineTextAlignment(.leading)
                                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                            }
                                                            
                                                            Text(keyMoment.transcript)
                                                                .font(.caption)
                                                                .multilineTextAlignment(.leading)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .foregroundStyle(.black)
                                                                .lineLimit(2)
                                                        }
                                                        Spacer()
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.gray)
                                                            .padding(.leading)
                                                            .padding(.trailing, 5)
                                                    }
                                                    
                                                }
                                                Divider()
                                                
                                            }
                                        }
                                    }
                                } else if !isStillLoading {
                                    CustomUIFields.customDivider("Key Moments")
                                        .padding(.top, 15)
                                    
                                    // Transcripts empty
                                    VStack(alignment: .center) {
                                        Image(systemName: "video.slash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                        
                                        Text("No key moments were found at this time.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 15)
                                }
                            }
                            
                            if let transcripts = transcripts, !transcripts.isEmpty {
                                Section(header:
                                            CustomDividerWithNavigationLink(
                                                title: "Transcripts",
                                                subTitle: "See all",
                                                subTitleColor: .red,
                                                icon: "arrow.right"
                                            ) {
                                                CoachAllTranscriptsView(game: game, team: team)
                                            }
                                    .background(Color(.systemBackground))
                                ) {
                                    ForEach(transcripts, id: \.id) { recording in
                                        if let gameStartTime = gameStartTime {
                                            VStack {
                                                NavigationLink(destination: CoachSpecificTranscriptView(game: game,
                                                                                                        team: team,
                                                                                                        transcript: recording)
                                                ) {
                                                    HStack {
                                                        Image(systemName: "waveform.and.mic")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 30, height: 30)
                                                            .padding(.horizontal, 5)
                                                        
                                                        VStack(spacing: 4) {
                                                            let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                                                            Text(formatDuration(durationInSeconds))
                                                                .bold()
                                                                .font(.headline)
                                                                .foregroundColor(Color.black)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                            Text("\(recording.transcript)")
                                                                .font(.caption)
                                                                .multilineTextAlignment(.leading)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                                .lineLimit(2)
                                                                .foregroundColor(Color.black)
                                                        }
                                                        Spacer()
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.gray)
                                                            .padding(.leading)
                                                            .padding(.trailing, 5)
                                                        
                                                    }.tag(recording.id as Int)
                                                        .padding(.vertical, 2)
                                                }
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            } else if !isStillLoading {
                                // Transcripts empty
                                CustomUIFields.customDivider("Transcripts")
                                    .padding(.top, 15)

                                if videoURL == nil, !transcriptsFound && !keyMomentsFound {
                                    // Working with only audio transcripts, show error
                                    VStack(alignment: .center) {
                                        Image(systemName: "microphone.slash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                        Text("No transcripts were found at this time.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text("Consider removing this game since it doesn't contain any feedback")
                                            .font(.footnote) .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 15)
                                } else {
                                    // Text("No transcripts were found.").font(.caption).foregroundColor(.secondary)
                                    VStack(alignment: .center) {
                                        Image(systemName: "microphone.slash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                        Text("No transcripts were found at this time.").font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 15)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                        Color.clear.frame(height: 90)
                    }

                    
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                isLoadingContent = true
                gameName = game.title
                
                if let startTime = game.startTime {
                    gameStartTime = startTime
                }
                
                async let transcriptsTask = transcriptModel.getPreviewTranscriptsAndKeyMoments(
                    gameId: game.gameId,
                    teamDocId: team.id
                )
                
                async let videoPathTask = fgVideoRecordingModel.getFGRecordingVideoUrl(
                    teamDocId: team.id,
                    gameId: game.gameId
                )
                
                do {
                    
                    // 3. Await transcripts and keymoments
                    let (tmpTranscripts, tmpKeyMoments) = try await transcriptsTask
                    self.transcripts = tmpTranscripts
                    self.keyMoments = tmpKeyMoments
                    
                    // Set the flags
                    transcriptsFound = !(tmpTranscripts?.isEmpty ?? true)
                    keyMomentsFound = !(tmpKeyMoments?.isEmpty ?? true)
                    
                    // 4. Await the video path
                    guard let videoPath = try await videoPathTask else {
                        print("❌ Error: No videoPath found for \(team.id), \(game.gameId)")
                        isLoadingContent = false
                        return
                    }
                    
                    // 5. Convert to async URL fetch instead of callback
                    let storageRef = StorageManager.shared.getAudioURL(path: videoPath)
                    let url: URL = try await withCheckedThrowingContinuation { continuation in
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let url = url {
                                continuation.resume(returning: url)
                            } else {
                                continuation.resume(throwing: URLError(.badURL))
                            }
                        }
                    }
                    
                    self.videoURL = url
                    print("✅ Download URL: \(url)")
                    
                    // 6. Generate thumbnails for key moments
                    if let allKeyMoments = tmpKeyMoments,
                       let gameStartTime = self.gameStartTime {
                        
                        for moment in allKeyMoments {
                            let startSec = moment.frameStart.timeIntervalSince(gameStartTime)
                            await generateThumbnail(for: url, key: moment.keyMomentId, sec: startSec)
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
                
                isLoadingContent = false
            }
            .onChange(of: game.title) {
                print("RESET gameModel.lastDoc because game.title changed")
                gameModel.lastDoc = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", systemImage: "trash") {
                        dismissOnRemove = true
                    }
                }
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isGameDetailsEnabled.toggle()
                    } label: {
                        Image(systemName: "info")
                    }
                }
            }
            .alert(
                "Are you sure you want to delete this game? This will remove all feedback associated with it.",
                isPresented: $dismissOnRemove
                
            ) {
                Button(role: .destructive, action: {
                    Task {
                        do {
                            // Remove game from database and from all players
                            try await gameModel.removeGame(gameId: game.gameId, teamDocId: team.id, teamId: team.teamId)
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }) {
                    Text("Delete")
                }
                Button(role: .cancel, action: {
                    dismissOnRemove = false
                }) {
                    Text("Cancel")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled, onDismiss: refreshData) {
                GameDetailsView(selectedGame: game, team: team, userType: .coach, dismissOnRemove: $dismissOnRemove, gameTitle: $gameName)
            }
            .onAppear {
                transcriptModel.setDependencies(dependencies)
                fgVideoRecordingModel.setDependencies(dependencies)
            }
        }
    }
    
    private func generateThumbnail(for url: URL, key: String, sec: Double) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: sec, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    thumbnails[key] = uiImage
                }
            } catch {
                print("❌ Failed to generate thumbnail for \(key): \(error.localizedDescription)")
            }
        }
    }
    
    private func refreshData() {
        Task {
            do {
                keyMomentsFound = false
                transcriptsFound = false
                isLoadingContent = true

                // 1. Refresh game info
                let previousGame = game
                game = try await gameModel.getGame(
                    teamId: team.teamId,
                    gameId: previousGame.gameId
                ) ?? previousGame
                if let start = game.startTime {
                    gameStartTime = start
                }

                // 2. Load transcripts + key moments in parallel
                let (tmpTranscripts, tmpKeyMoments) = try await transcriptModel
                    .getPreviewTranscriptsAndKeyMoments(
                        gameId: game.gameId,
                        teamDocId: team.id
                    )

                // 3. Assign values
                self.transcripts = tmpTranscripts
                self.keyMoments  = tmpKeyMoments

                // 4. Update flags
                transcriptsFound = !(tmpTranscripts?.isEmpty ?? true)
                keyMomentsFound  = !(tmpKeyMoments?.isEmpty ?? true)
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
            
            isLoadingContent = false
        }
    }
}

//#Preview {
//    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
//    
//    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
//    
//    CoachSpecificFootageView(game: game, team: team, gameModel: GameModel())
//}
