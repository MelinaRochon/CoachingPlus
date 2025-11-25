//
//  PlayerNotificationView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared

/***
 This structure is the recent activity view. All the recent acitivities made in the app (all types of notifications) will be shown here.
 */
struct PlayerNotificationView: View {
    @EnvironmentObject private var dependencies: DependencyContainer
    @StateObject private var vm = NotificationsViewModel()

    let playerId: String

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
                                await vm.loadPlayerLastWeekComments(playerId: playerId)
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
            await vm.loadPlayerLastWeekComments(playerId: playerId)
        }
    }
}

// MARK: - Helpers

private func relative(_ date: Date) -> String {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .abbreviated
    return f.localizedString(for: date, relativeTo: Date())
}

