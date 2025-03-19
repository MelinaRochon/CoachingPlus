//
//  TeamViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-19.
//

import Foundation
@MainActor
final class TeamViewModel: ObservableObject {
    
    @Published var team: DBTeam?
    @Published var players: [DBUser] = []
    @Published var games: [DBGame] = []
    
    func loadTeam(name: String, teamId: String) async throws {
        
        print("name: \(name) - teamID: \(teamId)")
        // Find the team from the teamId
        guard let tmpTeam = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Error when loading the team. Aborting")
            return
        }
        
        self.team = tmpTeam
        
        // Get the list of games, if they exists.
        guard let tmpGames: [DBGame] = try await GameManager.shared.getAllGames(teamId: teamId) else {
            print("Could not get games. Abort,,,")
            return
        }
        print("------------")
        print(tmpGames)
        print("------------")
        
        self.games = tmpGames
//        for game in tmpGames {
//
//        }

        // Get the list of players, if they exist. Otherwise, let the user know that there's none
        guard let tmpPlayers = team?.players else {
            print("There are no players in the team at the moment. Please add one.")
            // TO DO - Will need to add more here! Maybe an icon can show on the page to let the user know there's no player in the team
            return
        }
        
        // For each player in the list, get their names
        var tmpArrayPlayer: [DBUser] = []
        for player in tmpPlayers {
            guard let tmpPlayer = try await UserManager.shared.getUser(userId: player) else {
                print("Could not find the player's info.. Aborting")
                return
            }
            tmpArrayPlayer.append(tmpPlayer) // add player to the list of players on the team
        }
        
        self.players = tmpArrayPlayer
    }

}
