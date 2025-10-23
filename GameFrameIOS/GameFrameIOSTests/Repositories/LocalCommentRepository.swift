//
//  LocalCommentRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation
@testable import GameFrameIOS

final class LocalCommentRepository: CommentRepository {
    private var comments: [DBComment] = []
    private var store: [String: [DBComment]] = [:]
    
    /// Retrieves a specific comment by its document ID for a given team.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - commentDocId: The Firestore document ID of the comment.
    /// - Returns: A `DBComment` object if found, otherwise `nil`.
    /// - Throws: An error if the retrieval fails.
    func getComment(teamId: String, commentDocId: String) async throws -> DBComment? {
        // Search the local array for a comment matching both teamId and commentDocId
        return comments.first { $0.commentId == commentDocId }
    }

    
    /// Retrieves all comments associated with a specific team.
    /// - Parameter teamId: The unique identifier of the team.
    /// - Returns: An optional array of `DBComment` objects, or `nil` if no comments exist.
    /// - Throws: An error if the retrieval fails.
    func getAllComments(teamId: String) async throws -> [DBComment]? {
        // Filter the local array for comments belonging to the specified team
        // Since DBComment has no teamId field, simply return comments
        return comments.isEmpty ? nil : comments
    }

    
    /// Retrieves all comments linked to a specific key moment in a team.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - keyMomentId: The unique identifier of the key moment.
    /// - Returns: An optional array of `DBComment` objects related to the key moment, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllCommentsForSpecificKeyMomentId(teamId: String, keyMomentId: String) async throws -> [DBComment]? {
        // Filter the local comments array for comments matching the teamId and keyMomentId
        let filteredComments = comments.filter { $0.keyMomentId == keyMomentId }
        return filteredComments.isEmpty ? nil : filteredComments

    }

    
    /// Retrieves all comments linked to a specific transcript in a team.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - transcriptId: The unique identifier of the transcript.
    /// - Returns: An optional array of `DBComment` objects related to the transcript, or `nil` if none exist.
    /// - Throws: An error if the retrieval fails.
    func getAllCommentsForSpecificTranscriptId(teamDocId: String, transcriptId: String) async throws -> [DBComment]? {
        // Filter the local comments array for comments matching the teamDocId and transcriptId
        let filteredComments = comments.filter { $0.transcriptId == transcriptId }
        return filteredComments.isEmpty ? nil : filteredComments
    }

    
    /// Adds a new comment to a team's collection.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - commentDTO: A data transfer object containing the comment details to be added.
    /// - Throws: An error if adding the comment fails.
//    func addNewComment(teamDocId: String, commentDTO: CommentDTO) async throws {
//        // Create a DBComment from the DTO
//        let newComment = DBComment(commentId: UUID().uuidString, commentDTO: commentDTO)
//        
//        // Add to local array
//        comments.append(newComment)
//
//    }

    
    /// Removes a comment from a team's collection.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - commentId: The Firestore document ID of the comment to remove.
    /// - Throws: An error if the removal fails.
    func removeComment(teamId: String, commentId: String) async throws {
        guard let index = comments.firstIndex(where: { $0.commentId == commentId }) else {
            print("Unable to find comment to be deleted")
            return
        }
        comments.remove(at: index)
    }
    
    
    @discardableResult
    func addNewCommentReturningId(teamDocId: String, commentDTO: CommentDTO) async throws -> String {
        let id = UUID().uuidString
        comments.append(DBComment(commentId: id, commentDTO: commentDTO))
        return id
    }

    func addNewComment(teamDocId: String, commentDTO: CommentDTO) async throws {
        _ = try await addNewCommentReturningId(teamDocId: teamDocId, commentDTO: commentDTO)
    }

}
