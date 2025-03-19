//
//  TeamViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-19.
//

struct User_Status {
//    let userId: String
    let firstName: String
    let lastName: String
    let status: String
    let playerDocId: String
    let userDocId: String
}

import Foundation
@MainActor
final class TeamViewModel: ObservableObject {
    
    @Published var team: DBTeam?
    @Published var players: [User_Status] = []
    @Published var games: [DBGame] = []
    
    func loadTeam(name: String, teamId: String) async throws {
        
        print("name: \(name) - teamID: \(teamId)")
        // Find the team from the teamId
        guard let tmpTeam = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Error when loading the team. Aborting")
            return
        }
        
        self.team = tmpTeam
        
        // Get the list of games, if they exists.
        guard let tmpGames: [DBGame] = try await GameManager.shared.getAllGames(teamId: teamId) else {
            print("Could not get games. Abort,,,")
            return
        }
        print("------------")
        print(tmpGames)
        print("------------")
        
        self.games = tmpGames

        // Get the list of players, if they exist. Otherwise, let the user know that there's none
        guard let tmpPlayers = team?.players else {
            print("There are no players in the team at the moment. Please add one.")
            // TO DO - Will need to add more here! Maybe an icon can show on the page to let the user know there's no player in the team
            return
        }
        
        guard let tmpInvites = team?.invites else {
            print("There are no players in the team at the moment. Please add one.")
            // TO DO - Will need to add more here! Maybe an icon can show on the page to let the user know there's no player in the team
            return
        }
        
        
        // For each player in the list, get their names
        var tmpArrayPlayer: [User_Status] = []
        
        for inviteDocId in tmpInvites {
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
        
        for playerId in tmpPlayers {
            // Check invites array
            // if user status is set to "Pending", then get the user doc using userDocId!
            // else if user is not pending, don't do anything
            
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

}
