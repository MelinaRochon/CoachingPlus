//
//  PlayerSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI
import AVFoundation
import GameFrameIOSShared

/**
 This view is responsible for displaying detailed footage and related information for a specific game within a team. It is designed for players to view their individual game footage, transcripts, and key moments.

 Key responsibilities:
 - Displays game details, including the title, team nickname, and start time.
 - Allows the user (player) to view the full game transcript and specific key moments from the game.
 - Displays a list of key moments and transcripts with related time codes and player involvement.
 - The user can tap on each key moment or transcript to navigate to more detailed views.
 - The player can view specific game details by navigating to a modal view that displays further information about the game.
 - The view model handles fetching all transcripts and key moments for the game and team, updating the UI accordingly.
 - If no transcripts or key moments are available, appropriate messages will be shown to inform the user.
 
 The view is structured to ensure the player can easily navigate between various sections, such as full game transcripts, key moments, and specific player recordings from the game.

 **Functions:**
 - `task`: Used to fetch the game’s start time, transcripts, and key moments as soon as the view appears. It populates the UI with relevant data, and if key moments or transcripts are found, it updates the state variables accordingly.
 - `isGameDetailsEnabled`: A state that controls the visibility of a sheet showing detailed game information when tapped.
 
 This view serves as a way for players to review detailed aspects of their gameplay, with options to view game summaries, key moments, and the full transcript of the game. It is built to be user-friendly, ensuring that players can easily access and review their performance based on the provided footage and annotations.

*/
struct PlayerSpecificFootageView: View {
    
    /// A view model for managing and fetching the transcripts and key moments of the game.
    @StateObject private var transcriptModel = TranscriptModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Holds the start time of the game, used to calculate the timestamp for each key moment or transcript.
    @State private var gameStartTime: Date?

    /// A boolean flag that controls the visibility of the game details sheet.
    @State private var isGameDetailsEnabled: Bool = false

    /// A flag to track if key moments have been found for the game.
    @State private var keyMomentsFound: Bool = false

    /// A flag to track if transcripts have been found for the game.
    @State private var transcriptsFound: Bool = false

    /// The specific game for which the footage and related data is being displayed.
    @State var game: DBGame

    /// The team associated with the game and whose players' footage is being displayed.
    @State var team: DBTeam

    /// Holds the list of transcripts for the game.
    @State private var transcripts: [keyMomentTranscript]?

    /// Holds the list of key moments for the game.
    @State private var keyMoments: [keyMomentTranscript]?
    
    /// Cache of thumbnails for key moments, keyed by keyMomentId
    @State private var thumbnails: [String: UIImage] = [:]
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @State private var videoURL: URL?
    @State private var gameTitle: String = ""

    @State private var isLoadingContent: Bool = false

    private var isStillLoading: Bool {
        isLoadingContent || transcripts == nil || keyMoments == nil
    }


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
                                        NavigationLink(destination: PlayerFullGameTranscriptView(
                                            teamDocId: team.id,
                                            gameId: game.gameId,
                                            recordStartTime: game.startTime,
                                            gameTitle: game.title
                                        )) {
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
                                                    PlayerAllKeyMomentsView(game: game, team: team, videoUrl: videoURL)
                                                }
                                        .background(Color(.systemBackground))
                                    ) {
                                        ForEach(keyMoments, id: \.id) { keyMoment in
                                            VStack(alignment: .center) {
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
                                        
                                        Text("No key moments assigned to you were found at this time.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
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
                                                PlayerAllTranscriptsView(game: game, team: team)
                                            }
                                    .background(Color(.systemBackground))
                                ) {
                                    ForEach(transcripts, id: \.id) { recording in
                                        if let gameStartTime = gameStartTime {
                                            VStack {
                                                NavigationLink(destination: PlayerSpecificTranscriptView(game: game, team: team, transcript: recording)
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
                                
                                VStack(alignment: .center) {
                                    Image(systemName: "microphone.slash.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                    Text("No transcripts assigned to you were found at this time.").font(.subheadline).foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                                .padding(.horizontal, 15)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                        Color.clear.frame(height: 90)
                    }
                }
                
                Spacer()
            }
            
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                isLoadingContent = true
                gameTitle = game.title
                
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
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(selectedGame: game, team: team, userType: .player, dismissOnRemove: .constant(false), gameTitle: $gameTitle)
            }
            .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                Color.clear.frame(height: 75)
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

}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    PlayerSpecificFootageView(game: game, team: team)
}
