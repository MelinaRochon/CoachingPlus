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

    func loadLastWeekComments(coachId: String) async {
        isLoading = true; error = nil
        do {
            // 1) Get this coach’s team *doc IDs* (adjust to your API)
            let teams = try await TeamManager.shared.getTeamsOwnedByCoach(coachId: coachId)
            let teamDocIds = teams.map { $0.id }   // assuming your DBTeam has `id`

            // 2) Last 7 days
            let since = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date().addingTimeInterval(-7*24*3600)

            // 3) Fetch from CommentManager
            let comments = try await CommentManager.shared.fetchRecentComments(forTeamDocIds: teamDocIds, since: since)
            recentComments = comments
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
