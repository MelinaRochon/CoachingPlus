//
//  FirestoreNotificationRepository.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-11-26.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

/**
 A Firestore-backed implementation of `NotificationRepository`.

 Notifications are stored in a top-level collection:

 - `notifications/{notificationId}`

 Each document is a `DBNotification` and contains:
 - `user_doc_id` to indicate which user this notification belongs to.
 - Optional references to team / game / key moment / transcript / comment IDs.
 */
public final class FirestoreNotificationRepository: NotificationRepository {
    
    // MARK: - Firestore references
    
    /// Top-level `notifications` collection in Firestore.
    private let notificationsCollection = Firestore.firestore().collection("notifications")
    
    /**
     Returns a reference to a specific notification document in Firestore.
     
     Path:
     - `notifications/{id}`
     
     - Parameter id: The Firestore document ID of the notification.
     - Returns: A `DocumentReference` pointing to the specified notification.
     */
    private func notificationDocument(id: String) -> DocumentReference {
        notificationsCollection.document(id)
    }
    
    // MARK: - Create
    
    /**
     Creates a new notification in the Firestore database.
     
     A new document is created under:
     - `notifications/{notificationId}`
     
     - Parameter notificationDTO: A `NotificationDTO` containing the notification data.
     - Returns: The Firestore document ID of the newly created notification.
     - Throws: An error if the notification creation fails.
     */
    public func createNotification(notificationDTO: NotificationDTO) async throws -> String {
        let docRef = notificationsCollection.document()
        let documentId = docRef.documentID
        
        // Build DBNotification from DTO
        let notification = DBNotification(id: documentId, notificationDTO: notificationDTO)
        try docRef.setData(from: notification, merge: false)
        
        return documentId
    }
    
    // MARK: - Read single
    
    /**
     Retrieves a notification from Firestore by its document ID.
     
     - Parameter id: The Firestore document ID of the notification.
     - Returns: A `DBNotification` if found, otherwise `nil`.
     - Throws: An error if retrieval or decoding fails.
     */
    public func getNotification(id: String) async throws -> DBNotification? {
        try await notificationDocument(id: id).getDocument(as: DBNotification.self)
    }
    
    // MARK: - Read lists
    
    /**
     Retrieves all notifications for a specific user.
     
     The query filters by `user_doc_id` and orders by `created_at` (newest first).
     If `limit` is provided, the result set is limited to that number of documents.
     
     - Parameters:
       - userDocId: The Firestore document ID of the user who receives the notifications.
       - limit: Optional maximum number of notifications to return. If `nil`, all matching notifications are returned.
     - Returns: An array of `DBNotification` objects (empty if none found).
     - Throws: An error if retrieval or decoding fails.
     */
    public func getNotificationsForUser(
        userDocId: String,
        limit: Int?
    ) async throws -> [DBNotification] {
        
        var query: Query = notificationsCollection
            .whereField(DBNotification.CodingKeys.userDocId.rawValue, isEqualTo: userDocId)
            .order(by: DBNotification.CodingKeys.createdAt.rawValue, descending: true)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DBNotification.self)
        }
    }
    
    /**
     Retrieves all unread notifications for a specific user.
     
     A notification is considered unread if `is_read == false`.
     
     - Parameter userDocId: The Firestore document ID of the user.
     - Returns: An array of unread `DBNotification` objects (empty if none found).
     - Throws: An error if retrieval or decoding fails.
     */
    public func getUnreadNotificationsForUser(
        userDocId: String
    ) async throws -> [DBNotification] {
        
        let snapshot = try await notificationsCollection
            .whereField(DBNotification.CodingKeys.userDocId.rawValue, isEqualTo: userDocId)
            .whereField(DBNotification.CodingKeys.isRead.rawValue, isEqualTo: false)
            .order(by: DBNotification.CodingKeys.createdAt.rawValue, descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DBNotification.self)
        }
    }
    
    // MARK: - Update (read flags)
    
    /**
     Marks a specific notification as read.
     
     This sets `is_read` to `true` on:
     - `notifications/{id}`
     
     - Parameter id: The Firestore document ID of the notification to update.
     - Throws: An error if the update fails.
     */
    public func markNotificationAsRead(id: String) async throws {
        let data: [String: Any] = [
            DBNotification.CodingKeys.isRead.rawValue: true
        ]
        
        try await notificationDocument(id: id).updateData(data as [AnyHashable: Any])
    }
    
    /**
     Marks all notifications as read for a given user.
     
     This:
     - Queries all notifications where `user_doc_id == userDocId` and `is_read == false`
     - Updates `is_read` to `true` for each in a single batch operation.
     
     - Parameter userDocId: The Firestore document ID of the user.
     - Throws: An error if the update fails.
     */
    public func markAllNotificationsAsRead(for userDocId: String) async throws {
        let query = notificationsCollection
            .whereField(DBNotification.CodingKeys.userDocId.rawValue, isEqualTo: userDocId)
            .whereField(DBNotification.CodingKeys.isRead.rawValue, isEqualTo: false)
        
        let snapshot = try await query.getDocuments()
        
        guard !snapshot.documents.isEmpty else { return }
        
        let batch = Firestore.firestore().batch()
        for doc in snapshot.documents {
            batch.updateData(
                [DBNotification.CodingKeys.isRead.rawValue: true],
                forDocument: doc.reference
            )
        }
        
        try await batch.commit()
    }
    
    // MARK: - Delete
    
    /**
     Deletes a notification from the database.
     
     Path:
     - `notifications/{id}`
     
     - Parameter id: The Firestore document ID of the notification to delete.
     - Throws: An error if deletion fails.
     */
    public func deleteNotification(id: String) async throws {
        try await notificationDocument(id: id).delete()
    }
}
