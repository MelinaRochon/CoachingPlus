//
//  HomePageViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-10.
//

import Foundation


@MainActor
final class HomePageViewModel: ObservableObject {
    
    //@Published var games: [DBGame] = []
    
    @Published var futureGames: [HomeGameDTO] = []
    @Published var pastGames: [HomeGameDTO] = []
    
    /** GET - Fetch all the games from the database */
    func loadGames() async throws {
        // Get the user id
        let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
        
        // get the user type
        let userType = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
        
        var teamsId: [String] = []
        if (userType == "Coach") {
            let test = try await CoachManager.shared.getCoach(coachId: authUser.uid)!
            teamsId = try await CoachManager.shared.getCoach(coachId: authUser.uid)!.teamsCoaching ?? []
            
            print("Coach is \(test)")
        } else {
            // player
            teamsId = try await PlayerManager.shared.getPlayer(playerId: authUser.uid)!.teamsEnrolled
        }
        
        // Loop through each team ID
        var gamesWithTeam: [HomeGameDTO] = []
        for teamId in teamsId {
            // Get team docs for each team
            guard let teamDocId = try await TeamManager.shared.getTeam(teamId: teamId)?.id else {
                print("Could not find team id. Aborting")
                return
            }
            // Get games for each team
            let gameSnapshot = try await GameManager.shared.gameCollection(teamDocId: teamDocId).getDocuments()
            
            // Map the documents to Game objects and append them to the games array
            for document in gameSnapshot.documents {
                if let game = try? document.data(as: DBGame.self) {
                    // Append the game to the games array
                    
                    // Fetch the team for each game
                    if let team = try? await TeamManager.shared.getTeam(teamId: teamId) {
                        let gameWithTeam = HomeGameDTO(game: game, team: team)
                        gamesWithTeam.append(gameWithTeam)
                        
                        
                        //self.games.append()
                        print("games values: \(gameWithTeam)")
                    }
                }
            }
        }
        
//        // Now filter games based on their startTime
//        let currentDate = Date()
//        let filteredGames = gamesWithTeam.filter { game in
//            guard let startTime = game.game.startTime else { return false }
//            
//            // Make sure the game is in the future
//            return startTime > currentDate
//        }
//        
//        // Sort the filtered games by their startTime (earliest to latest)
//        let sortedGames = filteredGames.sorted { game1, game2 in
//            guard let startTime1 = game1.game.startTime, let startTime2 = game2.game.startTime else {
//                return false
//            }
//            // Compare startTimes in ascending order (earliest first)
//            return startTime1 < startTime2
//        }
//
        let currentDate = Date()
        var tmpFutureGames: [HomeGameDTO] = []
        var tmpPastGames: [HomeGameDTO] = []
        // Separate games into future and past
        for game in gamesWithTeam {
            if let startTime = game.game.startTime {
                let gameEndTime = startTime.addingTimeInterval(TimeInterval(game.game.duration))
                    if gameEndTime > currentDate {
                        tmpFutureGames.append(game)
                    } else {
                        tmpPastGames.append(game)
                    }
                }
            }
        // Sort the future games by startTime (earliest to latest)
           let sortedFutureGames = tmpFutureGames.sorted { game1, game2 in
               guard let startTime1 = game1.game.startTime, let startTime2 = game2.game.startTime else {
                   return false
               }
               return startTime1 < startTime2
           }
        
        
        // Assign the combined data to the published array
        self.futureGames = sortedFutureGames
        self.pastGames = tmpPastGames
        //self.games = gamesWithTeam
    }
}
