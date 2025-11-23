//
//  TestHelpers.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-21.
//

@testable import GameFrameIOS
import GameFrameIOSShared

/// Creates a new coach in the local repository for testing purposes.
/// This helper function is used to simplify setup within multiple test cases.
///
/// The function:
/// 1. Calls `sut.addCoach(coachId:)` to add a new coach to the test repository.
/// 2. Immediately retrieves that coach using `sut.getCoach(coachId:)`.
/// 3. Returns the created `DBCoach` instance, ready to use in further test steps.
///
/// - Parameter coachId: An optional identifier for the coach (defaults to `"coach_123"`).
/// - Returns: The created `DBCoach` instance stored in the local repository.
/// - Throws: An error if the coach cannot be created or retrieved.
/// - Note: If the coach creation fails, this function will trigger an `XCTFail`
///         to immediately flag the setup issue in the test results.
func createCoach(for manager: CoachManager, coachId: String = "coach_123") async throws -> DBCoach? {
    try await manager.addCoach(coachId: coachId)
    return try await manager.getCoach(coachId: coachId)
}


/// Helper function used in tests to create a new user and immediately retrieve it from the database.
///
/// - Parameters:
///   - manager: The `UserManager` instance responsible for handling user operations.
///   - userDTO: A `UserDTO` object containing the user's data to be created.
///   - userId: The unique identifier for the user (defaults to `"user_123"`).
/// - Returns: The created `DBUser` instance if successfully retrieved, otherwise `nil`.
/// - Throws: Any error encountered during user creation or retrieval.
func createUser(for manager: UserManager, userDTO: UserDTO, userId: String = "user_123") async throws -> DBUser? {
    _ = try await manager.createNewUser(userDTO: userDTO)
    return try await manager.getUser(userId: userId)
}


/// Creates a new user from a `DBUser` model (often loaded from JSON) and saves it through the `UserManager`.
///
/// - Parameters:
///   - manager: The `UserManager` responsible for handling user-related database operations.
///   - user: A `DBUser` object representing the user data to be inserted.
///   - userId: The unique identifier for the user (defaults to `"uuid001"`).
/// - Returns: The newly created `DBUser` fetched from the database if creation was successful, otherwise `nil`.
/// - Throws: Any error thrown by the `UserManager` during creation or retrieval.
func createUserFromJSON(for manager: UserManager, user: DBUser, userId: String = "uuid001") async throws -> DBUser? {
    let userDTO = UserDTO(
        userId: user.userId,
        email: user.email,
        userType: user.userType,
        firstName: user.firstName,
        lastName: user.lastName
    )
    _ = try await manager.createNewUser(userDTO: userDTO)
    return try await manager.getUser(userId: userId)
}


/// Creates a new player from a given `PlayerDTO` and retrieves it from the database.
///
/// - Parameters:
///   - manager: The `PlayerManager` responsible for handling player-related database operations.
///   - playerDTO: A `PlayerDTO` object containing the data for the new player.
///   - playerId: The unique identifier of the player (defaults to `"uid002"`).
/// - Returns: The created `DBPlayer` if successfully stored and retrieved, otherwise `nil`.
/// - Throws: Any error thrown by the `PlayerManager` during creation or retrieval.
func createPlayer(for manager: PlayerManager, playerDTO: PlayerDTO, playerId: String = "uid002") async throws -> DBPlayer? {
    _ = try await manager.createNewPlayer(playerDTO: playerDTO)
    return try await manager.getPlayer(playerId: playerId)
}


/// Creates a new player directly from a `DBPlayer` object (commonly loaded from JSON for testing).
///
/// - Parameters:
///   - manager: The `PlayerManager` responsible for player persistence.
///   - player: A `DBPlayer` object representing the player’s full data.
/// - Returns: The created `DBPlayer` fetched from the database after creation.
/// - Throws: Any error during the creation or retrieval process.
func createPlayerForJSON(for manager: PlayerManager, player: DBPlayer) async throws -> DBPlayer? {
    let playerDTO = PlayerDTO(
        playerId: player.playerId,
        gender: player.gender,
        profilePicture: player.profilePicture,
        teamsEnrolled: player.teamsEnrolled ?? [],
        guardianName: player.guardianName,
        guardianEmail: player.guardianEmail,
        guardianPhone: player.guardianPhone
    )
    _ = try await manager.createNewPlayer(playerDTO: playerDTO)
    return try await manager.getPlayer(playerId: player.playerId!)
}


/// Creates a new team from a `DBTeam` model (e.g., loaded from a JSON test file) and saves it via the `TeamManager`.
///
/// - Parameters:
///   - manager: The `TeamManager` responsible for managing team-related database operations.
///   - team: A `DBTeam` object containing full team details to be inserted.
/// - Returns: The created `DBTeam` retrieved from the database after creation, or `nil` if not found.
/// - Throws: Any error thrown during creation or retrieval.
func createTeamForJSON(for manager: TeamManager, team: DBTeam) async throws -> DBTeam? {
    let teamDTO = TeamDTO(
        teamId: team.teamId,
        name: team.name,
        teamNickname: team.teamNickname,
        sport: team.sport,
        logoUrl: team.logoUrl,
        colour: team.colour,
        gender: team.gender,
        ageGrp: team.ageGrp,
        accessCode: team.accessCode,  // Optional access code for joining the team
        coaches: team.coaches,  // The coach creating the team
        players: team.players,
        invites: team.invites
    )
    try await manager.createNewTeam(coachId: team.coaches.first!, teamDTO: teamDTO)
    return try await manager.getTeam(teamId: team.teamId)
}
