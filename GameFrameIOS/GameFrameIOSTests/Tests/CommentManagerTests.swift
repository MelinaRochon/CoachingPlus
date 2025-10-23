//
//  CommentManagerTests.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-10-21.
//

import XCTest
@testable import GameFrameIOS

final class CommentManagerTests: XCTestCase {
    var manager: CommentManager!
    var localRepo: LocalCommentRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalCommentRepository()
        manager = CommentManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }

    func testAddNewComment() async throws {
        let teamDocId = "test"
        
        let sampleComments: [DBComment] = TestDataLoader.load("TestComments", as: [DBComment].self)
        guard let sampleComment = sampleComments.first else { return }

        let dto = CommentDTO(
            keyMomentId: sampleComment.keyMomentId,
            gameId: sampleComment.gameId,
            transcriptId: sampleComment.transcriptId,
            uploadedBy: sampleComment.uploadedBy,
            comment: sampleComment.comment,
            createdAt: sampleComment.createdAt
        )

        let comment = try await manager.addNewComment(teamDocId: teamDocId, commentDTO: dto)
        XCTAssertNotNil(comment, "Comment should exist after being added")
    }
    
    func testGetComment() async throws {
        let teamDocId = "test"
        
        let sampleComments: [DBComment] = TestDataLoader.load("TestComments", as: [DBComment].self)
        guard let sampleComment = sampleComments.first else { return }

        let dto = CommentDTO(
            keyMomentId: sampleComment.keyMomentId,
            gameId: sampleComment.gameId,
            transcriptId: sampleComment.transcriptId,
            uploadedBy: sampleComment.uploadedBy,
            comment: sampleComment.comment,
            createdAt: sampleComment.createdAt
        )

        let id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto)

        let c = try await manager.getComment(teamId: teamDocId, commentDocId: id)
        XCTAssertNotNil(c)
        XCTAssertEqual(c?.comment, sampleComment.comment)
    }

    func testFilterByKeyMoment() async throws {
        let teamDocId = "test"
        
        let sampleComments: [DBComment] = TestDataLoader.load("TestComments", as: [DBComment].self)
        guard let sampleComment1 = sampleComments.first else { return }
        guard let sampleComment2 = sampleComments.last else { return }

        let dto1 = CommentDTO(
            keyMomentId: sampleComment1.keyMomentId,
            gameId: sampleComment1.gameId,
            transcriptId: sampleComment1.transcriptId,
            uploadedBy: sampleComment1.uploadedBy,
            comment: sampleComment1.comment,
            createdAt: sampleComment1.createdAt
        )
        let dto2 = CommentDTO(
            keyMomentId: sampleComment2.keyMomentId,
            gameId: sampleComment2.gameId,
            transcriptId: sampleComment2.transcriptId,
            uploadedBy: sampleComment2.uploadedBy,
            comment: sampleComment2.comment,
            createdAt: sampleComment2.createdAt
        )

        let comment1_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto1)
        let comment2_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto2)

        let tr = try await manager.getAllCommentsForSpecificKeyMomentId(teamId: teamDocId, keyMomentId: sampleComment2.keyMomentId)
        XCTAssertEqual(tr?.count, 1)
        XCTAssertEqual(tr?.first?.commentId, comment2_id)
    }
    

    func testFilterByTranscript() async throws {
        let teamDocId = "test"

        let sampleComments: [DBComment] = TestDataLoader.load("TestComments", as: [DBComment].self)
        guard let sampleComment1 = sampleComments.first else { return }
        guard let sampleComment2 = sampleComments.last else { return }

        let dto1 = CommentDTO(
            keyMomentId: sampleComment1.keyMomentId,
            gameId: sampleComment1.gameId,
            transcriptId: sampleComment1.transcriptId,
            uploadedBy: sampleComment1.uploadedBy,
            comment: sampleComment1.comment,
            createdAt: sampleComment1.createdAt
        )
        let dto2 = CommentDTO(
            keyMomentId: sampleComment2.keyMomentId,
            gameId: sampleComment2.gameId,
            transcriptId: sampleComment2.transcriptId,
            uploadedBy: sampleComment2.uploadedBy,
            comment: sampleComment2.comment,
            createdAt: sampleComment2.createdAt
        )

        let comment1_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto1)
        let comment2_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto2)

        let tr = try await manager.getAllCommentsForSpecificTranscriptId(teamDocId: teamDocId, transcriptId: sampleComment1.transcriptId)
        XCTAssertEqual(tr?.count, 1)
        XCTAssertEqual(tr?.first?.commentId, comment1_id)
    }



    func testRemoveComment() async throws {
        let teamDocId = "test"
        
        let sampleComments: [DBComment] = TestDataLoader.load("TestComments", as: [DBComment].self)
        guard let sampleComment = sampleComments.first else { return }

        let dto = CommentDTO(
            keyMomentId: sampleComment.keyMomentId,
            gameId: sampleComment.gameId,
            transcriptId: sampleComment.transcriptId,
            uploadedBy: sampleComment.uploadedBy,
            comment: sampleComment.comment,
            createdAt: sampleComment.createdAt
        )

        let id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto)
        
        do {
            let beforeAll = try await manager.getAllComments(teamId: teamDocId) ?? []
            XCTAssertTrue(beforeAll.contains { $0.commentId == id })
        }

        try await manager.removeComment(teamId: teamDocId, commentId: id)

        let all = try await manager.getAllComments(teamId: teamDocId) ?? []
        XCTAssertFalse(all.contains { $0.commentId == id })
    }

    
}
