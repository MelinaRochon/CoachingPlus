//
//  NotificationsViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-02.
//

import Foundation
import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var recentComments: [DBComment] = []
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Dependencies (injected as async closures)
    private let loadTeamsOwnedByCoach: (_ coachId: String) async throws -> [DBTeam]
    private let fetchRecentCommentsForTeams: (_ teamDocIds: [String], _ since: Date) async throws -> [DBComment]

    /// Designated initializer with sensible defaults (no singletons required).
    /// - Parameters:
    ///   - loadTeamsOwnedByCoach: async function that returns teams owned by coach
    ///   - fetchRecentCommentsForTeams: async function that returns recent comments for team doc IDs since a date
    init(
        loadTeamsOwnedByCoach: @escaping (_ coachId: String) async throws -> [DBTeam] = { coachId in
            // Default: call your concrete manager directly
            try await TeamManager().getTeamsOwnedByCoach(coachId: coachId)
        },
        fetchRecentCommentsForTeams: @escaping (_ teamDocIds: [String], _ since: Date) async throws -> [DBComment] = { teamDocIds, since in
            // Default: use the Firestore repository directly
            try await FirestoreCommentRepository().fetchRecentComments(forTeamDocIds: teamDocIds, since: since)
        }
    ) {
        self.loadTeamsOwnedByCoach = loadTeamsOwnedByCoach
        self.fetchRecentCommentsForTeams = fetchRecentCommentsForTeams
    }

    /// Loads comments from the last 7 days for all teams owned by the coach.
    func loadLastWeekComments(coachId: String) async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            // 1) Get this coach’s team *doc IDs* (assumes DBTeam.id is the document id)
            let teams = try await loadTeamsOwnedByCoach(coachId)
            let teamDocIds = teams.map { $0.id }

            // 2) Last 7 days
            let since = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                        ?? Date().addingTimeInterval(-7 * 24 * 3600)

            // 3) Fetch comments
            let comments = try await fetchRecentCommentsForTeams(teamDocIds, since)
            recentComments = comments
        } catch {
            self.error = (error as NSError).localizedDescription
        }
    }
}
