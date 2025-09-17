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
        print("In PlayerTeamInfoModel!!")
        // 1) Current auth user
        let auth = try AuthenticationManager.shared.getAuthenticatedUser()

        // 2) Resolve to your player **document id**
        guard let player = try await PlayerManager.shared.getPlayer(playerId: auth.uid) else {
                    throw NSError(domain: "PlayerTeamInfoModel", code: 404,
                                  userInfo: [NSLocalizedDescriptionKey: "Player doc not found for current user"])
                }

        // 3) Create subdoc via manager
        let docId = try await PlayerTeamInfoManager.shared
            .createNewPlayerTeamInfo(playerDocId: player.id, playerTeamInfoDTO: dto)

        return docId
    }
}
