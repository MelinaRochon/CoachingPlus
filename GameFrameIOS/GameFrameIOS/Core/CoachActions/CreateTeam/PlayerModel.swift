//
//  PlayerModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

struct User_Status {
    let firstName: String
    let lastName: String
    let status: String
    let playerDocId: String
    let userDocId: String
}


@MainActor
final class PlayerModel: ObservableObject {
    @Published var players: [User_Status] = []
    
    func getAllPlayers(invites: [String], players: [String]) async throws {
        // Get the list of players, if they exist. Otherwise, let the user know that there's none
        // For each player in the list, get their names
        var tmpArrayPlayer: [User_Status] = []
        
        for inviteDocId in invites {
            guard let invite = try await InviteManager.shared.getInvite(id: inviteDocId) else {
                print("Could not find the invite's info.. Aborting")
                return
            }
            
            if invite.status == "Pending" {
                print("We are here. with \(inviteDocId)")
                // get the user info
                guard let user = try await UserManager.shared.getUserWithDocId(id: invite.userDocId) else {
                    print("Could not find the user's info.. Aborting")
                    return
                }

                // user not done signing up, add to the player's array
                let newPlayerObject = User_Status(firstName: user.firstName, lastName: user.lastName, status: "Pending Invite", playerDocId: invite.playerDocId, userDocId: user.id)
                tmpArrayPlayer.append(newPlayerObject) // add player to the list of players on the team
            }
        }
        
        for playerId in players {
            guard let user = try await UserManager.shared.getUser(userId: playerId) else {
                print("Could not find the user's info.. Aborting")
                return
            }
            
            guard let player = try await PlayerManager.shared.getPlayer(playerId: playerId) else {
                print("Could not find the player's info.. Aborting")
                return
            }
            let newPlayerObject = User_Status(firstName: user.firstName, lastName: user.lastName, status: "Accepted", playerDocId: player.id, userDocId: user.id)
            tmpArrayPlayer.append(newPlayerObject) // add player to the list of players on the team
        }
        
        self.players = tmpArrayPlayer
    }
    
    func addPlayer(playerDTO: PlayerDTO) async throws -> String {
        return try await PlayerManager.shared.createNewPlayer(playerDTO: playerDTO)
    }
    
    func addPlayerToTeam(teamId: String, inviteDocId: String) async throws -> Bool {
        do {
            // Add the new invite to the team
            try await TeamManager.shared.addInviteToTeam(id: teamId, inviteDocId: inviteDocId)
            return true
        } catch {
            print("Failed to add player to the team.. \(error.localizedDescription)")
            return false
        }
    }
}
