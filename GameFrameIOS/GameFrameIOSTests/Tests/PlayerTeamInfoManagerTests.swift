//
//  PlayerTeamInfoManagerTests.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-22.
//

import XCTest
@testable import GameFrameIOSShared

final class PlayerTeamInfoManagerTests: XCTestCase {
    var manager: PlayerTeamInfoManager!
    var localRepo: LocalPlayerTeamInfoRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localRepo = LocalPlayerTeamInfoRepository()
        manager = PlayerTeamInfoManager(repo: localRepo)
    }

    override func tearDownWithError() throws {
        manager = nil
        localRepo = nil
        try super.tearDownWithError()
    }

    func testAddNewPlayerTeamInfo() async throws {
        let playerTeamInfoId = "uuid01"
        let playerId = "player_123"
        let playerTeamInfoDocId = "playerTeamInfoDocId01"
        // Add a new user
        let playerTeamDTO = PlayerTeamInfoDTO(
            id: playerTeamInfoId,
            playerId: playerId,
            nickname: nil,
            jerseyNum: 12,
            joinedAt: Date()
        )
        let playerTeamInfo = try await manager.createNewPlayerTeamInfo(playerDocId: playerTeamInfoDocId, playerTeamInfoDTO: playerTeamDTO)
        
        XCTAssertNotNil(playerTeamInfo, "User should exist after being added")
    }
}
