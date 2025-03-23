//
//  SelectedScheduledGameModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-18.
//

import Foundation
@MainActor
final class SelectedGameModel: ObservableObject {
    @Published var selectedGame: HomeGameDTO? = nil
    @Published var userType: String? = nil

    func getSelectedGameInfo(gameId: String, teamDocId: String) async throws {
        
        // Get the team data
        let team = try await TeamManager.shared.getTeamWithDocId(docId: teamDocId);
        
        // Get the game's data
        guard let game = try await GameManager.shared.getGame(gameId: gameId, teamId: team.teamId) else {
            print("Game not found or nil")
            return
        }
        
        let gameWithTeam = HomeGameDTO(game: game, team: team)
        self.selectedGame = gameWithTeam
    }
    
    /** This function get the user type of the authenticated user (either Coach or Player) */
    func getUserType() async throws {
        let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
        
        // get the user type
        let type = try await UserManager.shared.getUser(userId: authUser.uid)!.userType
        self.userType = type
    }
}
