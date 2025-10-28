//
//  LocalTranscriptRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

public final class LocalTranscriptRepository: TranscriptRepository {
    private var transcripts: [DBTranscript] = []
    
    public init(transcripts: [DBTranscript]? = nil) {
        // If no transcripts provided, fallback to default JSON
        self.transcripts = transcripts ?? TestDataLoader.load("TestTranscripts", as: [DBTranscript].self)
    }

    
    public func getTranscript(teamId: String, gameId: String, transcriptId: String) async throws -> DBTranscript? {
        guard let transcript = transcripts.first(where: { $0.transcriptId == transcriptId && $0.gameId == gameId }) else {
            throw TranscriptError.transcriptNotFound
        }
        return transcript
    }
    
    public func getAllTranscripts(teamId: String, gameId: String) async throws -> [DBTranscript]? {
        let filtered = transcripts.filter { $0.gameId == gameId }
        if filtered.isEmpty {
            throw TranscriptError.transcriptNotFound
        }
        return filtered
    }
    
    public func getTranscriptsPreviewWithDocId(teamDocId: String, gameId: String) async throws -> [DBTranscript]? {
        let filtered = transcripts.filter { $0.gameId == gameId }
        if filtered.isEmpty {
            throw TranscriptError.transcriptNotFound
        }
        return Array(filtered.prefix(3))
    }
    
    public func getAllTranscriptsWithDocId(teamDocId: String, gameDocId: String) async throws -> [DBTranscript]? {
        let filtered = transcripts.filter( { $0.gameId == gameDocId })
        if filtered.isEmpty {
            throw TranscriptError.transcriptNotFound
        }
        return filtered
    }
    
    public func addNewTranscript(teamId: String, transcriptDTO: TranscriptDTO) async throws -> String? {
        let id = UUID().uuidString
        let transcript = DBTranscript(transcriptId: id, transcriptDTO: transcriptDTO)
        transcripts.append(transcript)
        return id
    }
    
    public func removeTranscript(teamId: String, gameId: String, transcriptId: String) async throws {
        // Find the index of the transcript in the local array
        guard let index = transcripts.firstIndex(where: { $0.gameId == gameId && $0.transcriptId == transcriptId }) else {
            print("❌ Transcript not found with id: \(transcriptId)")
            throw TranscriptError.transcriptNotFound
        }
        
        // Remove the transcript from the local list
        transcripts.remove(at: index)
    }
    
    public func deleteAllTranscripts(teamDocId: String, gameId: String) async throws {
        transcripts.removeAll(where: { $0.gameId == gameId })
    }
    
    public func updateTranscript(teamDocId: String, gameId: String, transcriptId: String, transcript: String) async throws {
        // Find the index of the transcript in the local array
        guard let index = transcripts.firstIndex(where: { $0.gameId == gameId && $0.transcriptId == transcriptId }) else {
            print("❌ Transcript not found with id: \(transcriptId)")
            throw TranscriptError.transcriptNotFound
        }
        
        transcripts[index].transcript = transcript
    }
}
