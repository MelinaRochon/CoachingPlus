//
//  PlayerTeamInfoModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-09-14.
//

import Foundation
import SwiftUI
//import FirebaseFirestoreSwift

@MainActor
final class PlayerTeamInfoModel: ObservableObject {
    func createPlayerTeamInfo(playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        let playerManager = PlayerManager()
        print("In PlayerTeamInfoModel!!")

        // 1) Resolve to player **document id**
        guard let player = try await playerManager.getPlayer(playerId: dto.playerId) else {
                    throw NSError(domain: "PlayerTeamInfoModel", code: 404,
                                  userInfo: [NSLocalizedDescriptionKey: "Player doc not found for current user"])
                }

        // 2) Create subdoc via manager
        let docId = try await PlayerTeamInfoManager()
            .createNewPlayerTeamInfo(playerDocId: player.id, playerTeamInfoDTO: dto)

        return docId
    }
}
