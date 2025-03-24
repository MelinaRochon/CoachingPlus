//
//  CommentManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
import FirebaseFirestore

struct DBComment: Codable {
    let commentId: String
    let keyMomentId: String
    let gameId: String
    let transcriptId: String
    let uploadedBy: String
    let comment: String
    let createdAt: Date
    
    init(commentId: String, keyMomentId: String, gameId: String, transcriptId: String, uploadedBy: String, comment: String, createdAt: Date) {
        self.commentId = commentId
        self.keyMomentId = keyMomentId
        self.gameId = gameId
        self.transcriptId = transcriptId
        self.uploadedBy = uploadedBy
        self.comment = comment
        self.createdAt = createdAt
    }
    
    init(commentId: String, commentDTO: CommentDTO) {
        self.commentId = commentId
        self.keyMomentId = commentDTO.keyMomentId
        self.gameId = commentDTO.gameId
        self.transcriptId = commentDTO.transcriptId
        self.uploadedBy = commentDTO.uploadedBy
        self.comment = commentDTO.comment
        self.createdAt = commentDTO.createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case keyMomentId = "key_moment_id"
        case gameId = "game_id"
        case transcriptId = "transcript_id"
        case uploadedBy = "uploaded_by"
        case comment = "comment"
        case createdAt = "created_at"
    }

    
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

final class CommentManager {
    static let shared = CommentManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    /** Returns a specific comment document */
    func commentDocument(teamDocId: String, commentDocId: String) -> DocumentReference {
        return commentCollection(teamDocId: teamDocId).document(commentDocId)
    }

    /** Returns the comment collection */
    func commentCollection(teamDocId: String) -> CollectionReference {
        return TeamManager.shared.teamCollection.document(teamDocId).collection("comments")
    }
    
    /** GET - Returns a specific comment document from the database */
    func getComment(teamId: String, commentDocId: String) async throws -> DBComment? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        return try await commentDocument(teamDocId: teamDocId, commentDocId: commentDocId).getDocument(as: DBComment.self)
    }
    
    /** GET - Returns all comments from the database */
    func getAllComments(teamId: String) async throws -> [DBComment]? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        // Get all documents in the comments collection
        let snapshot = try await commentCollection(teamDocId: teamDocId).getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    /** GET - Returns all comments that are associated to a specific key moment from the database */
    func getAllCommentsForSpecificKeyMomentId(teamId: String, keyMomentId: String) async throws -> [DBComment]? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        let query = try await commentCollection(teamDocId: teamDocId).whereField("key_moment_id", isEqualTo: keyMomentId).getDocuments()
        
        return query.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    /** GET - Returns all comments that are associated to a specific transcript from the database */
    func getAllCommentsForSpecificTranscriptId(teamId: String, transcriptId: String) async throws -> [DBComment]? {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return nil
        }
        
        let query = try await commentCollection(teamDocId: teamDocId).whereField("transcript_id", isEqualTo: transcriptId).getDocuments()
        
        return query.documents.compactMap { document in
            try? document.data(as: DBComment.self)
        }
    }
    
    /** POST - Add a new comment to the database */
    func addNewComment(teamId: String, commentDTO: CommentDTO) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }

        let commentDocument = commentCollection(teamDocId: teamDocId).document()
        let documentId = commentDocument.documentID // get the document ID
        
        // Create a new comment object
        let comment = DBComment(commentId: documentId, commentDTO: commentDTO)
        
        // Add the comment to the database
        try commentDocument.setData(from: comment, merge: false)
    }
    
    /** DELETE - Remove a comment from the database */
    func removeComment(teamId: String, commentId: String) async throws {
        // Make sure the team document can be found with the team id given
        guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
            print("Could not find team id. Aborting")
            return
        }
        
        try await commentDocument(teamDocId: teamDocId, commentDocId: commentId).delete()
    }
}
