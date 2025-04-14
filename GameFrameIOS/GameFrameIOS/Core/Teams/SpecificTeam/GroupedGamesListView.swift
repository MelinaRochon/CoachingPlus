//
//  GroupedGamesListView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI


/// A reusable SwiftUI view that displays a list of games grouped by weeks. Each week is labeled
/// as "This Week", "Last Week", or a date range for older weeks. This view handles navigation
/// to a detailed player-specific footage view when a game is selected.
///
/// - Parameters:
///   - groupedGames: An array of tuples where each tuple contains a `label` (e.g., "This Week")
///     and an array of `DBGame` objects belonging to that week.
///   - selectedTeam: The selected team to pass to the destination view for each game.
///   - destinationBuilder: A closure that constructs the destination view when a game is tapped.
///
/// - Example usage:
/// ```swift
/// GroupedGamesListView(
///     groupedGames: groupedGames,
///     selectedTeam: selectedTeam,
///     destinationBuilder: { game in
///         AnyView(PlayerSpecificFootageView(game: game, team: selectedTeam))
///     }
/// )
/// ```
struct GroupedGamesListView: View {
    let groupedGames: [(label: String, games: [DBGame])]
    let selectedTeam: DBTeam?
    let destinationBuilder: (DBGame) -> AnyView
    
    var body: some View {
        
        // Iterate through each group of games
        ForEach(groupedGames, id: \.label) { group in
            
            // Create a section for each week or time period
            Section(header: Text(group.label)) {
                
                // Iterate through each game in the group
                ForEach(group.games, id: \.gameId) { game in
                    
                    // Navigation link that opens the destination view for the selected game
                    NavigationLink(destination: destinationBuilder(game)) {
                        HStack(alignment: .top) {
                            // Custom UI for game preview
                            CustomUIFields.gameVideoPreviewStyle()
                            
                            VStack(alignment: .leading) {
                                Text(game.title)
                                    .font(.headline)
                                
                                Text(formatStartTime(game.startTime))
                                    .font(.subheadline)
                                
                                // If the game has a start time, check if it is a future game
                                if let startTime = game.startTime {
                                    let gameEndTime = startTime.addingTimeInterval(TimeInterval(game.duration))
                                    if gameEndTime > Date() {
                                        Text("Scheduled Game")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }
}
