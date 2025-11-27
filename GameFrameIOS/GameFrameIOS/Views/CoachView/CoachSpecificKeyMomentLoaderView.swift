//
//  CoachSpecificKeyMomentLoaderView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-23.
//

import SwiftUI
import GameFrameIOSShared

/// Loads DBTeam, DBGame and keyMomentTranscript from ids,
/// then shows either:
/// - `CoachSpecificKeyMomentView` if a video URL exists, or
/// - `CoachSpecificTranscriptView` if there is no video.
struct CoachSpecificKeyMomentLoaderView: View {
    @EnvironmentObject private var dependencies: DependencyContainer
    
    let teamId: String
    let gameId: String
    let keyMomentId: String
    
    @State private var team: DBTeam?
    @State private var game: DBGame?
    @State private var keyMoment: keyMomentTranscript?
    @State private var videoUrl: URL?      // optional: nil means “no video available”
    @State private var isLoading = true
    @State private var error: String?
    
    init(teamId: String, gameId: String, keyMomentId: String) {
        self.teamId = teamId
        self.gameId = gameId
        self.keyMomentId = keyMomentId
        
        print("CoachSpecificKeyMomentLoaderView init")
        print("   teamId: \(teamId)")
        print("   gameId: \(gameId)")
        print("   keyMomentId: \(keyMomentId)")
    }
    
    var body: some View {
        content
            .task {
                await load()
            }
    }
    
    // MARK: - View content
    
    @ViewBuilder
    private var content: some View {
        if let error {
            Text("Error: \(error)")
        } else if isLoading {
            ProgressView("Loading key moment…")
        } else if let team, let game, let keyMoment {
            // Decide which detail view to show based on presence of a video URL
            if let videoUrl {
                CoachSpecificKeyMomentView(
                    game: game,
                    team: team,
                    specificKeyMoment: keyMoment,
                    videoUrl: videoUrl
                )
            } else {
                // No associated video → fall back to transcript-only view
                CoachSpecificTranscriptView(
                    game: game,
                    team: team,
                    transcript: keyMoment
                )
            }
        } else {
            // Shouldn’t really happen, but keeps the compiler happy
            EmptyView()
        }
    }

    // MARK: - Loading

    @MainActor
    private func load() async {
        do {
            let teamDocId = teamId
            // 1) Load team using the teamId passed into the loader
            let teamObj = try await dependencies.teamManager.getTeamWithDocId(docId: teamDocId)
            let teamId = teamObj.teamId
            
            // 2) Load game
            guard let gameObj = try await dependencies.gameManager.getGame(
                gameId: gameId,
                teamId: teamId
            ) else {
                self.error = "Game not found."
                self.isLoading = false
                return
            }

            // 3) Use TranscriptModel to build keyMomentTranscript objects
            let transcriptModel = TranscriptModel()
            transcriptModel.setDependencies(dependencies)

            let allKeyMoments = try await transcriptModel.getAllTranscripts(
                gameId: gameId,
                teamDocId: teamDocId
            ) ?? []
            
            print("🔍 Loader – keyMoment from notification: \(keyMomentId)")
            print("🔍 Loaded \(allKeyMoments.count) key moments for game \(gameId)")

            for km in allKeyMoments {
                print("   ↳ keyMomentTranscript: keyMomentId=\(km.keyMomentId)")
            }

            // 4) Pick the key moment matching our keyMomentId
            guard let kmObj = allKeyMoments.first(where: { $0.keyMomentId == keyMomentId }) else {
                self.error = "Key moment not found."
                self.isLoading = false
                return
            }

            // Set base state (so we always have data for transcript view)
            self.team = teamObj
            self.game = gameObj
            self.keyMoment = kmObj

            // 5) Try to resolve full-game video URL
            let fgRecordingModel = FGVideoRecordingModel()
            fgRecordingModel.setDependencies(dependencies)

            do {
                if let videoPath = try await fgRecordingModel.getFGRecordingVideoUrl(
                    teamDocId: teamDocId,
                    gameId: gameId
                ) {
                    print("🎥 Found video path: \(videoPath)")
                    
                    // Convert Firebase Storage path -> HTTPS download URL
                    let storageRef = StorageManager.shared.getAudioURL(path: videoPath)
                    let downloadURL: URL = try await withCheckedThrowingContinuation { continuation in
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
                    
                    print("✅ Resolved full-game video URL: \(downloadURL)")
                    self.videoUrl = downloadURL
                } else {
                    print("ℹ️ No full-game video path found: will show transcript-only view.")
                }
            } catch {
                // If video fails, we just log and fall back to transcript view
                print("❌ Failed to resolve full-game video, falling back to transcript view: \(error)")
            }

            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
}
