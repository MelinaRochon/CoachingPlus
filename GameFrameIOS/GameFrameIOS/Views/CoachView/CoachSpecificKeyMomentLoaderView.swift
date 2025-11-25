//
// CoachSpecificKeyMomentLoaderView.swift
// GameFrameIOS
//
// Created by Caterina Bosi on 2025-11-23.
//

import SwiftUI
import GameFrameIOSShared

/// Loads DBTeam, DBGame and keyMomentTranscript from ids,
/// then shows `CoachSpecificKeyMomentView`.
struct CoachSpecificKeyMomentLoaderView: View {
    @EnvironmentObject private var dependencies: DependencyContainer

    let teamId: String
    let gameId: String
    let keyMomentId: String

    @State private var team: DBTeam?
    @State private var game: DBGame?
    @State private var keyMoment: keyMomentTranscript?
    @State private var videoUrl: URL?      // we’ll resolve this later
    @State private var isLoading = true
    @State private var error: String?

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
        } else if let team, let game, let keyMoment, let videoUrl {
            CoachSpecificKeyMomentView(
                game: game,
                team: team,
                specificKeyMoment: keyMoment,
                videoUrl: videoUrl
            )
        } else {
            // Shouldn’t really happen, but keeps the compiler happy
            EmptyView()
        }
    }

    // MARK: - Loading

    @MainActor
    private func load() async {
        do {
            // 1) Load team using the teamId passed into the loader
            guard let teamObj = try await dependencies.teamManager.getTeam(teamId: teamId) else {
                self.error = "Team not found."
                self.isLoading = false
                return
            }
            let teamDocId = teamObj.id

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

            // IMPORTANT: use the *document id* here
            let allKeyMoments = try await transcriptModel.getAllTranscripts(
                gameId: gameId,
                teamDocId: teamDocId
            ) ?? []

            // 4) Pick the key moment matching our keyMomentId
            let kmObj = allKeyMoments.first { $0.keyMomentId == keyMomentId }

            // 5) TODO: replace with real video URL logic
            let dummyUrl = URL(string: "https://example.com/video.mp4")!

            // 6) Update state
            self.team = teamObj
            self.game = gameObj
            self.keyMoment = kmObj
            self.videoUrl = dummyUrl
            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
}
