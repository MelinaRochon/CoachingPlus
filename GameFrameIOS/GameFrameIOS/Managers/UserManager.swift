//
//  UserManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation

/// Manages user-related operations such as retrieving, creating, and updating users.
final class UserManager {
    private let repo: UserRepository
    
    init(repo: UserRepository = FirestoreUserRepository()) {
        self.repo = repo
    }
    
    
    /**
     GET - Retrieves the authenticated user's type from the database.
     - Throws: An error if the user is not authenticated or if retrieval fails.
     - Returns: The user type (e.g., "coach", "player").
    */
    func getUserType() async throws -> UserType {
        // returns the user type!
        return try await repo.getUserType()
    }
    
    
    /**
     POST - Creates a new user in the database.
     - Parameter userDTO: The data transfer object containing user information to be saved.
     - Throws: An error if the user creation fails.
     - Returns: The document ID of the newly created user.
     */
    func createNewUser(userDTO: UserDTO) async throws -> String {
        return try await repo.createNewUser(userDTO: userDTO)
    }
        
    
    /**
     GET - Retrieves user information from the database by user ID.
     - Parameter userId: The unique user ID.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if the user is not found.
     */
    func getUser(userId: String) async throws -> DBUser? {
        return try await repo.getUser(userId: userId)
    }
    
    
    /**
     GET - Retrieves user information from the database using document ID.
     - Parameter id: The document ID of the user.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if not found.
     */
    func getUserWithDocId(id: String) async throws -> DBUser? {
        return try await repo.getUserWithDocId(id: id)
    }

    
    /**
     GET - Retrieves user information by their email address.
     - Parameter email: The user's email address.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if the user is not found.
     */
    func getUserWithEmail(email: String) async throws -> DBUser? {
        return try await repo.getUserWithEmail(email: email)
    }
    
    
    /**
     PUT - Updates the coach's profile in the user collection.
     - Parameter user: The DBUser object containing the updated user information.
     - Throws: An error if the update fails.
     */
    func updateCoachProfile(user: DBUser) async throws {
        try await repo.updateCoachProfile(user: user)
    }
    
    
    /// Updates a coach's settings in the database with any provided non-nil values.
    /// - Parameters:
    ///   - id: The unique identifier of the coach's user document.
    ///   - phone: Optional updated phone number.
    ///   - dateOfBirth: Optional updated date of birth.
    ///   - firstName: Optional updated first name.
    ///   - lastName: Optional updated last name.
    ///   - membershipDetails: Optional updated membership details (currently unused).
    /// - Throws: Rethrows any errors that occur during the Firestore update operation.
    func updateCoachSettings(id: String, phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) async throws {
        try await repo.updateCoachSettings(
            id: id,
            phone: phone,
            dateOfBirth: dateOfBirth,
            firstName: firstName,
            lastName: lastName,
            membershipDetails: membershipDetails
        )
    }

    
    /**
     GET - Finds a user by document ID.
     - Parameter id: The unique document ID of the user.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user's information, or nil if not found.
     */
    func findUserWithId(id: String) async throws -> DBUser? {
        return try await repo.findUserWithId(id: id)
    }
    
    
    /**
     PUT - Updates user details in the database.
     - Parameters:
        - id: The unique document ID of the user to update.
        - email: The new email address.
        - userTpe: The new user type (e.g., "coach", "player").
        - firstName: The new first name.
        - lastName: The new last name.
        - dob: The new date of birth.
        - phone: The new phone number (optional).
        - country: The new country (optional).
        - userId: The Firebase user ID.
     - Throws: An error if the update fails.
     */
    func updateUserDTO(id: String, email: String, userTpe: UserType, firstName: String, lastName: String, dob: Date, phone: String?, country: String?, userId: String) async throws {
        try await repo.updateUserDTO(
            id: id,
            email: email,
            userTpe: userTpe,
            firstName: firstName,
            lastName: lastName,
            dob: dob,
            phone: phone,
            country: country,
            userId: userId
        )
    }
    
    func updateUserDOB(id: String, dob: Date) async throws {
        try await repo.updateUserDOB(id: id, dob: dob)
    }
    
    
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        try await repo.updateUserSettings(
            id: id,
            dateOfBirth: dateOfBirth,
            firstName: firstName,
            lastName: lastName,
            phone: phone
        )
    }
}
