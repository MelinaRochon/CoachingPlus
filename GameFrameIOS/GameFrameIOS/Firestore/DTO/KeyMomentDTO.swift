//
//  KeyMomentDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation
struct KeyMomentDTO {
    let fullGameId: String // shouldn't this also be String? might not be a video recording...
    let gameId: String
    let uploadedBy: String
    let audioUrl: String?
    let frameStart: Date // transcription start
    let frameEnd: Date // transcription end
    let feedbackFor: [DBPlayer]?
}
