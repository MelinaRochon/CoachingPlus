//
//  NotificationManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation

/**
 A manager class responsible for handling operations related to notifications.
 This class provides functionality to create, retrieve, update, and delete notifications
 in the Firestore database (or any underlying data source via the repository).
 */
public final class NotificationManager {
    
    private let repo: NotificationRepository
    
    public init(repo: NotificationRepository) {
        self.repo = repo
    }
    
    
    // MARK: - Create
    
    /**
     Creates a new notification in the database.
     
     - Parameter notificationDTO: The `NotificationDTO` containing the notification data.
     - Returns: A string representing the document ID of the newly created notification.
     - Throws: An error if the notification creation fails.
     */
    public func createNotification(notificationDTO: NotificationDTO) async throws -> String {
        return try await repo.createNotification(notificationDTO: notificationDTO)
    }
    
    
    // MARK: - Read
    
    /**
     Retrieves a notification document by its ID.
     
     - Parameter id: The ID of the notification to retrieve.
     - Returns: An optional `DBNotification` object if found, otherwise `nil`.
     - Throws: An error if the retrieval process fails.
     */
    public func getNotification(id: String) async throws -> DBNotification? {
        return try await repo.getNotification(id: id)
    }
    
    
    /**
     Retrieves all notifications for a given user.
     
     - Parameters:
        - userDocId: The Firestore document ID of the user.
        - limit: Optional maximum number of notifications to return. If `nil`, all are returned.
     - Returns: An array of `DBNotification` objects (empty if none found).
     - Throws: An error if the retrieval process fails.
     */
    public func getNotificationsForUser(userDocId: String, limit: Int? = nil) async throws -> [DBNotification] {
        return try await repo.getNotificationsForUser(userDocId: userDocId, limit: limit)
    }
    
    
    /**
     Retrieves all unread notifications for a given user.
     
     - Parameter userDocId: The Firestore document ID of the user.
     - Returns: An array of unread `DBNotification` objects (empty if none found).
     - Throws: An error if the retrieval process fails.
     */
    public func getUnreadNotificationsForUser(userDocId: String) async throws -> [DBNotification] {
        return try await repo.getUnreadNotificationsForUser(userDocId: userDocId)
    }
    
    
    // MARK: - Update
    
    /**
     Marks a specific notification as read.
     
     - Parameter id: The ID of the notification to update.
     - Throws: An error if the update process fails.
     */
    public func markNotificationAsRead(id: String) async throws {
        try await repo.markNotificationAsRead(id: id)
    }
    
    
    /**
     Marks all notifications as read for a given user.
     
     - Parameter userDocId: The Firestore document ID of the user.
     - Throws: An error if the update process fails.
     */
    public func markAllNotificationsAsRead(for userDocId: String) async throws {
        try await repo.markAllNotificationsAsRead(for: userDocId)
    }
    
    
    // MARK: - Delete
    
    /**
     Deletes a notification in the database.
     
     - Parameter id: The ID of the notification to delete.
     - Throws: An error if the delete process fails.
     */
    public func deleteNotification(id: String) async throws {
        try await repo.deleteNotification(id: id)
    }
}
