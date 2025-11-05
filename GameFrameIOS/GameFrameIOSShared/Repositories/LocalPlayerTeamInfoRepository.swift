//
//  LocalPlayerTeamInfoRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

public final class LocalPlayerTeamInfoRepository: PlayerTeamInfoRepository {
    private var playerTeamInfos: [DBPlayerTeamInfo] = []
    
    public init(playerTeamInfos: [DBPlayerTeamInfo]? = nil) {
        self.playerTeamInfos = playerTeamInfos ?? TestDataLoader.load("TestPlayerTeamInfo", as: [DBPlayerTeamInfo].self)
    }
    
    public func createNewPlayerTeamInfo(playerDocId: String, playerTeamInfoDTO dto: PlayerTeamInfoDTO) async throws -> String {
        let id = UUID().uuidString
        let playerTeamInfoObj = DBPlayerTeamInfo(id: id, playerTeamInfoDTO: dto)
        playerTeamInfos.append(playerTeamInfoObj)
        return id
    }
}
