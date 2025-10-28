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
    

    func createPlayerTeamInfo(playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        print("In PlayerTeamInfoModel!!")
        
        guard let repo = dependencies else {
            throw NSError(domain: "PlayerTeamInfoModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dependencies not found"])
        }

        // 1) Resolve to player **document id**
        guard let player = try await repo.playerManager.getPlayer(playerId: dto.playerId) else {
                    throw NSError(domain: "PlayerTeamInfoModel", code: 404,
                                  userInfo: [NSLocalizedDescriptionKey: "Player doc not found for current user"])
                }

        // 2) Create subdoc via manager
        let docId = try await repo.playerTeamInfoManager
            .createNewPlayerTeamInfo(playerDocId: player.id, playerTeamInfoDTO: dto)

        return docId
    }
}
