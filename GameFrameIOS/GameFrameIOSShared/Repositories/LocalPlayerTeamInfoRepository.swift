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
    
    public func getPlayerTeamInfo(playerDocId: String, teamId: String) async throws -> DBPlayerTeamInfo? {
        guard let playerTeamInfo = playerTeamInfos.first(where: { $0.id == teamId}) else {
            return nil
        }
        
        return playerTeamInfo
    }
    
    public func updatePlayerTeamInfoJerseyAndNickname(teamId: String, playerDocId: String, jersey: Int?, nickname: String?) async throws {
        guard let index = playerTeamInfos.firstIndex(where: { $0.id == teamId}) else {
            return
        }
        
        if let jersey = jersey {
            playerTeamInfos[index].jerseyNum = jersey
        }
        if let nickname = nickname {
            playerTeamInfos[index].nickName = nickname
        }
    }
}
