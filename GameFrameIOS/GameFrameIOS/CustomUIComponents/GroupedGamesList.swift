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
    let groupedGames: [(label: String, games: [IndexedFootage])]
    let selectedTeam: DBTeam

    let showUpcomingGames: Bool
    let showRecentGames: Bool
    let userType: UserType
    let gameModel: GameModel
        
    var body: some View {
        
        // Iterate through each group of games
        // MARK: Upcoming Games Section
        if showUpcomingGames {
            let upcomingGames = groupedGames.first(where: { $0.label == "Upcoming Games" })
            if let upcomingGames = upcomingGames {
                // Create a section for each week or time period
                Section(header:
                    VStack {
                        CustomUIFields.customDivider(upcomingGames.label)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                    }
                    .background(Color(.systemBackground))
                ) {
                    ForEach(upcomingGames.games, id: \.id) { game in
                        NavigationLink(destination: SelectedScheduledGameView(selectedGame: HomeGameDTO(id: game.id, game: game.game, team: selectedTeam), userType: userType)) {
                            VStack {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 5)
                                    VStack (alignment: .leading, spacing: 4) {
                                        Text(game.game.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        Text(formatStartTime(game.game.startTime))
                                            .font(.subheadline)
                                            .padding(.leading, 1)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .padding(.leading)
                                        .padding(.trailing, 5)
                                }
                                .padding(.vertical, 5)
                                Divider()
                            }
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
                Section(header:
                    VStack {
                        CustomUIFields.customDivider(group.label)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                    }
                    .background(Color(.systemBackground))
                ) {
                    ForEach(group.games, id: \.id) { game in
                        if userType == .coach {
                            NavigationLink(destination: CoachSpecificFootageView(game: game.game, team: selectedTeam, gameModel: gameModel)) {
                                GameRow(
                                    isFullGame: game.isFullGame,
                                    title: game.game.title,
                                    startTimeString: formatStartTime(game.game.startTime)
                                )
                            }
                        } else {
                            NavigationLink(destination: PlayerSpecificFootageView(game: game.game, team: selectedTeam)) {
                                GameRow(
                                    isFullGame: game.isFullGame,
                                    title: game.game.title,
                                    startTimeString: formatStartTime(game.game.startTime)
                                )
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
    let isFullGame: Bool
    let title: String
    let startTimeString: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: isFullGame ? "video.fill" : "microphone.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .padding(.horizontal, 5)
                VStack (alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                    Text(startTimeString)
                        .font(.subheadline)
                        .padding(.leading, 1)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.leading)
                    .padding(.trailing, 5)
            }
            .padding(.vertical, 5)
            Divider()
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
