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
    
//    @State private var comments: [DBComment]?
    @State private var notifications: [DBNotification] = []

    @State private var isLoadingMyNotifs: Bool = false
    
    
    let coachId: String
    
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
                                CoachSpecificKeyMomentLoaderView(
                                    teamId: notif.teamDocId ?? "",
                                    gameId: notif.gameId ?? "",
                                    keyMomentId: notif.keyMomentId ?? ""
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
    
    
    // MARK: - Helpers
    
    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
    
    private func loadCoachNotifications() async {
        do {
            isLoadingMyNotifs = true            
            try await notifModel.loadNotifications(userId: coachId)
            notifications = notifModel.notifications
            print("🔔 View copying \(notifModel.notifications.count) notifications into state")
            isLoadingMyNotifs = false
        } catch {
            isLoadingMyNotifs = false
            print("Error loading notifications: \(error)")
        }
    }
}
