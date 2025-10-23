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

        let dto = CommentDTO(
            keyMomentId: "KM050",
            gameId: "G050",
            transcriptId: "T050",
            uploadedBy: "uid999",
            comment: "New test comment",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )

        let comment = try await localRepo.addNewComment(teamDocId: teamDocId, commentDTO: dto)
        XCTAssertNotNil(comment, "Comment should exist after being added")
    }
    
    func testGetComment() async throws {
        let teamDocId = "test"

        let dto = CommentDTO(
            keyMomentId: "KM017",
            gameId: "G004",
            transcriptId: "T017",
            uploadedBy: "uid004",
            comment: "Patrick, take the time to look at this key moment.",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )

        let id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto)

        let c = try await localRepo.getComment(teamId: teamDocId, commentDocId: id)
        XCTAssertNotNil(c)
        XCTAssertEqual(c?.comment, "Patrick, take the time to look at this key moment.")
    }

    func testFilterByKeyMoment() async throws {
        let teamDocId = "test"

        let dto1 = CommentDTO(
            keyMomentId: "KM023",
            gameId: "G005",
            transcriptId: "T023",
            uploadedBy: "uid006",
            comment: "Coach, where should I aim to shoot next time?",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )
        let dto2 = CommentDTO(
            keyMomentId: "KM031",
            gameId: "G007",
            transcriptId: "T031",
            uploadedBy: "uid009",
            comment: "I noticed I was not well positioned. Coach, where can I be next time to help with the attack when it's a corner kick?",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )

        let comment1_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto1)
        let comment2_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto2)

        let tr = try await localRepo.getAllCommentsForSpecificKeyMomentId(teamId: teamDocId, keyMomentId: "KM031")
        XCTAssertEqual(tr?.count, 1)
        XCTAssertEqual(tr?.first?.commentId, comment2_id)
    }
    

    func testFilterByTranscript() async throws {
        let teamDocId = "test"

        let dto1 = CommentDTO(
            keyMomentId: "KM023",
            gameId: "G005",
            transcriptId: "T023",
            uploadedBy: "uid006",
            comment: "Coach, where should I aim to shoot next time?",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )
        let dto2 = CommentDTO(
            keyMomentId: "KM031",
            gameId: "G007",
            transcriptId: "T031",
            uploadedBy: "uid009",
            comment: "I noticed I was not well positioned. Coach, where can I be next time to help with the attack when it's a corner kick?",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )

        let comment1_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto1)
        let comment2_id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto2)

        let tr = try await localRepo.getAllCommentsForSpecificTranscriptId(teamDocId: teamDocId, transcriptId: "T023")
        XCTAssertEqual(tr?.count, 1)
        XCTAssertEqual(tr?.first?.commentId, comment1_id)
    }



    func testRemoveComment() async throws {
        let teamDocId = "test"

        let dto = CommentDTO(
            keyMomentId: "T049",
            gameId: "G010",
            transcriptId: "T049",
            uploadedBy: "uid001",
            comment: "Mason make sure to look at this key moment as it happens often.",
            createdAt: ISO8601DateFormatter().date(from: "2025-11-20T12:00:00Z")!
        )

        let id = try await localRepo.addNewCommentReturningId(teamDocId: teamDocId, commentDTO: dto)
        
        do {
            let beforeAll = try await localRepo.getAllComments(teamId: teamDocId) ?? []
            XCTAssertTrue(beforeAll.contains { $0.commentId == id })
        }

        try await localRepo.removeComment(teamId: teamDocId, commentId: id)

        let all = try await localRepo.getAllComments(teamId: teamDocId) ?? []
        XCTAssertFalse(all.contains { $0.commentId == id })
    }

    
}
