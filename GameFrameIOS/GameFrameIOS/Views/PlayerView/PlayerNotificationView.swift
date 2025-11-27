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
    @StateObject private var notifModel = NotificationsViewModel()
    @EnvironmentObject private var dependencies: DependencyContainer
    
//    @State private var comments: [DBComment]?
    @State private var notifications: [DBNotification] = []

    @State private var isLoadingMyNotifs: Bool = false
    
    
    let playerId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Divider().padding(.bottom, 30)

                CustomListSection(
                    titleContent: {
                        AnyView(
                            CustomUIFields.customDivider("My notifications")
                        )},
                    items: notifications,
                    isLoading: isLoadingMyNotifs,
                    rowLogo: "bell",
                    isLoadingProgressViewTitle: "Searching for my activity…",
                    noItemsFoundIcon: "bubble.left",
                    noItemsFoundTitle: "No activity found at this time.",
                    noItemsFoundSubtitle: "Try again later.",

                    destinationBuilder: { notif in
                        switch notif.type {
                        case .comment:
                            return AnyView(
                                MarkOnAppearWrapper(
                                    onAppear: { markNotificationAsRead(notif) },
                                    content: {
                                        CoachSpecificKeyMomentLoaderView(
                                            teamId: notif.teamDocId ?? "",
                                            gameId: notif.gameId ?? "",
                                            keyMomentId: notif.keyMomentId ?? ""
                                        )
                                    }
                                )
                            )
                        case .gameRecordingReady:
                            return AnyView(EmptyView()
//                                CoachFullGameRecordingView(
//                                    teamId: notif.teamId ?? "",
//                                    gameId: notif.gameId,
//                                    recordingId: notif.recordingId ?? ""
                                )
                        default:
                            // if you add more enum cases later and don't want navigation for them yet
                            return AnyView(EmptyView())
                        }
                    },
                    // MARK: - Row content
                    rowContent: { notif in
                        AnyView(
                            HStack(alignment: .top, spacing: 8) {
                                if !notif.isRead {
                                                Circle()
                                                    .frame(width: 8, height: 8)
                                                    .foregroundStyle(.red)
                                                    .padding(.top, 6)
                                            }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notif.title)          // comes from DBNotification
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .foregroundStyle(.black)
                                    
                                    Text(relative(notif.createdAt))
                                        .font(.caption)
                                        .padding(.leading, 1)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                )
                Spacer()
            }
            .background(Color.white)
            .navigationTitle(Text("Recent Activity"))
        }
        .task {
            // inject deps and load notifications when the view appears
            notifModel.setDependencies(dependencies)
            await loadCoachNotifications()
        }
    }
    
    private struct MarkOnAppearWrapper<Content: View>: View {
        let onAppear: () -> Void
        let content: () -> Content
        
        @State private var hasAppeared = false
        
        var body: some View {
            content()
                .onAppear {
                    if !hasAppeared {
                        hasAppeared = true
                        onAppear()
                    }
                }
        }
    }

    
    // MARK: - Helpers
    
    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
    
    private func loadCoachNotifications() async {
        do {
            isLoadingMyNotifs = true
            try await notifModel.loadNotifications(userId: playerId)
            notifications = notifModel.notifications
            print("🔔 View copying \(notifModel.notifications.count) notifications into state")
            isLoadingMyNotifs = false
        } catch {
            isLoadingMyNotifs = false
            print("Error loading notifications: \(error)")
        }
    }
    
    private func markNotificationAsRead(_ notif: DBNotification) {
        // Don’t do anything if it’s already read
        if notif.isRead { return }
        
        Task {
            do {
                print("Marking notification as read!")
                try await dependencies.notificationManager.markNotificationAsRead(
                    userDocId: notif.userDocId,
                    id: notif.id
                )

                // Update local state so UI reflects it immediately
                var copy = notifications
                if let idx = copy.firstIndex(where: { $0.id == notif.id }) {
                    copy[idx].isRead = true
                }
                notifications = copy
            } catch {
                print("❌ Failed to mark notification as read: \(error)")
            }
        }
    }


}
