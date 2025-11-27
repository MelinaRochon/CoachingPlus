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

 Notifications are stored under each user document:

 - `users/{userDocId}/notifications/{notificationId}`

 Each document is a `DBNotification` and contains:
 - `user_doc_id` to indicate which user this notification belongs to.
 - Optional references to team / game / key moment / transcript / comment IDs.
 */
public final class FirestoreNotificationRepository: NotificationRepository {
    
    // MARK: - Firestore references
    
    /// Returns the `notifications` subcollection for a given user.
    ///
    /// Path:
    /// - `users/{userDocId}/notifications`
    private func notificationsCollection(for userDocId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(userDocId)
            .collection("notifications")
    }
    
    /// Finds a notification document by its `id` field across all users,
    /// using a collection group query on `notifications`.
    ///
    /// - Parameter id: The notification's Firestore document ID stored in the `id` field.
    /// - Returns: The first matching `DocumentSnapshot` if found, otherwise `nil`.
    private func findNotificationDocument(id: String) async throws -> DocumentSnapshot? {
        let snapshot = try await Firestore.firestore()
            .collectionGroup("notifications")
            .whereField(DBNotification.CodingKeys.id.rawValue, isEqualTo: id)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.first
    }
    
    // MARK: - Create
    
    /**
     Creates a new notification in the Firestore database.

     A new document is created under:
     - `users/{userDocId}/notifications/{notificationId}`

     - Parameter notificationDTO: A `NotificationDTO` containing the notification data.
     - Returns: The Firestore document ID of the newly created notification.
     - Throws: An error if the notification creation fails.
     */
    public func createNotification(notificationDTO: NotificationDTO) async throws -> String {
        print("FirestoreNotificationRepository - createNotification")
        print(notificationDTO.userDocId)
        print("")
        let collection = notificationsCollection(for: notificationDTO.userDocId)
        let docRef = collection.document()
        let documentId = docRef.documentID
        
        // Build DBNotification from DTO
        let notification = DBNotification(id: documentId, notificationDTO: notificationDTO)
        try docRef.setData(from: notification, merge: false)
        
        return documentId
    }
    
    // MARK: - Read single
    
    /**
     Retrieves a notification from Firestore by its document ID.

     This uses a `collectionGroup("notifications")` query since
     notifications are nested under each user.

     - Parameter id: The Firestore document ID of the notification (stored in the `id` field).
     - Returns: A `DBNotification` if found, otherwise `nil`.
     - Throws: An error if retrieval or decoding fails.
     */
    public func getNotification(id: String) async throws -> DBNotification? {
        guard let doc = try await findNotificationDocument(id: id) else {
            return nil
        }
        return try doc.data(as: DBNotification.self)
    }
    
    // MARK: - Read lists
    
    /**
     Retrieves all notifications for a specific user.

     The query is scoped to:
     - `users/{userDocId}/notifications`

     and orders by `created_at` (newest first).

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
        print("Getting notifications for user \(userDocId)")
        
        var query: Query = notificationsCollection(for: userDocId)
            .order(by: DBNotification.CodingKeys.createdAt.rawValue, descending: true)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        print("📄 Raw snapshot doc count: \(snapshot.documents.count)")
        
        var results: [DBNotification] = []
        
        for doc in snapshot.documents {
            do {
                let notif = try doc.data(as: DBNotification.self)
                results.append(notif)
            } catch {
                print("❌ Failed to decode DBNotification for doc \(doc.documentID): \(error)")
                print("   Raw data: \(doc.data())")
            }
        }
        
        return results
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
        
        let snapshot = try await notificationsCollection(for: userDocId)
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

     This sets `is_read` to `true` on the matching document found in any
     `users/{userDocId}/notifications` subcollection.

     - Parameter id: The Firestore document ID of the notification to update.
     - Throws: An error if the update fails.
     */
    public func markNotificationAsRead(id: String) async throws {
        guard let doc = try await findNotificationDocument(id: id) else {
            return
        }
        
        let data: [String: Any] = [
            DBNotification.CodingKeys.isRead.rawValue: true
        ]
        
        try await doc.reference.updateData(data as [AnyHashable: Any])
    }
    
    /**
     Marks all notifications as read for a given user.

     This:
     - Queries all notifications in `users/{userDocId}/notifications`
       where `is_read == false`
     - Updates `is_read` to `true` for each in a single batch operation.

     - Parameter userDocId: The Firestore document ID of the user.
     - Throws: An error if the update fails.
     */
    public func markAllNotificationsAsRead(for userDocId: String) async throws {
        let query = notificationsCollection(for: userDocId)
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

     This finds the document by `id` across all `notifications`
     subcollections and deletes the first match.

     - Parameter id: The Firestore document ID of the notification to delete.
     - Throws: An error if deletion fails.
     */
    public func deleteNotification(id: String) async throws {
        guard let doc = try await findNotificationDocument(id: id) else {
            return
        }
        try await doc.reference.delete()
    }
}
