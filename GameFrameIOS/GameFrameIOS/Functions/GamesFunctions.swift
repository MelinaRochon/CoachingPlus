//
//  GamesFunctions.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import Foundation
import GameFrameIOSShared


/// Groups an array of `DBGame` objects into weekly sections, labeling each group as
/// "This Week", "Last Week", or a formatted date range for older weeks.
///
/// The games are grouped based on the start of the week in which their `startTime` occurs.
/// Games without a `startTime` are grouped using the current date's week.
///
/// - Parameter games: An array of `DBGame` objects to group.
/// - Returns: An array of tuples where each tuple contains a `label` (e.g., "This Week")
///            and an array of `DBGame` objects belonging to that week.
func groupGamesByWeek(_ games: [DBGame]) -> [(label: String, games: [DBGame])] {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    let now = Date()
    
    let futureGames = games.filter { ($0.startTime ?? now) > now }
    let pastGames = games.filter { ($0.startTime ?? now) <= now }

    
    // Group games by the start of their week.
    let groupedPast = Dictionary(grouping: pastGames) { game -> Date in
        game.startTime?.startOfWeek(using: calendar) ?? Date().startOfWeek(using: calendar)
    }
    
    let sortedGroupedPast: [(String, [DBGame])] = groupedPast
        .sorted { $0.key > $1.key } // Sort weeks in ascending order (oldest last)
        .map { (startOfWeek, games) in
            
            let endOfWeek = startOfWeek.endOfWeek(using: calendar)
            
            // Determine how many weeks ago this group is from now
            let weeksAgo = startOfWeek.weeksAgo(from: now)
            
            // Label the section based on how recent the week is
            let label: String
            switch weeksAgo {
            case 0:
                label = "This Week"
            case 1:
                label = "Last Week"
            default:
                label = "\(formatter.string(from: startOfWeek)) – \(formatter.string(from: endOfWeek))"
            }
            
            // Sort games within each section by descending start time
            return (label: label, games: games.sorted { $0.startTime ?? Date() > $1.startTime ?? Date() })
        }
    
    // Combine into one list
    var result: [(String, [DBGame])] = []
    if !futureGames.isEmpty {
        result.append(("Upcoming Games", futureGames.sorted { $0.startTime ?? now > $1.startTime ?? now }))
    }
    result.append(contentsOf: sortedGroupedPast)
    
    return result
}


/// Returns a user-friendly label describing the reminder time in minutes.
///
/// - Parameter minutes: The reminder time in minutes (e.g., 0, 5, 10, 60).
///
/// - Returns: A `String` label for the given reminder time:
///   - If the value exists in `AppData.timeOptions`, the predefined label is returned
///     (e.g., `"At time of event"` or `"5 minutes before"`).
///   - If no predefined label exists, the function generates a fallback:
///       - `"X minutes before"` if the value is not a multiple of 60
///       - `"Y hour(s) before"` if the value is divisible by 60
func labelForReminder(_ minutes: Int) -> String {
    // Try to find an exact match in timeOptions
    if let option = AppData.timeOptions.first(where: { $0.1 == minutes }) {
        return option.0
    }
    
    // Fallback if the value is not in timeOptions
    if minutes % 60 == 0 {
        return "\(minutes / 60) hour\(minutes == 60 ? "" : "s") before"
    } else {
        return "\(minutes) minutes before"
    }
}
