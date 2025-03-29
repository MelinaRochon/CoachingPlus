//
//  UtilityFunctions.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-29.
//
//  This file contains helper functions used throughout the app
//  to improve code reuse and maintainability.
//

import Foundation

/** Converts a time interval (in seconds) into a formatted string (HH:MM:SS).
 - Parameter duration: The time interval in seconds.
 - Returns: A formatted string in "HH:MM:SS" format.
 */
func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
