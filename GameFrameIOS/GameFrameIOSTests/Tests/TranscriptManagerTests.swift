//
//  TranscriptManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-23.
//

import XCTest
@testable import GameFrameIOSShared

final class TranscriptManagerTests: XCTestCase {
    var manager: TranscriptManager!
    var localRepo: LocalTranscriptRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalTranscriptRepository()
        manager = TranscriptManager(repo: localRepo)
    }
    
    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }
    
    func testGetTranscript() async throws {
        let teamId = "team1"
        let gameId = "G001"
        let transcriptId = "T001"
        
        let transcript = try await manager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
        
        XCTAssertNotNil(transcript)
        XCTAssertEqual(transcript?.transcriptId, transcriptId, "Transcript IDs should match")
        XCTAssertEqual(transcript?.gameId, gameId, "Game IDs should match")
    }
    
    func testGetAllTranscripts() async throws {
        let teamId = "team1"
        let gameId = "G001"
        let transcripts = try await manager.getAllTranscripts(teamId: teamId, gameId: gameId)
        
        XCTAssertNotNil(transcripts)
        XCTAssertEqual(transcripts?.count, 5, "There should be 5 transcripts for this game")
        XCTAssertEqual(transcripts?.first?.gameId, gameId, "Game IDs should match")
    }
    
    func testGetTranscriptsPreviewWithDocId() async throws {
        let teamDocId = "uidT001"
        let gameId = "G001"
        let transcripts = try await manager.getTranscriptsPreviewWithDocId(teamDocId: teamDocId, gameId: gameId)
        
        XCTAssertNotNil(transcripts)
        XCTAssertLessThanOrEqual(transcripts?.count ?? 0, 3, "There should be 3 transcripts for this game")
        XCTAssertEqual(transcripts?.first?.gameId, gameId, "Game IDs should match")
    }
    
    func testGetAllTranscriptsWithDocId() async throws {
        let teamDocId = "uidT001"
        let gameId = "G001"
        let transcripts = try await manager.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId)
        
        XCTAssertNotNil(transcripts)
        XCTAssertEqual(transcripts?.first?.gameId, gameId, "Game IDs should match")
    }
    
    func testAddNewTranscript() async throws {
        let teamId = "team1"
        let gameId = "G001"
        
        // Add a new transcript
        let transcriptDTO = TranscriptDTO(
            keyMomentId: "KM001",
            transcript: "This is a test transcript",
            language: "en",
            generatedBy: "system",
            confidence: 5,
            gameId: gameId
        )
        let transcriptId = try await manager.addNewTranscript(teamId: teamId, transcriptDTO: transcriptDTO)
        XCTAssertNotNil(transcriptId)
        let transcript = try await manager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId!)
        
        XCTAssertNotNil(transcript)
        XCTAssertEqual(transcript?.gameId, gameId)
        XCTAssertEqual(transcript?.transcript, transcriptDTO.transcript, "Transcript content should match")
        XCTAssertEqual(transcript?.gameId, gameId, "Game IDs should match")
    }
    
    func testDeleteTranscript() async throws {
        let teamId = "team1"
        let gameId = "G001"
        let transcriptId = "T001"
        
        // Make sure the transcript to be deleted exists
        let transcriptToBeRm = try await manager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
        XCTAssertNotNil(transcriptToBeRm)
        XCTAssertEqual(transcriptToBeRm?.gameId, gameId)
        XCTAssertEqual(transcriptToBeRm?.transcriptId, transcriptId)
        
        // Removing transcript
        try await manager.removeTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
        do {
            _ = try await manager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeleteAllTranscripts() async throws {
        let teamDocId = "uidT001"
        let gameId = "G001"
        let teamId = "team1"
        
        // Make sure we have at least one transcript
        let tmpTranscripts = try await manager.getAllTranscripts(teamId: teamId, gameId: gameId)
        XCTAssertNotNil(tmpTranscripts)
        XCTAssertEqual(tmpTranscripts?.first?.gameId, gameId)
        XCTAssertGreaterThan(tmpTranscripts?.count ?? 0, 1)
        
        // Delete all transcripts
        try await manager.deleteAllTranscripts(teamDocId: teamDocId, gameId: gameId)
        do {
            _ = try await manager.getAllTranscripts(teamId: teamId, gameId: gameId)

            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateTranscript() async throws {
        let teamDocId = "uidT001"
        let gameId = "G001"
        let transcriptId = "T001"
        let transcript = "This is the new transcript"
        
        // Make sure what's being updated does not match the previous settings
        let tmpTranscript = try await manager.getTranscript(teamId: "team1", gameId: gameId, transcriptId: transcriptId)
        XCTAssertNotNil(tmpTranscript)
        XCTAssertEqual(tmpTranscript?.gameId, gameId)
        XCTAssertEqual(tmpTranscript?.transcriptId, transcriptId)
        XCTAssertNotEqual(tmpTranscript?.transcript, transcript)

        // Update the transcript
        try await manager.updateTranscript(
            teamDocId: teamDocId,
            gameId: gameId,
            transcriptId: transcriptId,
            transcript: transcript
        )
        let updatedTranscript = try await manager.getTranscript(teamId: "team1", gameId: gameId, transcriptId: transcriptId)
        
        XCTAssertNotNil(updatedTranscript)
        XCTAssertEqual(updatedTranscript?.gameId, gameId)
        XCTAssertEqual(updatedTranscript?.transcriptId, transcriptId)
        XCTAssertEqual(updatedTranscript?.transcript, transcript, "Transcript should be updated correctly")
    }
    
    // MARK: Negative Testing
    
    func testGetInvalidTranscript() async throws {
        let teamId = "team1"
        let gameId = "GAME_1"
        let transcriptId = "Tid_1"
        
        do {
            _ = try await manager.getTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetAllInvalidTranscripts() async throws {
        let teamId = "team1"
        let gameId = "GAME_1"
        
        do {
            _ = try await manager.getAllTranscripts(teamId: teamId, gameId: gameId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetInvalidTranscriptsPreviewWithDocId() async throws {
        let teamDocId = "uidT001"
        let gameId = "GAME_1"
        
        do {
            _ = try await manager.getTranscriptsPreviewWithDocId(teamDocId: teamDocId, gameId: gameId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetAllInvalidTranscriptsWithDocId() async throws {
        let teamDocId = "uidT001"
        let gameId = "GAME_1"
        
        do {
            _ = try await manager.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testRemoveNotExistentTranscript() async {
        let teamId = "invaliduidT001"
        let gameId = "GAME_1"
        let transcriptId = "invalidT1"
        
        do {
            _ = try await manager.removeTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
            XCTFail("Expected error not thrown")
        } catch TranscriptError.transcriptNotFound {
            // Error catch
            print("TranscriptError.transcriptNotFound error catched.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
