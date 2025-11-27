//
//  FirestoreCommentRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
import FirebaseFirestore
import Combine
import GameFrameIOSShared

public final class FirestoreCommentRepository: CommentRepository {
    
    /**
     * Returns a reference to a specific comment document in the Firestore database
     * - Parameters:
     *   - teamDocId: The document ID of the team
     *   - commentDocId: The document ID of the comment
     * - Returns: A `DocumentReference` pointing to the specific comment document
     */
    public func commentDocument(teamDocId: String, commentDocId: String) -> DocumentReference {
        return commentCollection(teamDocId: teamDocId).document(commentDocId)
    }

    
    /**
     * Returns a reference to the comments collection for a specific team
     * - Parameters:
     *   - teamDocId: The document ID of the team
     * - Returns: A `CollectionReference` to the team's comments collection in Firestore
     */
    public func commentCollection(teamDocId: String) -> CollectionReference {
        let teamRepo = FirestoreTeamRepository()
        return teamRepo.teamCollection().document(teamDocId).collection("comments")
    }
    
    
    // MARK: - Public Methods

    /**
     * Fetches a specific comment from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team to which the comment belongs
     *   - commentDocId: The ID of the comment to fetch
     * - Returns: The `DBComment` object containing the comment's data, or `nil` if not found
     * - Throws: Throws an error if the team document cannot be found or there is an issue fetching the comment
     */
    public func getComment(teamId: String, commentDocId: String) async throws -> DBComment? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("getComment: Could not find team id. Aborting")
            return nil
        }
        
        // Fetch the comment document and map it to the `DBComment` model
        return try await commentDocument(teamDocId: teamDocId, commentDocId: commentDocId).getDocument(as: DBComment.self)
    }
    
    
    /**
     * Fetches all comments for a specific team from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team for which comments should be fetched
     * - Returns: An array of `DBComment` objects containing all comments for the team, or `nil` if no comments are found
     * - Throws: Throws an error if the team document cannot be found or there is an issue fetching the comments
     */
    public func getAllComments(teamId: String) async throws -> [DBComment]? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("getAllComments: Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the comments collection
        let snapshot = try await commentCollection(teamDocId: teamDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    
    /**
     * Fetches all comments associated with a specific key moment from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team whose comments should be fetched
     *   - keyMomentId: The key moment ID to filter comments by
     * - Returns: An array of `DBComment` objects that are associated with the specified key moment, or `nil` if none are found
     * - Throws: Throws an error if the team document cannot be found or there is an issue fetching the comments
     */
    public func getAllCommentsForSpecificKeyMomentId(teamId: String, keyMomentId: String) async throws -> [DBComment]? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("getAllCommentsForSpecificKeyMomentId: Could not find team id. Aborting")
            return nil
        }
        
        let query = try await commentCollection(teamDocId: teamDocId).whereField("key_moment_id", isEqualTo: keyMomentId).getDocuments()
        
        return query.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    

    /**
     * Fetches all comments associated with a specific transcript ID from the Firestore database
     * - Parameters:
     *   - teamDocId: The document ID of the team
     *   - transcriptId: The transcript ID to filter comments by
     * - Returns: An array of `DBComment` objects that are associated with the specified transcript, or `nil` if none are found
     * - Throws: Throws an error if there is an issue fetching the comments
     */
    public func getAllCommentsForSpecificTranscriptId(teamDocId: String, transcriptId: String) async throws -> [DBComment]? {
        
        let query = try await commentCollection(teamDocId: teamDocId).whereField("transcript_id", isEqualTo: transcriptId).getDocuments()
        
        return query.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    
    /// Fetch only replies to a given parent comment.
    public func getReplies(teamDocId: String, parentCommentId: String) async throws -> [DBComment]? {
        let query = try await commentCollection(teamDocId: teamDocId)
            .whereField("parent_comment_id", isEqualTo: parentCommentId)
            .order(by: "created_at", descending: false)
            .getDocuments()
        return query.documents.compactMap { try? $0.data(as: DBComment.self) }
    }
    
    
    /**
     * Adds a new comment to the Firestore database
     * - Parameters:
     *   - teamDocId: The document ID of the team to which the comment should be added
     *   - commentDTO: The `CommentDTO` object containing the comment data to be added
     * - Throws: Throws an error if there is an issue adding the comment to Firestore
     */
    @discardableResult
    public func addNewComment(teamDocId: String, commentDTO: CommentDTO) async throws -> String {
        let ref = commentCollection(teamDocId: teamDocId).document()
        let commentId = ref.documentID

        let dbComment = DBComment(
            commentId: commentId,
            keyMomentId: commentDTO.keyMomentId,
            gameId: commentDTO.gameId,
            transcriptId: commentDTO.transcriptId,
            uploadedBy: commentDTO.uploadedBy,
            comment: commentDTO.comment,
            createdAt: commentDTO.createdAt,
            parentCommentId: commentDTO.parentCommentId
        )

        try ref.setData(from: dbComment, merge: false)
        return commentId
    }
    
    
    /**
     * Removes a comment from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team from which the comment should be removed
     *   - commentId: The ID of the comment to be removed
     * - Throws: Throws an error if there is an issue deleting the comment
     */
    public func removeComment(teamId: String, commentId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: teamId)?.id else {
            print("removeComment: Could not find team id. Aborting")
            return
        }
        
        try await commentDocument(teamDocId: teamDocId, commentDocId: commentId).delete()
    }

}

extension FirestoreCommentRepository {

    /// Fetch comments newer than `since` for many team doc IDs (no listeners).
    public func fetchRecentComments(
        forTeamDocIds teamDocIds: [String],
        since: Date
    ) async throws -> [DBComment] {
        guard !teamDocIds.isEmpty else { return [] }
        let ts = Timestamp(date: since)

        // Run queries in parallel per team
        return try await withThrowingTaskGroup(of: [DBComment].self) { group in
            for teamDocId in teamDocIds {
                group.addTask { [weak self] in
                    guard let self else { return [] }
                    let snap = try await self.commentCollection(teamDocId: teamDocId)
                        .whereField("created_at", isGreaterThan: ts)
                        .order(by: "created_at", descending: true)
                        .getDocuments()
                    return snap.documents.compactMap { try? $0.data(as: DBComment.self) }
                }
            }

            var all: [DBComment] = []
            for try await chunk in group { all.append(contentsOf: chunk) }

            // Dedupe (if the same id could appear twice) and sort newest first
            var byId: [String: DBComment] = [:]
            for c in all { byId[c.commentId] = c }
            return byId.values.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
