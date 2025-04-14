//
//  GameList.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI


/// A SwiftUI view that displays a list of recent games with navigation to a detailed view for each game.
/// Each game is presented with its title, team name, and start time. When a game is tapped, the destination
/// view, defined by `destinationBuilder`, is shown with the selected game's details.
///
/// - Parameters:
///   - games: An array of `HomeGameDTO` objects to be displayed in the list.
///   - destinationBuilder: A closure that takes a `HomeGameDTO?` and returns a view (`AnyView`) to be displayed
///                         when the game is selected.
///
/// - Example usage:
/// ```swift
/// GameList(
///     games: recentGames,
///     prefix: 3,
///     gameType: .recent,
///     destinationBuilder: { game in
///         AnyView(GameDetailView(game: game))
///     }
/// )
/// ```
struct GameList: View {
    let games: [HomeGameDTO]
    let prefix: Int?
    let gameType: GameTypeEnum
    let destinationBuilder: (HomeGameDTO?) -> AnyView

    var body: some View {
        
        // Iterate through each games
        // Safely unwrap prefix to get the first N games, or return the full list if nil.
        let recentGames = prefix.map { Array(games.prefix($0)) } ?? games

        ForEach(recentGames, id: \.game.gameId) { game in
            
            // Navigation link that opens the destination view for the selected game
            NavigationLink(destination: destinationBuilder(game)) {
                HStack {
                    
                    if gameType == .recent {
                        // Custom UI for game preview
                        CustomUIFields.gameVideoPreviewStyle()
                    }
                    
                    VStack {
                        Text(game.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        Text(game.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        Text(formatStartTime(game.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }.foregroundColor(.black)
        }
    }
}
