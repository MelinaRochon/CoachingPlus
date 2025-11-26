//
//  NotificationRepository.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation

public protocol NotificationRepository {
    
    /// Creates a new notification document in the database.
    /// - Parameter notificationDTO: A data transfer object containing the notification details to be saved.
    /// - Returns: The Firestore document ID of the newly created notification.
    /// - Throws: An error if the creation fails.
    func createNotification(notificationDTO: NotificationDTO) async throws -> String
    
    
    /// Retrieves a notification by its document ID.
    /// - Parameter id: The Firestore document ID of the notification.
    /// - Returns: A `DBNotification` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getNotification(id: String) async throws -> DBNotification?
    
    
    /// Retrieves all notifications for a specific user.
    /// - Parameters:
    ///   - userDocId: The Firestore document ID of the user who receives the notifications.
    ///   - limit: Optional maximum number of notifications to return. If `nil`, all matching notifications are returned.
    /// - Returns: An array of `DBNotification` objects (empty if none found).
    /// - Throws: An error if retrieval fails.
    func getNotificationsForUser(userDocId: String, limit: Int?) async throws -> [DBNotification]
    
    
    /// Retrieves all unread notifications for a specific user.
    /// - Parameter userDocId: The Firestore document ID of the user.
    /// - Returns: An array of unread `DBNotification` objects (empty if none found).
    /// - Throws: An error if retrieval fails.
    func getUnreadNotificationsForUser(userDocId: String) async throws -> [DBNotification]
    
    
    /// Marks a specific notification as read.
    /// - Parameter id: The Firestore document ID of the notification to update.
    /// - Throws: An error if the update fails.
    func markNotificationAsRead(id: String) async throws
    
    
    /// Marks all notifications as read for a given user.
    /// - Parameter userDocId: The Firestore document ID of the user.
    /// - Throws: An error if the update fails.
    func markAllNotificationsAsRead(for userDocId: String) async throws
    
    
    /// Deletes a notification from the database.
    /// - Parameter id: The Firestore document ID of the notification to delete.
    /// - Throws: An error if deletion fails.
    func deleteNotification(id: String) async throws
}
