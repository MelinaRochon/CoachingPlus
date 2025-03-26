//
//  KeyMomentViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-20.
//

import Foundation
@MainActor
final class KeyMomentViewModel: ObservableObject {
    
    @Published var team: DBTeam?
    @Published var game: DBGame?
    // TO DO - Will need to add the key moments db
    @Published var recordings: [keyMomentTranscript] = [];
    
    func loadGameDetails(gameId: String, teamDocId: String) async throws {
        // Get the team data
        let team = try await TeamManager.shared.getTeamWithDocId(docId: teamDocId);
        
        self.team = team
        
        // Get the game's data
        guard let tmpGame = try await GameManager.shared.getGame(gameId: gameId, teamId: team.teamId) else {
                print("Game not found or nil")
                return
            }
        
        self.game = tmpGame

    }
    
}
