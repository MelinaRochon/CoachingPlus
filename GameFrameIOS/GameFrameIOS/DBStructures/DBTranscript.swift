//
//  DBTranscript.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation


/// Represents a transcript stored in Firestore, linked to a key moment in a game.
struct DBTranscript: Codable {
    let transcriptId: String
    let keyMomentId: String
    var transcript: String // transcription
    let language: String // Language of the transcript - Only english for now
    let generatedBy: String
    let confidence: Int
    let gameId: String
    
    init(transcriptId: String, keyMomentId: String, transcript: String, language: String, generatedBy: String, confidence: Int, gameId: String) {
        self.transcriptId = transcriptId
        self.keyMomentId = keyMomentId
        self.transcript = transcript
        self.language = language
        self.generatedBy = generatedBy
        self.confidence = confidence
        self.gameId = gameId
    }
    
    init(transcriptId: String, transcriptDTO: TranscriptDTO) {
        self.transcriptId = transcriptId
        self.keyMomentId = transcriptDTO.keyMomentId
        self.transcript = transcriptDTO.transcript
        self.language = transcriptDTO.language
        self.generatedBy = transcriptDTO.generatedBy
        self.confidence = transcriptDTO.confidence
        self.gameId = transcriptDTO.gameId
    }
    
    enum CodingKeys: String, CodingKey {
        case transcriptId = "transcript_id"
        case keyMomentId = "key_moment_id"
        case transcript = "transcript"
        case language = "language"
        case generatedBy = "generated_by"
        case confidence = "confidence"
        case gameId = "game_id"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transcriptId = try container.decode(String.self, forKey: .transcriptId)
        self.keyMomentId = try container.decode(String.self, forKey: .keyMomentId)
        self.transcript = try container.decode(String.self, forKey: .transcript)
        self.language = try container.decode(String.self, forKey: .language)
        self.generatedBy = try container.decode(String.self, forKey: .generatedBy)
        self.confidence = try container.decode(Int.self, forKey: .confidence)
        self.gameId = try container.decode(String.self, forKey: .gameId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.transcriptId, forKey: .transcriptId)
        try container.encode(self.keyMomentId, forKey: .keyMomentId)
        try container.encode(self.transcript, forKey: .transcript)
        try container.encode(self.language, forKey: .language)
        try container.encode(self.generatedBy, forKey: .generatedBy)
        try container.encode(self.confidence, forKey: .confidence)
        try container.encode(self.gameId, forKey: .gameId)
    }
}
