//
//  FullGameVideoRecordingDTO.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation

struct FullGameVideoRecordingDTO {
    let fullGameVideoRecordingId: String
    let gameId: String
    let uploadedBy: String
    let fileURL: String?
    let startTime: Date
    let endTime: Date?
}
