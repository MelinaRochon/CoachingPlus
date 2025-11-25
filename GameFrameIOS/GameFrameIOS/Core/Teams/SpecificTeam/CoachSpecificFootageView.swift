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
    
    @StateObject private var gameModel = GameModel()
    
    @State private var dismissOnRemove: Bool = false
    
    /// Cache of thumbnails for key moments, keyed by keyMomentId
    @State private var thumbnails: [String: UIImage] = [:]
    @StateObject private var fgVideoRecordingModel = FGVideoRecordingModel()
    @State private var videoURL: URL?

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
//            ScrollView {
//                VStack {
//                    // Game details section
                HStack(alignment: .top) {
                    VStack {
                        //                            Text(game.title).font(.title2).multilineTextAlignment(.center)
                        //                            Text(team.teamNickname).font(.headline)
                        if let gameStartTime = gameStartTime {
                            Text(gameStartTime, style: .date).font(.subheadline).foregroundStyle(.secondary)
                        }
                        
                        Button {
                            isGameDetailsEnabled.toggle()
                        } label: {
                            Text("View Game Details").foregroundColor(Color.red).underline()
                        }
                        Divider()
                    }
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        // Full Game Recording Section
                        Section(header: VStack {
                            CustomUIFields.customDivider("Full Game Recording")
                                .padding(.top, 30)
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
                                        
                                        //                VStack (alignment: .leading, spacing: 4) {
                                        Text("Game Name")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        Spacer()
                                        
                                        HStack {
                                            Text("Watch")
                                            //                                .lineLimit(1)
                                            //                                .truncationMode(.tail)
                                                .foregroundStyle(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                            //                                .padding(.leading)
                                                .padding(.trailing, 5)
                                        }
                                    }
                                    .font(.callout)
                                    .frame(height: 40)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                        //                            .fill(.white)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        if let videoURL = videoURL, let keyMoments = keyMoments {
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
                                .padding(.top)
                                .background(Color(.systemBackground))
                            ) {
                                //                                if !keyMoments.isEmpty {
                                //                                    ForEach(keyMoments, id: \.id) { keyMoment in
                                //                                        HStack(alignment: .top) {
                                //                                            NavigationLink(destination: CoachSpecificKeyMomentView(game: game,
                                //                                                                                                   team: team,
                                //                                                                                                   specificKeyMoment: keyMoment,
                                //                                                                                                   videoUrl: videoURL)
                                //                                            ) {
                                //
                                //                                            }
                                //                                        }
                                //                                    }
                                //                            }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    
                                    // Display key moments if available
                                    //                                if let keyMoments = keyMoments {
                                    if !keyMoments.isEmpty {
                                        ForEach(keyMoments, id: \.id) { keyMoment in
                                            VStack { //}(alignment: .top) {
                                                NavigationLink(destination: CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: keyMoment, videoUrl: videoURL)) {
                                                    HStack {
                                                        if let image = thumbnails[keyMoment.keyMomentId] {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 110, height: 60)
                                                                .clipped()
                                                                .cornerRadius(10)
                                                        } else {
                                                            //                                                        Rectangle()
                                                            //                                                            .fill(Color.gray.opacity(0.3))
                                                            //                                                            .frame(width: 110, height: 60)
                                                            //                                                            .cornerRadius(10)
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
                                    } else {
                                        // key moments empty
                                        Text("No key moments.").font(.caption).foregroundColor(.secondary)
                                    }
                                    //                                }
                                }
                                //                                .padding()
                                //                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                                //                                    .padding(.horizontal).padding(.top)
                            }
                            
                            Section(header:
                                        CustomDividerWithNavigationLink(
                                            title: "Transcripts",
                                            subTitle: "See all",
                                            subTitleColor: .red,
                                            icon: "arrow.right"
                                        ) {
                                            CoachAllTranscriptsView(game: game, team: team)
                                        }
                                .padding(.top)
                                .background(Color(.systemBackground))
                            ) {
                                if let transcripts = transcripts {
                                    if !transcripts.isEmpty {
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
                                                                //                                                                    .padding(.top, 4)
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
                                    } else {
                                        // Transcripts empty
                                        Text("No transcripts.").font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                    Color.clear.frame(height: 75)
                }
                
//
//                    // Full game transcript section
//                    VStack(alignment: .leading, spacing: 0) {
//                        NavigationLink(destination: CoachFullGameTranscriptView(teamDocId: team.id, gameId: game.gameId, recordStartTime: game.startTime, gameTitle: game.title)) {
//                            Text("Full Game Recording")
//                                .font(.headline)
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text("Watch").foregroundColor(.gray)
//                            Image(systemName: "chevron.right").foregroundColor(.gray)
//                        }
//                    }.padding()
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
//                        .padding(.horizontal).padding(.top)
//                    
//                    if let videoURL = videoURL {
//                        // Key moments section
//                        VStack(alignment: .leading, spacing: 10) {
//                            
//                            NavigationLink(destination: CoachAllKeyMomentsView(game: game, team: team, videoUrl: videoURL)) {
//                                Text("Key moments")
//                                    .font(.headline)
//                                    .foregroundStyle(keyMomentsFound ? .black : .secondary)
//                                
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(keyMomentsFound ? .black : .secondary)
//                                Spacer()
//                                
//                            }.padding(.bottom, 4).disabled(!keyMomentsFound)
//                            
//                            
//                            // Display key moments if available
//                            if let keyMoments = keyMoments {
//                                if !keyMoments.isEmpty {
//                                    ForEach(keyMoments, id: \.id) { keyMoment in
//                                        HStack(alignment: .top) {
//                                            NavigationLink(destination: CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: keyMoment, videoUrl: videoURL)) {
//                                                if let image = thumbnails[keyMoment.keyMomentId] {
//                                                    Image(uiImage: image)
//                                                        .resizable()
//                                                        .scaledToFill()
//                                                        .frame(width: 110, height: 60)
//                                                        .clipped()
//                                                        .cornerRadius(10)
//                                                } else {
//                                                    Rectangle()
//                                                        .fill(Color.gray.opacity(0.3))
//                                                        .frame(width: 110, height: 60)
//                                                        .cornerRadius(10)
//                                                }
//                                                
//                                                VStack {
//                                                    HStack {
//                                                        if let gameStartTime = gameStartTime {
//                                                            let durationInSeconds = keyMoment.frameStart.timeIntervalSince(gameStartTime)
//                                                            Text(formatDuration(durationInSeconds)).font(.headline).bold().foregroundStyle(.black)
//                                                            Spacer()
//                                                        }
//                                                    }
//                                                    Text(keyMoment.transcript).font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black).lineLimit(2)
//                                                }
//                                            }
//                                        }
//                                    }
//                                } else {
//                                    // key moments empty
//                                    Text("No key moments.").font(.caption).foregroundColor(.secondary)
//                                }
//                            }
//                        }.padding()
//                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
//                            .padding(.horizontal).padding(.top)
//                    }
//                    // Transcript section
//                    VStack(alignment: .leading, spacing: 10) {
//                        
//                        NavigationLink(destination: CoachAllTranscriptsView(game: game, team: team)) {
//                            Text("Transcript")
//                                .font(.headline)
//                                .foregroundStyle(transcriptsFound ? .black : .secondary)
//                            
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(transcriptsFound ? .black : .secondary)
//                            Spacer()
//                            
//                        }
//                        .padding(.bottom, 4)
//                        .disabled(!transcriptsFound)
//                        
//                        // Display available transcripts
//                        if let transcripts = transcripts {
//                            if !transcripts.isEmpty {
//                                ForEach(transcripts, id: \.id) { recording in
//                                    HStack(alignment: .center) {
//                                        NavigationLink(destination: CoachSpecificTranscriptView(game: game, team: team, transcript: recording)) {
//                                            HStack(alignment: .center) {
//                                                if let gameStartTime = gameStartTime {
//                                                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
//                                                    Text(formatDuration(durationInSeconds)).bold().font(.headline).foregroundColor(Color.black)
//                                                    Spacer()
//                                                    Text("\(recording.transcript)")
//                                                        .font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(2).padding(.top, 4).foregroundColor(Color.black)
//                                                }
//                                            }.tag(recording.id as Int)
//                                        }
//                                    }
//                                }
//                            } else {
//                                // Transcripts empty
//                                Text("No transcripts.").font(.caption).foregroundColor(.secondary)
//                            }
//                        }
//                    }.padding()
//                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
//                        .padding(.horizontal).padding(.top)
//                }
            }
//            .navigationTitle(game.title)
//            .toolbarTitleDisplayMode(.inline)
//            .navigationSubtitle(team.teamNickname)

            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    if let startTime = game.startTime {
                        gameStartTime = startTime
                    }
                    
                    let (tmpTranscripts, tmpKeyMom) = try await transcriptModel.getPreviewTranscriptsAndKeyMoments(gameId: game.gameId, teamDocId: team.id)
                    
                    self.transcripts = tmpTranscripts
                    self.keyMoments = tmpKeyMom
                    
                    if let allTranscripts = transcripts {
                        if !allTranscripts.isEmpty {
                            transcriptsFound = true
                        }
                    }
                    
                    // Get the full game video path
                    guard let videoPath = try await fgVideoRecordingModel.getFGRecordingVideoUrl(teamDocId: team.id, gameId: game.gameId) else {
                        print("error with videoPath for \(team.id), \(game.gameId)")
                        return
                    }
                    
                    let storageRef = StorageManager.shared.getAudioURL(path: videoPath)
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("❌ Failed to get stream URL: \(error.localizedDescription)")
                        } else if let url = url {
                            print("✅ download url is: \(url)")
                            self.videoURL = url
                            if let allKeyMoments = keyMoments {
                                print("key moments found")
                                if !allKeyMoments.isEmpty {
                                    keyMomentsFound = true
                                }
                                
                                // Get the thumbail for each key moments
                                for keyMoment in allKeyMoments {
                                    print("are we at least passing here")
                                    // TODO: Add time before feedback? possibly for the thumbnail
                                    if let gameStartTime = gameStartTime {
                                        print("generating a thumbnail")
                                        let startTime = keyMoment.frameStart.timeIntervalSince(gameStartTime)
                                        generateThumbnail(for: url, key: keyMoment.keyMomentId, sec: startTime)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled, onDismiss: refreshData) {
                GameDetailsView(selectedGame: game, team: team, userType: .coach, dismissOnRemove: $dismissOnRemove)
            }
            .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                Color.clear.frame(height: 75)
            }
            .onChange(of: dismissOnRemove) {
                Task {
                    do {
                        // Remove game from database and from all players
                        try await gameModel.removeGame(gameId: game.gameId, teamDocId: team.id, teamId: team.teamId)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .onAppear {
                transcriptModel.setDependencies(dependencies)
                gameModel.setDependencies(dependencies)
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
                
                let tmpGame = game
                game = try await gameModel.getGame(teamId: team.teamId, gameId: game.gameId) ?? tmpGame
                
                if let startTime = game.startTime {
                    gameStartTime = startTime
                }
                
                let (tmpTranscripts, tmpKeyMom) = try await transcriptModel.getPreviewTranscriptsAndKeyMoments(gameId: game.gameId, teamDocId: team.id)
                
                self.transcripts = tmpTranscripts
                self.keyMoments = tmpKeyMom
                
                if let allTranscripts = transcripts {
                    if !allTranscripts.isEmpty {
                        transcriptsFound = true
                    }
                }
                
                if let allKeyMoments = keyMoments {
                    if !allKeyMoments.isEmpty {
                        keyMomentsFound = true
                    }
                }
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    CoachSpecificFootageView(game: game, team: team)
}
