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
        
        print("Games: \(games)")
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
}
