//
//  CoachNotificationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared

/***
 This structure is the recent activity view. All the recent acitivities made in the app (all types of notifications) will be shown here.
 */
struct CoachNotificationView: View {
    @EnvironmentObject private var dependencies: DependencyContainer
    @StateObject private var vm = NotificationsViewModel()

    let coachId: String

    var body: some View {
        NavigationStack {
            Divider()
            List {
                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading activity…")
                            .font(.caption)
                        Spacer()
                    }
                } else if let err = vm.error {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Couldn’t load activity")
                                .font(.headline)
                            Text(err)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Button("Retry") {
                            Task {
                                vm.setDependencies(dependencies)
                                await vm.loadCoachLastWeekComments(coachId: coachId)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                } else if vm.recentComments.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No recent activity this week",
                            systemImage: "bubble.left",
                            description: Text("New activity in the last 7 days will appear here.")
                        )
                    }
                } else {
                    Section("Comments (last 7 days)") {
                        ForEach(vm.recentComments, id: \.commentId) { c in
                            let title  = vm.gameTitles[c.gameId] ?? "Unknown Game"
                            let author = vm.authorNames[c.uploadedBy] ?? "Unknown User"
                            let teamId = vm.teamIdsByGame[c.gameId]

                            CommentNavigationRow(
                                comment: c,
                                gameTitle: title,
                                authorName: author,
                                teamId: teamId
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .navigationTitle("Recent Activity")
        }
        .task {
            vm.setDependencies(dependencies)
            await vm.loadCoachLastWeekComments(coachId: coachId)
        }
    }
}

// MARK: - Helpers

private func relative(_ date: Date) -> String {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .abbreviated
    return f.localizedString(for: date, relativeTo: Date())
}

struct ActivityCommentRow: View {
    let comment: DBComment
    let gameTitle: String
    let authorName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.comment)
                .font(.body)
                .lineLimit(2)

            HStack(spacing: 8) {
                Text(authorName)
                Text("•")
                Text(gameTitle)
                Text("•")
                Text(relative(comment.createdAt))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct CommentNavigationRow: View {
    let comment: DBComment
    let gameTitle: String
    let authorName: String
    let teamId: String?    // may be nil if we couldn't resolve it

    var body: some View {
        if let teamId {
            NavigationLink {
                CoachSpecificKeyMomentLoaderView(
                    teamId: teamId,
                    gameId: comment.gameId,
                    keyMomentId: comment.keyMomentId ?? ""
                )
            } label: {
                ActivityCommentRow(
                    comment: comment,
                    gameTitle: gameTitle,
                    authorName: authorName
                )
            }
        } else {
            // Fallback: show the row but don't navigate
            ActivityCommentRow(
                comment: comment,
                gameTitle: gameTitle,
                authorName: authorName
            )
        }
    }
}




#Preview {
    CoachNotificationView(coachId: "FQzOD32960ZCORcwmULPPh21Ql53")
}
