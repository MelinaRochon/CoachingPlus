//
//  CoachNotificationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***
 This structure is the recent activity view. All the recent acitivities made in the app (all types of notifications) will be shown here.
 */
struct CoachNotificationView: View {
    @StateObject private var vm = NotificationsViewModel()
    let coachId: String // inject from session/auth

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading last 7 days…")
                } else if let err = vm.error {
                    VStack(spacing: 8) {
                        Text("Couldn’t load activity").font(.headline)
                        Text(err).font(.footnote).foregroundStyle(.secondary)
                        Button("Retry") { Task { await vm.loadLastWeekComments(coachId: coachId) } }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 4)
                    }
                } else if vm.recentComments.isEmpty {
                    ContentUnavailableView("No comments this week", systemImage: "bubble.left", description: Text("New comments in the last 7 days will appear here."))
                } else {
                    List {
                        Section("Comments (last 7 days)") {
                            ForEach(vm.recentComments, id: \.commentId) { c in
                                ActivityCommentRow(comment: c)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Recent Activity")
        }
        .task { await vm.loadLastWeekComments(coachId: coachId) }
    }
}

private func relative(_ date: Date) -> String {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .abbreviated
    return f.localizedString(for: date, relativeTo: Date())
}

struct ActivityCommentRow: View {
    let comment: DBComment
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.comment)
                .font(.body)
                .lineLimit(2)
            HStack(spacing: 8) {
                Text("Game \(comment.gameId)")
                Text("•")
                Text(relative(comment.createdAt))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    CoachNotificationView(coachId: "FQzOD32960ZCORcwmULPPh21Ql53")
}
