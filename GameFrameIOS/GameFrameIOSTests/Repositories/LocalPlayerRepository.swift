//
//  LocalPlayerRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
@testable import GameFrameIOS

final class LocalPlayerRepository: PlayerRepository {
    private var players: [DBPlayer] = []
    
    func createNewPlayer(playerDTO: GameFrameIOS.PlayerDTO) async throws -> String {
        let id = UUID().uuidString
        let player = DBPlayer(id: id, playerDTO: playerDTO)
        players.append(player)
        return id
    }
    
    func getPlayer(playerId: String) async throws -> GameFrameIOS.DBPlayer? {
        return players.first(where: { $0.playerId == playerId })
    }
    
    func findPlayerWithId(id: String) async throws -> GameFrameIOS.DBPlayer? {
        return players.first(where: { $0.id == id })
    }
    
    func updateGuardianName(id: String, name: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].guardianName = name
        }
    }
    
    func removeGuardianInfo(id: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].guardianName = nil
            players[index].guardianEmail = nil
            players[index].guardianPhone = nil
        }
    }
    
    func addTeamToPlayer(id: String, teamId: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].teamsEnrolled?.append(teamId)
        }
    }
    
    func removeTeamFromPlayer(id: String, teamId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "LocalPlayerRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found"])
        }

        if let playerIndex = players[index].teamsEnrolled?.firstIndex(of: teamId) {
            players[index].teamsEnrolled?.remove(at: playerIndex)
        }
    }
    
    func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "LocalPlayerRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found"])
        }

        let team = try await TeamManager().getTeamWithDocId(docId: teamDocId)
        if let playerIndex = players[index].teamsEnrolled?.firstIndex(of: team.teamId) {
            players[index].teamsEnrolled?.remove(at: playerIndex)
        }
    }
    
    func removeGuardianInfoName(id: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].guardianName = nil
        }
    }
    
    func removeGuardianInfoEmail(id: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].guardianEmail = nil
        }
    }
    
    func removeGuardianInfoPhone(id: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id }) {
            players[index].guardianPhone = nil
        }
    }
    
    func updatePlayerInfo(player: GameFrameIOS.DBPlayer) async throws {
        if let index = players.firstIndex(where: { $0.id == player.id}) {
            players[index] = player
        }
    }
    
    func updatePlayerSettings(id: String, jersey: Int?, nickname: String?, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) async throws {
        if let index = players.firstIndex(where: { $0.id == id}) {
            players[index].jerseyNum = jersey ?? players[index].jerseyNum
            players[index].nickName = nickname ?? players[index].nickName
            players[index].guardianName = guardianName ?? players[index].guardianName
            players[index].guardianEmail = guardianEmail ?? players[index].guardianEmail
            players[index].guardianPhone = guardianPhone ?? players[index].guardianPhone
            players[index].gender = gender ?? players[index].gender
        }
    }
    
    func updatePlayerJerseyAndNickname(playerDocId: String, jersey: Int, nickname: String) async throws {
        if let index = players.firstIndex(where: { $0.id == playerDocId}) {        players[index].jerseyNum = jersey
            players[index].nickName = nickname
        }
    }
    
    func updatePlayerId(id: String, playerId: String) async throws {
        if let index = players.firstIndex(where: { $0.id == id}) {        players[index].playerId = playerId
        }
    }
    
    func getTeamsEnrolled(playerId: String) async throws -> [GameFrameIOS.GetTeam] {
        guard var player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return []
        }

        var teamsEnrolled: [GetTeam] = []
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return []
        }
        
        for teamId in player.teamsEnrolled! {
            guard let team = try await TeamManager().getTeam(teamId: teamId) else {
                print("Could not find a team with teamId \(teamId)")
                return []
            }
            // Add a Team object with the teamId and team name
            let teamObject = GetTeam(teamId: team.teamId, name: team.name, nickname: team.teamNickname)
            teamsEnrolled.append(teamObject)
        }
        
        return teamsEnrolled
    }
    
    func getAllTeamsEnrolled(playerId: String) async throws -> [GameFrameIOS.DBTeam]? {
        guard let player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return nil
        }
        
        var teamsEnrolled: [DBTeam] = []
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return nil
        }
        let teamManager = TeamManager()
        for teamId in player.teamsEnrolled! {
            guard let team = try await teamManager.getTeam(teamId: teamId) else {
                print("Could not find a team with teamId \(teamId)")
                return nil
            }
            teamsEnrolled.append(team)
        }
        
        return teamsEnrolled
    }
    
    func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
        guard let player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return false
        }
        
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return false
        }
        
        return player.teamsEnrolled!.contains(teamId)
    }
}
