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
    private var teams: [DBTeam] = []

    
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
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        
        player.guardianName = name
    }
    
    func removeGuardianInfo(id: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        player.guardianName = nil
        player.guardianPhone = nil
        player.guardianEmail = nil
    }
    
    func addTeamToPlayer(id: String, teamId: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        
        player.teamsEnrolled?.append(teamId)
    }
    
    func removeTeamFromPlayer(id: String, teamId: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        guard let index = player.teamsEnrolled?.firstIndex(where: { $0 == teamId }) else {
            print("Could not find team id in teams enrolled for player with id \(id)")
            return
        }
        
        player.teamsEnrolled?.remove(at: index)
    }
    
    func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        guard let team = teams.first(where: { $0.id == teamDocId }) else {
            print("Could not find team with doc id \(teamDocId)")
            return
        }
                
        guard let index = player.teamsEnrolled?.firstIndex(where: { $0 == team.teamId }) else {
            print("Could not find team id in teams enrolled for player with id \(id)")
            return
        }
        
        player.teamsEnrolled?.remove(at: index)

    }
    
    func removeGuardianInfoName(id: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        
        player.guardianName = nil
    }
    
    func removeGuardianInfoEmail(id: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        
        player.guardianEmail = nil
    }
    
    func removeGuardianInfoPhone(id: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }

        player.guardianPhone = nil
    }
    
    func updatePlayerInfo(player: GameFrameIOS.DBPlayer) async throws {
        guard var tmpPlayer = try await findPlayerWithId(id: player.id) else {
            print("Could not find a player with id \(player.id)")
            return
        }
        tmpPlayer = player
        
    }
    
    func updatePlayerSettings(id: String, jersey: Int?, nickname: String?, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        
        player.jerseyNum = jersey ?? player.jerseyNum
        player.nickName = nickname ?? player.nickName
        player.guardianName = guardianName ?? player.guardianName
        player.guardianEmail = guardianEmail ?? player.guardianEmail
        player.guardianPhone = guardianPhone ?? player.guardianPhone
        player.gender = gender ?? player.gender
    }
    
    func updatePlayerJerseyAndNickname(playerDocId: String, jersey: Int, nickname: String) async throws {
        guard var player = try await findPlayerWithId(id: playerDocId) else {
            print("Could not find a player with id \(playerDocId)")
            return
        }
        
        player.jerseyNum = jersey
        player.nickName = nickname
    }
    
    func updatePlayerId(id: String, playerId: String) async throws {
        guard var player = try await findPlayerWithId(id: id) else {
            print("Could not find a player with id \(id)")
            return
        }
        player.playerId = playerId
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
            guard var team = teams.first(where: { $0.teamId == teamId }) else {
                print("Did not find a team with teamId \(teamId)")
                return []
            }
            // Add a Team object with the teamId and team name
            let teamObject = GetTeam(teamId: team.teamId, name: team.name, nickname: team.teamNickname)
            teamsEnrolled.append(teamObject)
        }
        
        return teamsEnrolled
    }
    
    func getAllTeamsEnrolled(playerId: String) async throws -> [GameFrameIOS.DBTeam]? {
        guard var player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return nil
        }
        
        var teamsEnrolled: [DBTeam] = []
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return nil
        }
        
        for teamId in player.teamsEnrolled! {
            guard var team = teams.first(where: { $0.teamId == teamId }) else {
                print("Did not find a team with teamId \(teamId)")
                return nil
            }
            teamsEnrolled.append(team)
        }
        
        return teamsEnrolled
    }
    
    func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
        guard var player = try await getPlayer(playerId: playerId) else {
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
