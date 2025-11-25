//
//  NotificationsViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-02.
//

import Foundation
import SwiftUI
import GameFrameIOSShared

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var recentComments: [DBComment] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var gameTitles: [String: String] = [:]   // gameId -> title
    @Published var authorNames: [String: String] = [:]  // authorId -> "First Last"
    @Published var teamIdsByGame: [String: String] = [:] // 👈 NEW: gameId -> teamId

    private var dependencies: DependencyContainer?
    private let teamModel = TeamModel()
    private let gameModel = GameModel()

    // MARK: - Dependency Injection
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
        teamModel.setDependencies(dependencies)
        gameModel.setDependencies(dependencies)
    }

    func loadCoachLastWeekComments(coachId: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return
        }

        do {
            // 0) Logged-in coach (current user)
            let authUser = try repo.authenticationManager.getAuthenticatedUser()
            let currentCoachId = authUser.uid

            // 1) Get this coach’s teams
            let teams = try await repo.teamManager.getTeamsWithCoach(coachId: coachId)
            let teamDocIds = teams.map { $0.id }

            // 2) Last 7 days
            let since = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                        ?? Date().addingTimeInterval(-7 * 24 * 3600)

            // 3) Fetch all recent comments for those teams
            let comments = try await repo.commentManager
                .fetchRecentComments(forTeamDocIds: teamDocIds, since: since)

            // 4) Filter out comments written by the logged-in coach
            let filtered = comments.filter { $0.uploadedBy != currentCoachId }

            recentComments = filtered

            // 5) Resolve game titles + author names based on the filtered list
            await resolveMetadata()

        } catch {
            self.error = (error as NSError).localizedDescription
        }
    }

    func loadPlayerLastWeekComments(playerId: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        guard let repo = dependencies else {
            print("⚠️ Dependencies not set")
            return
        }

        do {
            // 1) Get player’s teams
            guard let teams = try await repo.playerManager.getAllTeamsEnrolled(playerId: playerId),
                      !teams.isEmpty else {
                        print("No teams enrolled")
                        recentComments = []
                        return
                    }
            
            // Use the Firestore team document IDs
            let teamDocIds = teams.map(\.id)
            
            // 2) Last 7 days
            let since = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                        ?? Date().addingTimeInterval(-7 * 24 * 3600)

            // 3) Fetch recent comments for these teams
            let comments = try await repo.commentManager
                .fetchRecentComments(forTeamDocIds: teamDocIds, since: since)

            // 4) Keep only:
            //    - comments NOT written by the player
            //    - comments whose key moment belongs to THIS player
            let filtered = try await filterCommentsForPlayerKeyMoments(
                comments,
                playerId: playerId
            )

            recentComments = filtered

            // 5) Resolve the metadata so UI can show names, game titles, etc.
            await resolveMetadata()

        } catch {
            self.error = (error as NSError).localizedDescription
        }
    }


    private func resolveMetadata() async {
        guard let deps = dependencies else { return }

        var titles: [String: String] = [:]
        var authors: [String: String] = [:]
        var teamIds: [String: String] = [:]

        for comment in recentComments {
            let gameId = comment.gameId
            let authorId = comment.uploadedBy    // e.g. comment.authorId / comment.userId

            // --- Game title + teamId ---
            if titles[gameId] == nil || teamIds[gameId] == nil {
                if let teamId = try? await teamModel.getTeamIdForGameId(gameId) {
                    teamIds[gameId] = teamId

                    if let title = try? await gameModel.getGameTitle(teamId: teamId, gameId: gameId) {
                        titles[gameId] = title
                    }
                }
            }

            // --- Author name ---
            if authors[authorId] == nil {
                if let user = try? await deps.userManager.getUser(userId: authorId) {
                    // adjust names if your DBUser uses other property names
                    let name = "\(user.firstName) \(user.lastName)"
                    authors[authorId] = name
                }
            }
        }

        gameTitles = titles
        authorNames = authors
        teamIdsByGame = teamIds
    }
    
    private func filterCommentsForPlayerKeyMoments(
        _ comments: [DBComment],
        playerId: String
    ) async throws -> [DBComment] {
        guard let deps = dependencies else { return [] }

        var result: [DBComment] = []

        for comment in comments {
            
            // Skip own comments
            if comment.uploadedBy == playerId {
                continue
            }
            
            let gameId = comment.gameId
            let keyMomentDocId = comment.keyMomentId

            // Derive teamId from gameId (like you already do in resolveMetadata)
            guard let teamId = try? await teamModel.getTeamIdForGameId(gameId) else {
                continue
            }

            // Fetch key moment
            guard let keyMoment = try? await deps.keyMomentManager.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentDocId) else {
                continue
            }

            // Keep only key moments that belong to this player
            if ((keyMoment.feedbackFor?.contains(playerId)) != nil) {
                result.append(comment)
            }
        }

        return result
    }


}

