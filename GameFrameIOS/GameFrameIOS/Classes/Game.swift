//
//  Game.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//


import Foundation
import SwiftUI

struct Game {
    var title: String
    var duration: Date
    var location: String
    var scheduledTime: Date
    var sport: String
    
    /** Settings for the game */
    var timeBeforeFeedback: Date
    var timeAfterFeedback: Date
    var getRecordingReminder: Bool
    
    
}
