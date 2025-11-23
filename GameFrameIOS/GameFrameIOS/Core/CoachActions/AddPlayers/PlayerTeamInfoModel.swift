//
//  PlayerTeamInfoModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation
import SwiftUI
import GameFrameIOSShared

@MainActor
final class PlayerTeamInfoModel: ObservableObject {
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    

    /// Creates a PlayerTeamInfo subdocument for the specified player.
    ///
    /// - Parameter dto: The data transfer object containing all fields needed
    ///                  to create the PlayerTeamInfo document.
    /// - Returns: The document ID of the newly created PlayerTeamInfo entry.
    /// - Throws: An error if dependencies are missing or if the repository fails
    ///           to create the document.
    func createPlayerTeamInfo(playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {        
        guard let repo = dependencies else {
            throw NSError(domain: "PlayerTeamInfoModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dependencies not found"])
        }

        // Create the PlayerTeamInfo subdocument through the repository manager.
        let docId = try await repo.playerTeamInfoManager
            .createNewPlayerTeamInfo(playerDocId: dto.playerDocId, playerTeamInfoDTO: dto)

        return docId
    }
    
    /// Retrieves the Firestore document ID associated with a given player ID.
    ///
    /// - Parameter playerId: The user’s player ID used to locate the corresponding
    ///                       Player document in Firestore.
    /// - Returns: The Firestore document ID of the found Player.
    /// - Throws: An error if the player cannot be found or dependencies are missing.
    func findPlayerDocId(playerId: String) async throws -> String {
        guard let player = try await dependencies?.playerManager.getPlayer(playerId: playerId) else {
            throw NSError(domain: "PlayerTeamInfoModel", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Player doc not found for current user"])
        }
        
        return player.id
    }
}
