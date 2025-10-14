//
//  LocalPlayerTeamInfoRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
@testable import GameFrameIOS

final class LocalPlayerTeamInfoRepository: PlayerTeamInfoRepository {
    private var playerTeamInfos: [DBPlayerTeamInfo] = []
    
    func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: GameFrameIOS.PlayerTeamInfoDTO) async throws -> String {
        let id = UUID().uuidString
        let playerTeamInfoObj = DBPlayerTeamInfo(id: id, playerTeamInfoDTO: dto)
        playerTeamInfos.append(playerTeamInfoObj)
        return id
    }
}
