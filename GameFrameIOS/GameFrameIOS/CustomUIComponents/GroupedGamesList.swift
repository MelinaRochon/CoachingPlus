//
//  GroupedGamesList.swift
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
                        NavigationLink(destination: SelectedScheduledGameView(selectedGame: HomeGameDTO(game: game, team: selectedTeam), userType: userType)) {
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


//#Preview {
//    let groupedGames: [(String, [DBGame])] = [
//        (
//            "This Week",
//            [
//                DBGame(
//                    gameId: "game1",
//                    title: "Practice Match",
//                    duration: 5400,
//                    location: "Field A",
//                    scheduledTimeReminder: 30,
//                    startTime: Date(), // Now
//                    timeBeforeFeedback: 60,
//                    timeAfterFeedback: 120,
//                    recordingReminder: true,
//                    teamId: "teamA"
//                ),
//                DBGame(
//                    gameId: "game2",
//                    title: "Training Session",
//                    duration: 3600,
//                    location: "Gym",
//                    scheduledTimeReminder: 15,
//                    startTime: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
//                    timeBeforeFeedback: 30,
//                    timeAfterFeedback: 90,
//                    recordingReminder: false,
//                    teamId: "teamA"
//                ),
//                DBGame(
//                    gameId: "game3",
//                    title: "Friendly Game",
//                    duration: 7200,
//                    location: nil,
//                    scheduledTimeReminder: 60,
//                    startTime: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
//                    timeBeforeFeedback: 45,
//                    timeAfterFeedback: 120,
//                    recordingReminder: true,
//                    teamId: "teamA"
//                )
//            ]
//        ),
//        (
//            "Last Week",
//            [
//                DBGame(
//                    gameId: "game4",
//                    title: "League Game",
//                    duration: 5400,
//                    location: "Stadium",
//                    scheduledTimeReminder: 20,
//                    startTime: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
//                    timeBeforeFeedback: 60,
//                    timeAfterFeedback: 120,
//                    recordingReminder: true,
//                    teamId: "teamB"
//                ),
//                DBGame(
//                    gameId: "game5",
//                    title: "Strategy Practice",
//                    duration: 3600,
//                    location: "Indoor Arena",
//                    scheduledTimeReminder: 10,
//                    startTime: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
//                    timeBeforeFeedback: 30,
//                    timeAfterFeedback: 90,
//                    recordingReminder: false,
//                    teamId: "teamB"
//                ),
//                DBGame(
//                    gameId: "game6",
//                    title: "Recovery Session",
//                    duration: 1800,
//                    location: nil,
//                    scheduledTimeReminder: 15,
//                    startTime: Calendar.current.date(byAdding: .day, value: -9, to: Date()),
//                    timeBeforeFeedback: 15,
//                    timeAfterFeedback: 45,
//                    recordingReminder: false,
//                    teamId: "teamB"
//                )
//            ]
//        )
//    ]
//    
//    let exampleTeam = DBTeam(
//        id: "team001",
//        teamId: "t001",
//        name: "Lions Soccer Club",
//        teamNickname: "Lions",
//        sport: "Soccer",
//        logoUrl: "https://example.com/logos/lions.png",
//        colour: "#FFD700", // Gold color
//        gender: "Mixed",
//        ageGrp: "U18",
//        accessCode: "JOINLIONS2025",
//        coaches: ["coach123", "coach456"],
//        players: ["player001", "player002", "player003"],
//        invites: ["invite001", "invite002"]
//    )
//
//    List {
//        Section(header:
//                    HStack {
//            Text("Games")
//            Spacer()
//            Button{
//                //                addGameEnabled.toggle() // Toggles the Add Game form visibility
//            } label: {
//                // Button to add a new game
//                HStack {
//                    Text("Add Game")
//                }
//                .foregroundColor(Color.blue)
//            }
//        }) {
//            
//            GroupedGamesList(
//                groupedGames: groupedGames,
//                selectedTeam: exampleTeam,
//                destinationBuilder: { game in
//                    CoachSpecificFootageView(game: game, team: exampleTeam)
////                    AnyView(CoachSpecificFootageView(game: game, team: exampleTeam))
//                },
//                upcomingGamedestinationBuilder: { game in
//                    GameDetailsView(selectedGame: game, team: exampleTeam, userType: "Coach")
//
////                    AnyView(GameDetailsView(selectedGame: game, team: exampleTeam, userType: "Coach"))
//                },
//                showUpcomingGames: true,
//                showRecentGames: true
//            )
//        }
//    }.listStyle(PlainListStyle())
//}
