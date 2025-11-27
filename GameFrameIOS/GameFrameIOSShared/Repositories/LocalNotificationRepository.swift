//
//  LocalNotificationRepository.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation

public final class LocalNotificationRepository: NotificationRepository {
    
    private var notifications: [DBNotification] = []
    
    /// Initializes the local notification repository with optional seeded data.
    /// - Parameter notifications: An optional array of `DBNotification` objects.
    ///   If `nil`, it will attempt to load from `TestNotifications.json` via `TestDataLoader`.
    public init(notifications: [DBNotification]? = nil) {
        self.notifications = notifications ?? TestDataLoader.load("TestNotifications", as: [DBNotification].self)
    }
    
    // MARK: - Create
    
    /// Creates a new notification in the local in-memory store.
    /// - Parameter notificationDTO: DTO describing the notification to create.
    /// - Returns: The generated notification ID.
    public func createNotification(notificationDTO: NotificationDTO) async throws -> String {
        let newId = UUID().uuidString
        let notification = DBNotification(id: newId, notificationDTO: notificationDTO)
        notifications.append(notification)
        return newId
    }
    
    // MARK: - Read
    
    /// Retrieves a notification by its document ID.
    /// - Parameter id: The ID of the notification.
    /// - Returns: A `DBNotification` if found, otherwise `nil`.
    public func getNotification(id: String) async throws -> DBNotification? {
        return notifications.first { $0.id == id }
    }
    
    /// Retrieves all notifications for a specific user, optionally limited.
    /// - Parameters:
    ///   - userDocId: The user document ID.
    ///   - limit: Optional maximum count of notifications to return.
    /// - Returns: An array of `DBNotification` objects.
    public func getNotificationsForUser(userDocId: String, limit: Int? = nil) async throws -> [DBNotification] {
        let userNotifications = notifications
            .filter { $0.userDocId == userDocId }
            .sorted { $0.createdAt > $1.createdAt }
        
        if let limit {
            return Array(userNotifications.prefix(limit))
        } else {
            return userNotifications
        }
    }
    
    /// Retrieves all unread notifications for a user.
    /// - Parameter userDocId: The user document ID.
    /// - Returns: An array of unread `DBNotification` objects.
    public func getUnreadNotificationsForUser(userDocId: String) async throws -> [DBNotification] {
        return notifications
            .filter { $0.userDocId == userDocId && $0.isRead == false }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Update
    
    /// Marks a specific notification as read.
    /// - Parameter id: The ID of the notification to update.
    public func markNotificationAsRead(userDocId: String, id: String) async throws {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "LocalNotificationRepository",
                          code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Notification not found"])
        }
        notifications[index].isRead = true
    }
    
    /// Marks all notifications as read for a given user.
    /// - Parameter userDocId: The user document ID.
    public func markAllNotificationsAsRead(for userDocId: String) async throws {
        for i in notifications.indices {
            if notifications[i].userDocId == userDocId {
                notifications[i].isRead = true
            }
        }
    }
    
    // MARK: - Delete
    
    /// Deletes a notification by its ID.
    /// - Parameter id: The ID of the notification to remove.
    public func deleteNotification(id: String) async throws {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "LocalNotificationRepository",
                          code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Notification not found"])
        }
        notifications.remove(at: index)
    }
}
