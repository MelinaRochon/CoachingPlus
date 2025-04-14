//
//  AllRecentFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/**
 `AllRecentFootageView` displays all previously recorded game footage for coaches.

 ## Features:
 - Lists past games that have recorded footage.
 - Allows users to search for specific footage using a search bar.
 - Clicking on a game navigates to `SelectedRecentGameView` for detailed viewing.
 - If no past games are found, a placeholder message is displayed.

 ## User Interaction:
 - Coaches can scroll through the recorded games.
 - Typing in the search bar filters the list of past games.
 - Selecting a game opens its details, including recorded video previews.
 */
struct AllRecentFootageView: View {
    
    // MARK: - State Properties

    /// Stores the text entered in the search bar to filter recorded footage.
    @State private var searchText: String = ""
    
    /// Holds the list of past games with recorded footage.
    @State var pastGames: [HomeGameDTO] = []
    
    /// Determines whether to show an error message when no recorded games are available.
    @State private var showNoGamesError: Bool = false

    /// Stores the type of user (e.g., "Coach", "Player"), fetched dynamically.
    @State var userType: String

    /// Filters the games
    var filteredGames: [HomeGameDTO] {
        if searchText.isEmpty {
            return pastGames
        } else {
            return pastGames.filter { game in
                game.game.title.lowercased().contains(searchText.lowercased()) ||
                game.team.name.lowercased().contains(searchText.lowercased()) ||
                game.team.teamNickname.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @State private var groupedGames: [(label: String, games: [HomeGameDTO])]? = nil
    
    // MARK: - View

    var body: some View {
        NavigationStack {
            List  {
                Section {
                    if !pastGames.isEmpty {
//                        ForEach(filteredGames, id: \.game.gameId) { pastGame in
//                            NavigationLink(destination: SelectedRecentGameView(selectedGame: pastGame, userType: userType)) {
//                                HStack {
//                                    CustomUIFields.gameVideoPreviewStyle()
//                                    
//                                    VStack {
//                                        Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
//                                        Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
//                                        Text( formatStartTime(pastGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
//                                    }
//                                }
//                            }
//                        }
                    } else {
                        Text("No games found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                if let groupedGames = groupedGames {
                    ForEach (groupedGames, id: \.label) { group in
                        
                        
                        Section(header: Text(group.label)) {
                            ForEach(group.games, id: \.game.gameId) { pastGame in
                                NavigationLink(destination: SelectedRecentGameView(selectedGame: pastGame, userType: userType)) {
                                    HStack {
                                        CustomUIFields.gameVideoPreviewStyle()
                                        
                                        VStack {
                                            Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text( formatStartTime(pastGame.game.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            .background(Color.white) // Set background color to white for the List
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search Recent Games"))
            .navigationTitle(Text("All Recent Games"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .task{
            self.groupedGames = groupGamesByWeek(pastGames)
        }
    }
    
    private func groupGamesByWeek(_ games: [HomeGameDTO]) -> [(label: String, games: [HomeGameDTO])] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let now = Date()
        let grouped = Dictionary(grouping: games) { game -> Date in
            game.game.startTime?.startOfWeek(using: calendar) ?? Date().startOfWeek(using: calendar)
//            game -> String in
//            if let startTime = game.game.startTime {
//            let weeksAgo = game.game.startTime?.weeksAgo(from: now) ?? 0
//                switch weeksAgo {
//                case 0: return "This Week"
//                case 1: return "Last Week"
//                default: return "\(weeksAgo) Weeks Ago"
//                }
            
//            }
        }
        
        return grouped
            .sorted { $0.key < $1.key } // newest first
            .map { (startOfWeek, games) in
                let endOfWeek = startOfWeek.endOfWeek(using: calendar)
                let weeksAgo = calendar.dateComponents([.weekOfYear], from: startOfWeek, to: now.startOfWeek()).weekOfYear ?? 0

                let label: String
                switch weeksAgo {
                case 0:
                    label = "This Week"
                case 1:
                    label = "Last Week"
                default:
                    label = "\(formatter.string(from: startOfWeek)) – \(formatter.string(from: endOfWeek))"
                }
                return (label: label, games: games.sorted { $0.game.startTime ?? Date() > $1.game.startTime ?? Date() })
            }
//            .map { (key, games) in (label: key, games: games.sorted { $0.game.startTime ?? Date() > $1.game.startTime ?? Date() }) }
    }
}

#Preview {
    AllRecentFootageView(pastGames: [], userType: "Player")
}

//extension Date {
//    func startOfWeek(using calendar: Calendar = .current) -> Date {
//        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
//        return calendar.date(from: components)!
//    }
//    
//    func endOfWeek(using calendar: Calendar = .current) -> Date {
//        let start = self.startOfWeek(using: calendar)
//        return calendar.date(byAdding: .day, value: 6, to: start)!
//    }
//    func weeksAgo(from date: Date) -> Int {
//        let calendar = Calendar.current
//        let startOfSelfWeek = self.startOfWeek()
//        let startOfReferenceWeek = date.startOfWeek()
//        return calendar.dateComponents([.weekOfYear], from: startOfSelfWeek, to: startOfReferenceWeek).weekOfYear ?? 0
//    }
//}
