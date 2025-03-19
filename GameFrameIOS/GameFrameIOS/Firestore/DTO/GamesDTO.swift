//
//  GameDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import Foundation

struct GameDTO {
    let title: String
    let duration: Int
    let location: String?
    let scheduledTimeReminder: Int // in minutes
    let startTime: Date?
    let timeBeforeFeedback: Int // in seconds
    let timeAfterFeedback: Int // in seconds
    let recordingReminder: Bool
    let teamId: String
}
