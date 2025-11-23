//
//  LocalPlayerRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

public final class LocalPlayerRepository: PlayerRepository {
    private var players: [DBPlayer] = []
    
    public init(players: [DBPlayer]? = nil) {
        // If no player provided, fallback to default JSON
        self.players =
            players ?? TestDataLoader.load("TestPlayers", as: [DBPlayer].self)
    }

    public func createNewPlayer(playerDTO: PlayerDTO) async throws -> String {
        let id = UUID().uuidString
        let player = DBPlayer(id: id, playerDTO: playerDTO)
        players.append(player)
        return id
    }
    
    public func getPlayer(playerId: String) async throws -> DBPlayer? {
        guard let player = players.first(where: { $0.playerId == playerId }) else {
            throw PlayerError.playerNotFound
        }
        return player
    }
    
    public func findPlayerWithId(id: String) async throws -> DBPlayer? {
        guard let player = players.first(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        return player

    }
    
    public func updateGuardianName(id: String, name: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        players[index].guardianName = name
    }
    
    public func removeGuardianInfo(id: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        
        players[index].guardianName = nil
        players[index].guardianEmail = nil
        players[index].guardianPhone = nil
    }
    
    public func addTeamToPlayer(id: String, teamId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        players[index].teamsEnrolled?.append(teamId)
    }
    
    public func removeTeamFromPlayer(id: String, teamId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }

        if let playerIndex = players[index].teamsEnrolled?.firstIndex(of: teamId) {
            players[index].teamsEnrolled?.remove(at: playerIndex)
        }
    }
    
    public func removeTeamFromPlayerWithTeamDocId(id: String, teamDocId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }

        let team = try await LocalTeamRepository().getTeamWithDocId(docId: teamDocId)
        if let playerIndex = players[index].teamsEnrolled?.firstIndex(of: team.teamId) {
            players[index].teamsEnrolled?.remove(at: playerIndex)
        }
    }
    
    public func removeGuardianInfoName(id: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        players[index].guardianName = nil
    }
    
    public func removeGuardianInfoEmail(id: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        players[index].guardianEmail = nil
    }
    
    public func removeGuardianInfoPhone(id: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            throw PlayerError.playerNotFound
        }
        players[index].guardianPhone = nil
    }
    
    public func updatePlayerInfo(player: DBPlayer) async throws {
        guard let index = players.firstIndex(where: { $0.id == player.id}) else {
            throw PlayerError.playerNotFound
        }
        players[index] = player
    }
    
    public func updatePlayerSettings(id: String, guardianName: String?, guardianEmail: String?, guardianPhone: String?, gender: String?) async throws {
        guard let index = players.firstIndex(where: { $0.id == id}) else {
            throw PlayerError.playerNotFound
        }
        players[index].guardianName = guardianName ?? players[index].guardianName
        players[index].guardianEmail = guardianEmail ?? players[index].guardianEmail
        players[index].guardianPhone = guardianPhone ?? players[index].guardianPhone
        players[index].gender = gender ?? players[index].gender
    }
    
    public func updatePlayerId(id: String, playerId: String) async throws {
        guard let index = players.firstIndex(where: { $0.id == id}) else {
            throw PlayerError.playerNotFound
        }
        players[index].playerId = playerId
    }
    
    public func getTeamsEnrolled(playerId: String) async throws -> [GetTeam] {
        guard let player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return []
        }

        var teamsEnrolled: [GetTeam] = []
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return []
        }
        
        for teamId in player.teamsEnrolled! {
            guard let team = try await LocalTeamRepository().getTeam(teamId: teamId) else {
                print("Could not find a team with teamId \(teamId)")
                return []
            }
            // Add a Team object with the teamId and team name
            let teamObject = GetTeam(teamId: team.teamId, name: team.name, nickname: team.teamNickname)
            teamsEnrolled.append(teamObject)
        }
        
        return teamsEnrolled
    }
    
    public func getAllTeamsEnrolled(playerId: String) async throws -> [DBTeam]? {
        guard let player = try await getPlayer(playerId: playerId) else {
            print("Could not find a player with player id \(playerId)")
            return nil
        }
        
        var teamsEnrolled: [DBTeam] = []
        guard !player.teamsEnrolled!.isEmpty else {
            print("Teams enrolled to player id \(playerId) is empty")
            return nil
        }
        let teamManager = LocalTeamRepository()
        for teamId in player.teamsEnrolled! {
            guard let team = try await teamManager.getTeam(teamId: teamId) else {
                print("Could not find a team with teamId \(teamId)")
                return nil
            }
            teamsEnrolled.append(team)
        }
        
        return teamsEnrolled
    }
    
    public func isPlayerEnrolledToTeam(playerId: String, teamId: String) async throws -> Bool {
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
