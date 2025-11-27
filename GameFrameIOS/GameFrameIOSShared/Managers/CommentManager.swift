//
//  CommentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation

/// Manager for interacting with comment data in Firestore
public final class CommentManager {
    
    private let repo: CommentRepository
    
    public init(repo: CommentRepository) {
        self.repo = repo
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
        return try await repo.getComment(teamId: teamId, commentDocId: commentDocId)
    }
    
    
    /**
     * Fetches all comments for a specific team from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team for which comments should be fetched
     * - Returns: An array of `DBComment` objects containing all comments for the team, or `nil` if no comments are found
     * - Throws: Throws an error if the team document cannot be found or there is an issue fetching the comments
     */
    public func getAllComments(teamId: String) async throws -> [DBComment]? {
        return try await repo.getAllComments(teamId: teamId)
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
        return try await repo.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId)
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
        return try await repo.getAllCommentsForSpecificTranscriptId(teamDocId: teamDocId, transcriptId: transcriptId)
    }
    
    /**
     * Fetches recent comments for multiple teams since a given date.
     * - Parameters:
     *   - teamDocIds: The document IDs of the teams to fetch comments for.
     *   - since: Only comments with `datePosted` >= `since` will be returned.
     * - Returns: An array of `DBComment` objects.
     * - Throws: If there is an issue fetching from the repository.
     */
    public func fetchRecentComments(
        forTeamDocIds teamDocIds: [String],
        since: Date
    ) async throws -> [DBComment] {
        return try await repo.fetchRecentComments(forTeamDocIds: teamDocIds, since: since)
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
        try await repo.addNewComment(teamDocId: teamDocId, commentDTO: commentDTO)
    }

    
    
    /**
     * Removes a comment from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team from which the comment should be removed
     *   - commentId: The ID of the comment to be removed
     * - Throws: Throws an error if there is an issue deleting the comment
     */
    public func removeComment(teamId: String, commentId: String) async throws {
        try await repo.removeComment(teamId: teamId, commentId: commentId)
    }
}
