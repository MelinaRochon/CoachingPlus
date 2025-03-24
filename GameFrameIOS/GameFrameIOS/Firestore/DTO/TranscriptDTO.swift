//
//  TranscriptDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
struct TranscriptDTO {
    let keyMomentId: String
    let transcript: String // transcription
    let language: String // Language of the transcript - Only english for now
    let generatedBy: String
    let confidence: Int
    let gameId: String
}
