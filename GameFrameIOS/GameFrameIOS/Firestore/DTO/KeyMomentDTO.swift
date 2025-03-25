//
//  KeyMomentDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
struct KeyMomentDTO {
    let fullGameId: String?
    let gameId: String
    let uploadedBy: String
    let audioUrl: String?
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [String]?
}
