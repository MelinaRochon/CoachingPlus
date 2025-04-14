//
//  GamesFunctions.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import Foundation


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
