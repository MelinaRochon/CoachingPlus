//
//  CommentRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

public protocol CommentRepository {

    /// Retrieves a specific comment by its document ID for a given team.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - commentDocId: The Firestore document ID of the comment.
    /// - Returns: A `DBComment` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getComment(teamId: String, commentDocId: String) async throws -> DBComment?

    
    /// Retrieves all comments associated with a specific team.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: An optional array of `DBComment` objects, or `nil` if no comments exist.
    /// - Throws: An error if the retrieval fails.
    func getAllComments(teamId: String) async throws -> [DBComment]?

    
    /// Retrieves all comments linked to a specific key moment in a team.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - keyMomentId: The unique identifier of the key moment.
    /// - Returns: An optional array of `DBComment` objects related to the key moment, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllCommentsForSpecificKeyMomentId(teamId: String, keyMomentId: String) async throws -> [DBComment]?

    
    /// Retrieves all comments linked to a specific transcript in a team.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - transcriptId: The unique identifier of the transcript.
    /// - Returns: An optional array of `DBComment` objects related to the transcript, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllCommentsForSpecificTranscriptId(teamDocId: String, transcriptId: String) async throws -> [DBComment]?

    
    /// Retrieves all comments for the given team doc IDs that were posted on or after `since`.
    /// - Parameters:
    ///   - teamDocIds: List of team document IDs to filter by.
    ///   - since: Only comments on or after this date will be returned.
    /// - Returns: An array of `DBComment` objects.
    /// - Throws: An error if the retrieval fails.
    func fetchRecentComments(
        forTeamDocIds teamDocIds: [String],
        since: Date
    ) async throws -> [DBComment]


    /// Adds a new comment to a team's collection.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - commentDTO: A data transfer object containing the comment details to be added.
    /// - Throws: An error if adding the comment fails.
    func addNewComment(teamDocId: String, commentDTO: CommentDTO) async throws -> String

    
    /// Removes a comment from a team's collection.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - commentId: The Firestore document ID of the comment to remove.
    /// - Throws: An error if the removal fails.
    func removeComment(teamId: String, commentId: String) async throws
}
