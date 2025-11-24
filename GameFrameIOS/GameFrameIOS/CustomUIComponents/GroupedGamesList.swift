//
//  GroupedGamesList.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI
import GameFrameIOSShared

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
/// GroupedGamesList(
///     groupedGames: groupedGames,
///     selectedTeam: selectedTeam,
///     destinationBuilder: { game in
///         AnyView(PlayerSpecificFootageView(game: game, team: selectedTeam))
///     }
/// )
/// ```
struct GroupedGamesList: View {
    let groupedGames: [(label: String, games: [DBGame])]
    let selectedTeam: DBTeam

    let showUpcomingGames: Bool
    let showRecentGames: Bool
    let userType: UserType
        
    var body: some View {
        
        // Iterate through each group of games
        // MARK: Upcoming Games Section
        if showUpcomingGames {
            let upcomingGames = groupedGames.first(where: { $0.label == "Upcoming Games" })
            if let upcomingGames = upcomingGames {
                // Create a section for each week or time period
                Section(header: HStack{
                    Text(upcomingGames.label).font(.subheadline).foregroundStyle(.black)
                    Spacer()
                }.padding(.top, 5)
                ) {
                    ForEach(upcomingGames.games, id: \.gameId) { game in
                        NavigationLink(destination: SelectedScheduledGameView(selectedGame: HomeGameDTO(id: game.gameId, game: game, team: selectedTeam), userType: userType)) {
                            GameRow(game: game)
                        }
                    }
                }
            }
        }
        
        // MARK: Recent/Past Games Section
        if showRecentGames {
            let pastGroups = groupedGames.filter { $0.label != "Upcoming Games" }
            ForEach(pastGroups, id: \.label) { group in
                // Create a section for each week or time period
                Section(header: HStack{
                    Text(group.label).font(.subheadline).foregroundStyle(.black)
                    Spacer()
                }.padding(.top, 5)
                ) {
                    ForEach(group.games, id: \.gameId) { game in
                        if userType == .coach {
                            NavigationLink(destination: CoachSpecificFootageView(game: game, team: selectedTeam)) {
                                GameRow(game: game)
                            }
                        } else {
                            NavigationLink(destination: PlayerSpecificFootageView(game: game, team: selectedTeam)) {
                                GameRow(game: game)
                            }
                        }
                    }
                }
            }
        }
    }
}


/// A SwiftUI view representing a single row for a game in a list.
/// Displays a preview style element and basic information about the game.
///
/// - Parameters:
///   - game: The `DBGame` object to display in the row.
struct GameRow: View {
    let game: DBGame
    
    var body: some View {
        HStack {
            // Custom preview for the game video or thumbnail
           CustomUIFields.gameVideoPreviewStyle()
                       
            VStack(alignment: .leading) {
                // Display the game title
                Text(game.title).font(.headline)
                
                // Display formatted start time
                Text(formatStartTime(game.startTime)).font(.subheadline)
            }
        }
    }
}


/// A reusable SwiftUI view that displays a list of games with navigation links to a
/// custom destination view for each game. Can be used for upcoming or past games.
///
/// - Parameters:
///   - games: The array of `DBGame` objects to display.
///   - destinationBuilder: A closure that returns a SwiftUI `View` representing the
///     destination when a game row is tapped.
struct GamesList<Destination: View>: View {
    let games: [DBGame]
    let destinationBuilder: (DBGame) -> Destination

    var body: some View {
        ForEach(games, id: \.gameId) { game in
            NavigationLink(destination: destinationBuilder(game)) {
                HStack(alignment: .top) {
                    CustomUIFields.gameVideoPreviewStyle()
                    
                    VStack(alignment: .leading) {
                        Text(game.title).font(.headline)
                        Text(formatStartTime(game.startTime)).font(.subheadline)
                        
                        // Show "Scheduled Game" badge for upcoming games
                        if let startTime = game.startTime,
                           startTime.addingTimeInterval(TimeInterval(game.duration)) > Date() {
                            Text("Scheduled Game")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
