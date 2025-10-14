//
//  PlayerModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

/// A structure representing a player's basic information, including their ID, name, and photo URL.
struct PlayerNameAndPhoto {
    
    /// The unique identifier of the player.
    let playerId: String
    
    /// The full name of the player.
    let name: String
    
    /// An optional URL pointing to the player's profile photo.
    let photoURL: URL?
}


/// **User_Status** represents a player's status within a team.
///
/// This struct is used to store key information about players, including their:
/// - First and last name.
/// - Status (e.g., "Pending Invite" or "Accepted").
/// - Associated player and user document IDs.
struct User_Status {
    let firstName: String
    let lastName: String
    let status: String
    let playerDocId: String
    let userDocId: String
}


/// **PlayerModel** is responsible for handling player-related operations.
///
/// ## Responsibilities:
/// - Fetching and managing the list of players for a team.
/// - Handling player invitations and sign-ups.
/// - Adding new players and associating them with a team.
///
/// This class ensures that all operations execute on the main actor
/// to prevent concurrency issues in SwiftUI applications.
@MainActor
final class PlayerModel: ObservableObject {
    
    /// Stores the list of players along with their invitation status.
    @Published var players: [User_Status] = []
    
    
    /// Fetches all players associated with a team, including both accepted players and pending invites.
    ///
    /// - Parameters:
    ///   - invites: A list of invitation document IDs.
    ///   - players: A list of accepted player user IDs.
    /// - Throws: An error if any database request fails.
    func getAllPlayers(invites: [String], players: [String]) async throws {
        // Temporary array to store player details before updating the `players` state variable.
        var tmpArrayPlayer: [User_Status] = []
        let userManager = UserManager()
        let playerManager = PlayerManager()
        let inviteManager = InviteManager()
        
        // Process pending invites and retrieve user details.
        for inviteDocId in invites {
            // Fetch the invite information.
            guard let invite = try await inviteManager.getInvite(id: inviteDocId) else {
                print("Could not find the invite's info.. Aborting")
                return
            }
            
            // If the invitation is still pending, retrieve the user details.
            if invite.status == "Pending" {
                print("We are here. with \(inviteDocId)")
                // get the user info
                guard let user = try await userManager.getUserWithDocId(id: invite.userDocId) else {
                    print("Could not find the user's info.. Aborting")
                    return
                }

                // Create a new `User_Status` object for the invited player.
                let newPlayerObject = User_Status(firstName: user.firstName, lastName: user.lastName, status: "Pending Invite", playerDocId: invite.playerDocId, userDocId: user.id)
                tmpArrayPlayer.append(newPlayerObject) // add player to the list of players on the team
            }
        }
        
        // Process accepted players and retrieve their details.
        for playerId in players {
            guard let user = try await userManager.getUser(userId: playerId) else {
                print("Could not find the user's info.. Aborting")
                return
            }
            
            guard let player = try await playerManager.getPlayer(playerId: playerId) else {
                print("Could not find the player's info.. Aborting")
                return
            }
            // Create a new `User_Status` object for the accepted player.
            let newPlayerObject = User_Status(firstName: user.firstName, lastName: user.lastName, status: "Accepted", playerDocId: player.id, userDocId: user.id)
            tmpArrayPlayer.append(newPlayerObject) // add player to the list of players on the team
        }
        
        // filter the players array
        tmpArrayPlayer.sort { $0.firstName < $1.firstName }
        
        // Update the published players list with the newly fetched data.
        self.players = tmpArrayPlayer
    }
    
    
    /// Asynchronously retrieves full names of players based on their user IDs.
    ///
    /// This function loops through a list of player IDs, fetches their user data asynchronously
    /// using `UserManager.shared.getUser`, and constructs an array of full names.
    /// If any user ID fails to return a valid user, the function prints an error and returns `nil`.
    ///
    /// - Parameter players: An array of player IDs (as Strings).
    /// - Returns: An optional array of full player names (`[String]?`). Returns `nil` if a user cannot be found.
    /// - Throws: An error if the `getUser` call fails.
    func getAllPlayersNames(players: [String]) async throws -> [(String, String)]? {
        let userManager = UserManager()
        var tmpPlayersNames: [(String, String)] = [("0", "All")]
        
        // Process each player ID and retrieve their corresponding user data.
        for playerId in players {
            // Attempt to get user data from UserManager.
            guard let user = try await userManager.getUser(userId: playerId) else {
                print("Could not find the user's info.. Aborting")
                return nil // Return nil if any player info is missing.
            }
            
            // Construct full name and append to the result list.
            let name = user.firstName + " " + user.lastName
            
            tmpPlayersNames.append((playerId, name))
        }
        
        // Return the list of player names.
        return tmpPlayersNames
    }
    
    
    /// Returns player IDs, names, and optional photo URLs for a list of player IDs.
    ///
    /// - Parameter players: List of player IDs to fetch.
    /// - Returns: An array of tuples `(id, name, photoUrl)`.
    /// - Throws: If fetching user data fails.
    func getAllPlayersNamesAndUrl(players: [String]) async throws -> [(String, String, URL?)] {
        let userManager = UserManager()
        var results: [(String, String, URL?)] = [] ; //[("0", "All", nil)]
        
        for playerId in players {
            guard let user = try await userManager.getUser(userId: playerId) else {
                print("getAllPlayersNamesAndUrl : Could not find user \(playerId)")
                continue
            }
            
            let name = user.firstName + " " + user.lastName
            let photoUrl = user.photoUrl // or however your User object stores it
            
            results.append((playerId, name, photoUrl) as! (String, String, URL?))
        }
        
        return results
    }
    
    
    /// Creates a new player entry in the database.
    ///
    /// - Parameter playerDTO: The `PlayerDTO` object containing player details.
    /// - Returns: The unique document ID of the newly created player.
    /// - Throws: An error if the operation fails.
    func addPlayer(playerDTO: PlayerDTO) async throws -> String {
        return try await PlayerManager().createNewPlayer(playerDTO: playerDTO)
    }
    
    
    /// Associates a player with a team by adding an invite document ID to the team record.
    ///
    /// - Parameters:
    ///   - teamId: The ID of the team the player is joining.
    ///   - inviteDocId: The invitation document ID linked to the player.
    /// - Returns: `true` if the operation succeeds, `false` otherwise.
    func addPlayerToTeam(teamDocId: String, inviteDocId: String) async throws -> Bool {
        do {
            let teamManager = TeamManager()
            // Add the player's invite to the team document in the database.
            try await teamManager.addInviteToTeam(id: teamDocId, inviteDocId: inviteDocId)
            return true
        } catch {
            print("Failed to add player to the team.. \(error.localizedDescription)")
            return false
        }
    }
}
