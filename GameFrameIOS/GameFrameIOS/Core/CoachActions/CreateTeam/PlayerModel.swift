//
//  PlayerModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation
import GameFrameIOSShared

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
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    /// Fetches all players associated with a team, including both accepted players and pending invites.
    ///
    /// - Parameters:
    ///   - invites: A list of invitation document IDs.
    ///   - players: A list of accepted player user IDs.
    /// - Throws: An error if any database request fails.
    func getAllPlayers(invites: [String], players: [String]) async throws {
        // Temporary array to store player details before updating the `players` state variable.
        var tmpArrayPlayer: [User_Status] = []
        
        // Process pending invites and retrieve user details.
        for inviteDocId in invites {
            // Fetch the invite information.
            guard let invite = try await dependencies?.inviteManager.getInvite(id: inviteDocId) else {
                print("Could not find the invite's info.. Aborting")
                return
            }
            
            // If the invitation is still pending, retrieve the user details.
            if invite.status == .unverified {
                print("We are here. with \(inviteDocId)")
                // get the user info
                guard let user = try await dependencies?.userManager.getUserWithDocId(id: invite.userDocId) else {
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
            guard let user = try await dependencies?.userManager.getUser(userId: playerId) else {
                print("Could not find the user's info.. Aborting")
                return
            }
            
            guard let player = try await dependencies?.playerManager.getPlayer(playerId: playerId) else {
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
        var tmpPlayersNames: [(String, String)] = [("0", "All")]
        
        // Process each player ID and retrieve their corresponding user data.
        for playerId in players {
            // Attempt to get user data from UserManager.
            guard let user = try await dependencies?.userManager.getUser(userId: playerId) else {
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
        var results: [(String, String, URL?)] = [] ; //[("0", "All", nil)]
        
        for playerId in players {
            guard let user = try await dependencies?.userManager.getUser(userId: playerId) else {
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
        guard let repo = dependencies?.playerManager else {
            throw NSError(domain: "addPlayer", code: 0, userInfo: nil)
        }
        return try await repo.createNewPlayer(playerDTO: playerDTO)
    }
    
    
    /// Associates a player with a team by adding an invite document ID to the team record.
    ///
    /// - Parameters:
    ///   - teamId: The ID of the team the player is joining.
    ///   - inviteDocId: The invitation document ID linked to the player.
    /// - Returns: `true` if the operation succeeds, `false` otherwise.
    func addPlayerToTeam(teamDocId: String, inviteDocId: String) async throws -> Bool {
        do {
            // Add the player's invite to the team document in the database.
            try await dependencies?.teamManager.addInviteToTeam(id: teamDocId, inviteDocId: inviteDocId)
            return true
        } catch {
            print("Failed to add player to the team.. \(error.localizedDescription)")
            return false
        }
    }
    
    
    /// Retrieves a player document based on the provided `userId`,
    /// and ensures that the player is not already associated with the given team.
    ///
    /// - Parameters:
    ///   - userId: The ID that represents the user's account.
    ///   - teamId: The team to check against for duplicate membership.
    ///
    /// - Throws:
    ///   - `PlayerError.playerNotFound` if no corresponding player document exists.
    ///   - `PlayerError.playerAlreadyAddedToTeam` if the player is already enrolled in the team.
    ///
    /// - Returns: The `DBPlayer` model representing the player.
    func findPlayerWithUserId(userId: String, teamId: String) async throws -> DBPlayer {
        guard let player = try await dependencies?.playerManager.getPlayer(playerId: userId) else {
            throw PlayerError.playerNotFound
        }
        
        // Ensure the player isn't already a member of this team
        if let teamsEnrolled = player.teamsEnrolled {
            if teamsEnrolled.contains(teamId) {
                throw PlayerError.playerAlreadyAddedToTeam
            }
        }

        return player
    }
    
    /// Retrieves a player document directly using the player's document ID.
    ///
    /// - Parameter playerDocId: The Firestore document ID of the player.
    /// - Throws:
    ///   - `PlayerError.playerNotFound` if the player document does not exist.
    /// - Returns: A `DBPlayer` object containing the player's information.
    func findPlayerWithPlayerDocId(playerDocId: String) async throws -> DBPlayer {
        guard let player = try await dependencies?.playerManager.findPlayerWithId(id: playerDocId) else {
            throw PlayerError.playerNotFound
        }
        
        return player
    }
}
