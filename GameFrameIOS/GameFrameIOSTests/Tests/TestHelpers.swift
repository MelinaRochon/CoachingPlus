//
//  TestHelpers.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-21.
//

@testable import GameFrameIOS

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

func createUser(for manager: UserManager, userDTO: UserDTO, userId: String = "user_123") async throws -> DBUser? {
    try await manager.createNewUser(userDTO: userDTO)
    return try await manager.getUser(userId: userId)
}
