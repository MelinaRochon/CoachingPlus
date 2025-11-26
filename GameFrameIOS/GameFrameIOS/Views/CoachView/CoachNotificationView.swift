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
    @StateObject private var notifModel = NotificationsViewModel()
    @EnvironmentObject private var dependencies: DependencyContainer
    
    @State private var comments: [DBComment]?
    
    @State private var isLoadingMyNotifs: Bool = false
    
    
    let coachId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recent Activity").font(Font.largeTitle.bold())
                        .padding(.top, 54)
                        .padding(.horizontal, 15)
                    Divider()
                }
//                .padding(.horizontal, 15)
//                .padding(.top, 8)
                .padding(.bottom, 30)
                CustomListSection(
                    titleContent: {
                        AnyView(
                            CustomUIFields.customDivider("My notifications")
                        )},
                    items: comments ?? [],
                    isLoading: isLoadingMyNotifs,
                    rowLogo: "text.bubble",
                    isLoadingProgressViewTitle: "Searching for my activity…",
                    noItemsFoundIcon: "bubble.left",
                    noItemsFoundTitle: "No activity found at this time.",
                    noItemsFoundSubtitle: "Try again later.",
                    destinationBuilder: { comment in
                        // use the view-model’s mapping from gameId → teamId
                        CoachSpecificKeyMomentLoaderView(
                            teamId: notifModel.teamIdsByGame[comment.gameId] ?? "",
                            gameId: comment.gameId,
                            keyMomentId: comment.keyMomentId ?? ""
                        )
                    },
                    rowContent: { comment in
                        let authorName = notifModel.authorNames[comment.uploadedBy] ?? "Unknown User"
                        let gameTitle = notifModel.gameTitles[comment.gameId] ?? "Unknown Game"
                        
                        return AnyView(
                            VStack (alignment: .leading, spacing: 4) {
                                Text("\(authorName) commented on \(gameTitle)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.black)
                                Text(relative(comment.createdAt))
                                    .font(.caption)
                                    .padding(.leading, 1)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(.gray)
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                        )
                    }
                )
                Spacer()
            }
            .background(Color.white)
        }
        .task {
            // inject deps and load notifications when the view appears
            notifModel.setDependencies(dependencies)
            await loadNotifications()
        }
    }
    
    
    // MARK: - Helpers
    
    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
    
    private func loadNotifications() async {
        do {
            isLoadingMyNotifs = true
            await notifModel.loadCoachLastWeekComments(coachId: coachId)
            // copy from VM into local state, just like teams
            comments = notifModel.recentComments
            isLoadingMyNotifs = false
        } catch {
            isLoadingMyNotifs = false
            print("Error loading notifications: \(error)")
        }
    }
}
