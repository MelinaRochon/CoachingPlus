//
//  GameModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation

/// **GameModel** is responsible for managing game-related data and interactions.
///
/// ## Responsibilities:
/// - Fetching all games associated with a specific team.
/// - Adding a new game to the database.
/// - Retrieving teams associated with the authenticated user.
/// - Loading all games linked to the user's teams.
///
/// This class interacts with various managers (`GameManager`, `AuthenticationManager`, etc.)
/// to fetch and update game data in Firebase.
@MainActor
final class GameModel: ObservableObject {
    /// A list of games retrieved for a specific team.
    @Published var games: [DBGame] = []

    // MARK: - Fetch Games for a Team
    
    /// Retrieves all games associated with a given team and updates the `games` list.
    ///
    /// - Parameter teamId: The ID of the team for which to fetch games.
    /// - Throws: An error if fetching fails.
    func getAllGames (teamId: String) async throws {
        // Get the list of games, if they exists.
        guard let tmpGames: [DBGame] = try await GameManager.shared.getAllGames(teamId: teamId) else {
            print("Could not get games. Abort,,,")
            return
        }
        
        // Update the published games list with the fetched data.
        self.games = tmpGames
    }
    
    
    // MARK: - Fetch a Game for a Team
    
    /// Retrieves a game associated with a given team.
    ///
    /// - Parameters:
    ///  - teamId: The ID of the team for which to fetch the game.
    ///  - gameId: The ID of the game to fetch
    /// - Throws: An error if fetching fails.
    func getGame (teamId: String, gameId: String) async throws -> DBGame? {
        // Get the list of games, if they exists.
        guard let game = try await GameManager.shared.getGame(gameId: gameId, teamId: teamId) else {
            print("Could not load game. Abort...")
            return nil
        }
        
        // Update the published games list with the fetched data.
        return game
    }
    
    
    // MARK: - Add a New Game
      
    /// Adds a new game to the database.
    ///
    /// - Parameter gameDTO: The game data transfer object containing game details.
    /// - Returns: `true` if the game was added successfully, `false` otherwise.
    /// - Throws: An error if the addition fails.
    func addNewGame(gameDTO: GameDTO) async throws -> Bool {
        do {
            // Add game to the database
            try await GameManager.shared.addNewGame(gameDTO: gameDTO)
            return true
        } catch {
            print("Failed to add a new game: \(error.localizedDescription)")
            return false
        }
    }
    
    
    // MARK: - Get User's Associated Teams
    
    /// Retrieves the team IDs associated with the currently authenticated user.
    ///
    /// - Returns: An array of team IDs the user is coaching or playing for.
    /// - Throws: An error if fetching user or team data fails.
    func getTeamsAssociatedToUser() async throws -> [String]? {
        // Fetch the authenticated user's information.
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Retrieve the user type (Coach or Player).
        guard let user = try await UserManager.shared.getUser(userId: authUser.uid) else {
            throw NSError(domain: "UserNotFound", code: 404)
        }
        
        var teamsId: [String]? = []
        if (user.userType == "Coach") {
            // Get the list of teams the coach is managing.
            teamsId = try await CoachManager.shared.getCoach(coachId: authUser.uid)!.teamsCoaching ?? []
        } else {
            // Get the list of teams the player is enrolled in.
            teamsId = try await PlayerManager.shared.getPlayer(playerId: authUser.uid)!.teamsEnrolled
            // TODO: Make the recent footage for the player only the ones that are assigned them or the whole team
        }
        
        return teamsId
    }
    
    
    
    // MARK: - Load All Games for Associated Teams
    
    /// Loads all games for the teams associated with the authenticated user.
    ///
    /// - Returns: An array of `HomeGameDTO` objects, each containing game and team details.
    /// - Throws: An error if any data retrieval operation fails.
    func loadAllAssociatedGames() async throws -> [HomeGameDTO] {
        // Retrieve the list of team IDs associated with the user.
        guard let teamsId = try await getTeamsAssociatedToUser() else {
            print("No games associated to user")
            return []
        }
        
        print("has teams id: \(teamsId)")
        var games: [HomeGameDTO] = []
        
        // Iterate through each team ID to fetch associated games.
        for teamId in teamsId {
            // Attempt to fetch the team document.
            guard let team = try await TeamManager.shared.getTeam(teamId: teamId) else {
                print("Could not find team. Aborting")
                return [] // Return an empty list if the team is not found.
            }
            
            // Fetch game documents for the team.
            let gameSnapshot = try await GameManager.shared.gameCollection(teamDocId: team.id).getDocuments()
            
            // Convert each document into a `DBGame` object and append it to the games list.
            for document in gameSnapshot.documents {
                if let game = try? document.data(as: DBGame.self) {
                    // Create a `HomeGameDTO` containing both game and team details.
                    let gameWithTeam = HomeGameDTO(game: game, team: team)
                    games.append(gameWithTeam)
                }
            }
        }
        
        return games
    }
    
    
    /// Wrapper function that updates the title of a game by delegating to `GameManager`.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game document to update.
    ///   - teamDocId: The unique identifier of the parent team document containing the game.
    ///   - title: The new title string to assign to the game.
    ///
    /// ## Behavior:
    /// - Forwards the update request to `GameManager.shared.updateGameTitle`.
    /// - Keeps the view model / UI layer decoupled from the underlying data manager logic.
    ///
    /// - Throws: Rethrows any errors thrown by `GameManager.updateGameTitle`.
    func updateGameTitle(gameId: String, teamDocId: String, title: String) async throws {
        try await GameManager.shared.updateGameTitle(gameId: gameId, teamDocId: teamDocId, title: title)
    }
    
    
    /// Updates the scheduled game settings for a given game.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game to update.
    ///   - teamDocId: The document ID of the team the game belongs to.
    ///   - title: The updated title of the game, or `nil` to leave unchanged.
    ///   - startTime: The updated start time of the game, or `nil` to leave unchanged.
    ///   - duration: The updated duration of the game in seconds, or `nil` to leave unchanged.
    ///   - timeBeforeFeedback: The updated reminder time before feedback, in seconds, or `nil`.
    ///   - timeAfterFeedback: The updated reminder time after feedback, in seconds, or `nil`.
    ///   - recordingReminder: Whether to enable/disable recording reminders, or `nil`.
    ///   - location: The updated location string, or `nil` to leave unchanged.
    ///   - scheduledTimeReminder: The updated reminder time before the event, in minutes, or `nil`.
    ///
    /// - Throws: An error if the update operation fails.
    /// - Returns: Nothing. This function completes after updating the database.
    func updateScheduledGameSettings(
        gameId: String,
        teamDocId: String,
        title: String?,
        startTime: Date?,
        duration: Int?,
        timeBeforeFeedback: Int?,
        timeAfterFeedback: Int?,
        recordingReminder: Bool?,
        location: String?,
        scheduledTimeReminder: Int?
    ) async throws {
        
        try await GameManager.shared.updateScheduledGameSettings(
            id: gameId,
            teamDocId: teamDocId,
            title: title,
            startTime: startTime,
            duration: duration,
            timeBeforeFeedback: timeBeforeFeedback,
            timeAfterFeedback: timeAfterFeedback,
            recordingReminder: recordingReminder,
            location: location,
            scheduledTimeReminder: scheduledTimeReminder
        )
    }
    
    
    /// Removes a game from the database for the given team.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game to remove.
    ///   - teamDocId: The unique identifier of the team document containing the game.
    /// - Throws: An error if the deletion request fails.
    /// - Note: This only removes the game document itself.
    ///         Any subcollections (e.g., feedback, transcripts) must be deleted separately if needed.
    func removeGame(gameId: String, teamDocId: String) async throws {
        try await GameManager.shared.deleteGame(gameId: gameId, teamDocId: teamDocId)
    }
}
