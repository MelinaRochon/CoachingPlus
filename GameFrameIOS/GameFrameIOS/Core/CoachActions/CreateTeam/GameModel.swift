//
//  GameModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

@MainActor
final class GameModel: ObservableObject {
    @Published var games: [DBGame] = []
    
    
    func getAllGames (teamId: String) async throws {
        // Get the list of games, if they exists.
        guard let tmpGames: [DBGame] = try await GameManager.shared.getAllGames(teamId: teamId) else {
            print("Could not get games. Abort,,,")
            return
        }
        
        self.games = tmpGames
    }
    
    func addNewGame(gameDTO: GameDTO) async throws -> Bool {
        do {
            // Add game to the database
            try await GameManager.shared.addNewGame(gameDTO: gameDTO)
            return true
        } catch {
            print("Failed to add a new game: \(error.localizedDescription)")
            return false
        }
    }
    
    func getTeamsAssociatedToUser() async throws -> [String] {
        // Get the user id
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // get the user type
        let userType = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
        
        var teamsId: [String] = []
        if (userType == "Coach") {
            teamsId = try await CoachManager.shared.getCoach(coachId: authUser.uid)!.teamsCoaching ?? []
        } else {
            // player
            teamsId = try await PlayerManager.shared.getPlayer(playerId: authUser.uid)!.teamsEnrolled
            // TODO: Make the recent footage for the player only the ones that are assigned them or the whole team
        }
        
        return teamsId
    }
    
    func loadAllAssociatedGames() async throws -> [HomeGameDTO] {
        
        let teamsId = try await getTeamsAssociatedToUser()
        
        // Loop through each team ID
        var games: [HomeGameDTO] = []
        for teamId in teamsId {
            // Get team docs for each team
            guard let team = try await TeamManager.shared.getTeam(teamId: teamId) else {
                print("Could not find team. Aborting")
                return [] // empty
            }
            // Get games for each team
            let gameSnapshot = try await GameManager.shared.gameCollection(teamDocId: team.id).getDocuments()
            
            // Map the documents to Game objects and append them to the games array
            for document in gameSnapshot.documents {
                if let game = try? document.data(as: DBGame.self) {
                    // Append the game to the games array
                    
                    // Fetch the team for each game
                    let gameWithTeam = HomeGameDTO(game: game, team: team)
                    games.append(gameWithTeam)
                    print("games values: \(gameWithTeam.game.title)")
                    
                }
            }
        }
        
        return games
    }
    
}
