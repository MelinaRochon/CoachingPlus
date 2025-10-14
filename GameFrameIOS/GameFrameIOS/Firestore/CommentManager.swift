//
//  CommentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore
import Combine

/// Model representing a comment in the database
struct DBComment: Codable {
    let commentId: String
    let keyMomentId: String
    let gameId: String
    let transcriptId: String
    let uploadedBy: String
    let comment: String
    let createdAt: Date
    
    // Initializer for creating a comment with all fields
    init(commentId: String, keyMomentId: String, gameId: String, transcriptId: String, uploadedBy: String, comment: String, createdAt: Date) {
        self.commentId = commentId
        self.keyMomentId = keyMomentId
        self.gameId = gameId
        self.transcriptId = transcriptId
        self.uploadedBy = uploadedBy
        self.comment = comment
        self.createdAt = createdAt
    }
    
    // Initializer using a CommentDTO object
    init(commentId: String, commentDTO: CommentDTO) {
        self.commentId = commentId
        self.keyMomentId = commentDTO.keyMomentId
        self.gameId = commentDTO.gameId
        self.transcriptId = commentDTO.transcriptId
        self.uploadedBy = commentDTO.uploadedBy
        self.comment = commentDTO.comment
        self.createdAt = commentDTO.createdAt
    }
    
    // Enum for coding keys used in encoding and decoding
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case keyMomentId = "key_moment_id"
        case gameId = "game_id"
        case transcriptId = "transcript_id"
        case uploadedBy = "uploaded_by"
        case comment = "comment"
        case createdAt = "created_at"
    }

    // Decode the comment data from a decoder
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.keyMomentId = try container.decode(String.self, forKey: .keyMomentId)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.transcriptId = try container.decode(String.self, forKey: .transcriptId)
        self.uploadedBy = try container.decode(String.self, forKey: .uploadedBy)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
     
    // Encode the comment data to an encoder
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.commentId, forKey: .commentId)
        try container.encode(self.keyMomentId, forKey: .keyMomentId)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.transcriptId, forKey: .transcriptId)
        try container.encode(self.uploadedBy, forKey: .uploadedBy)
        try container.encode(self.comment, forKey: .comment)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}


/// Manager for interacting with comment data in Firestore
final class CommentManager {
    
    static let shared = CommentManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    
    // MARK: - Private Helper Methods

    /**
     * Returns a reference to a specific comment document in the Firestore database
     * - Parameters:
     *   - teamDocId: The document ID of the team
     *   - commentDocId: The document ID of the comment
     * - Returns: A `DocumentReference` pointing to the specific comment document
     */
    func commentDocument(teamDocId: String, commentDocId: String) -> DocumentReference {
        return commentCollection(teamDocId: teamDocId).document(commentDocId)
    }

    
    /**
     * Returns a reference to the comments collection for a specific team
     * - Parameters:
     *   - teamDocId: The document ID of the team
     * - Returns: A `CollectionReference` to the team's comments collection in Firestore
     */
    func commentCollection(teamDocId: String) -> CollectionReference {
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
    func getComment(teamId: String, commentDocId: String) async throws -> DBComment? {
        let teamManager = TeamManager()
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
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
    func getAllComments(teamId: String) async throws -> [DBComment]? {
        let teamManager = TeamManager()
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
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
    func getAllCommentsForSpecificKeyMomentId(teamId: String, keyMomentId: String) async throws -> [DBComment]? {
        let teamManager = TeamManager()
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
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
    func getAllCommentsForSpecificTranscriptId(teamDocId: String, transcriptId: String) async throws -> [DBComment]? {
        
        let query = try await commentCollection(teamDocId: teamDocId).whereField("transcript_id", isEqualTo: transcriptId).getDocuments()
        
        return query.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    
    /**
     * Adds a new comment to the Firestore database
     * - Parameters:
     *   - teamDocId: The document ID of the team to which the comment should be added
     *   - commentDTO: The `CommentDTO` object containing the comment data to be added
     * - Throws: Throws an error if there is an issue adding the comment to Firestore
     */
    func addNewComment(teamDocId: String, commentDTO: CommentDTO) async throws {
        let teamManager = TeamManager()

        // Make sure the team document can be found with the team id given
        let teamDocId = try await teamManager.getTeamWithDocId(docId: teamDocId).id

        let commentDocument = commentCollection(teamDocId: teamDocId).document()
        let documentId = commentDocument.documentID // get the document ID
        
        // Create a new comment object
        let comment = DBComment(commentId: documentId, commentDTO: commentDTO)
        
        // Add the comment to the database
        try commentDocument.setData(from: comment, merge: false)
        print("done!")
    }
    
    
    /**
     * Removes a comment from the Firestore database
     * - Parameters:
     *   - teamId: The ID of the team from which the comment should be removed
     *   - commentId: The ID of the comment to be removed
     * - Throws: Throws an error if there is an issue deleting the comment
     */
    func removeComment(teamId: String, commentId: String) async throws {
        let teamManager = TeamManager()
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await teamManager.getTeam(teamId: teamId)?.id else {
            print("removeComment: Could not find team id. Aborting")
            return
        }
        
        try await commentDocument(teamDocId: teamDocId, commentDocId: commentId).delete()
    }
}

extension CommentManager {

    /// Fetch comments newer than `since` for many team doc IDs (no listeners).
    func fetchRecentComments(forTeamDocIds teamDocIds: [String], since: Date) async throws -> [DBComment] {
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
