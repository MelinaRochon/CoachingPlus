//
//  LocalTranscriptRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
@testable import GameFrameIOS

final class LocalTranscriptRepository: TranscriptRepository {
    private var transcripts: [GameFrameIOS.DBTranscript] = []
    
    func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> GameFrameIOS.DBTranscript? {
        return transcripts.first(where: { $0.transcriptId == transcriptId })
    }
    
    func getAllTranscripts(teamId: String, gameId: String) async throws -> [GameFrameIOS.DBTranscript]? {
        return transcripts.filter( { $0.gameId == gameId })
    }
    
    func getTranscriptsPreviewWithDocId(teamDocId: String, gameId: String) async throws -> [GameFrameIOS.DBTranscript]? {
        return transcripts.filter( { $0.gameId == gameId })
    }
    
    func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [GameFrameIOS.DBTranscript]? {
        return transcripts.filter( { $0.gameId == gameDocId })
    }
    
    func addNewTranscript(teamId: String, transcriptDTO: GameFrameIOS.TranscriptDTO) async throws -> String? {
        let id = UUID().uuidString
        let transcript = DBTranscript(transcriptId: id, transcriptDTO: transcriptDTO)
        transcripts.append(transcript)
        return id
    }
    
    func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        // Find the index of the transcript in the local array
        guard let index = transcripts.firstIndex(where: { $0.gameId == gameId && $0.transcriptId == transcriptId }) else {
            print("❌ Transcript not found with id: \(transcriptId)")
            return
        }
        
        // Remove the transcript from the local list
        transcripts.remove(at: index)
    }
    
    func deleteAllTranscripts(teamDocId: String, gameId: String) async throws {
        var transcriptsToBeRm = transcripts.filter( { $0.gameId == gameId })
        transcriptsToBeRm.removeAll()
    }
    
    func updateTranscript(teamDocId: String, gameId: String, transcriptId: String, transcript: String) async throws {
        // Find the index of the transcript in the local array
        guard let index = transcripts.firstIndex(where: { $0.gameId == gameId && $0.transcriptId == transcriptId }) else {
            print("❌ Transcript not found with id: \(transcriptId)")
            return
        }
        
        transcripts[index].transcript = transcript
    }
}
