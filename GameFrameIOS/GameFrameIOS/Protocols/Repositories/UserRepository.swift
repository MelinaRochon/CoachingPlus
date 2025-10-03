//
//  UserRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation


/// A repository abstraction for managing user data.
/// Defines the contract for fetching, creating, and updating users in persistence (e.g., Firestore, local storage).
protocol UserRepository {
    
    /// Retrieves the type of the current authenticated user (e.g., `coach` or `player`).
    /// - Returns: The `UserType` of the current user.
    func getUserType() async throws -> UserType
    
    
    /// Creates a new user in the repository.
    /// - Parameter userDTO: The Data Transfer Object containing the new user's details.
    /// - Returns: The generated document ID (or unique identifier) for the new user.
    func createNewUser(userDTO: UserDTO) async throws -> String
    
    
    /// Retrieves a user by their user ID.
    /// - Parameter userId: The unique ID of the user.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    func getUser(userId: String) async throws -> DBUser?
    
    
    /// Retrieves a user by their Firestore document ID.
    /// - Parameter id: The Firestore document ID.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    func getUserWithDocId(id: String) async throws -> DBUser?
    
    
    /// Retrieves a user by their email address.
    /// - Parameter email: The user's email.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    func getUserWithEmail(email: String) async throws -> DBUser?
    
    
    /// Updates a coach's profile information.
    /// - Parameter user: The updated `DBUser` object representing the coach.
    func updateCoachProfile(user: DBUser) async throws
    
    
    /// Updates a coach's settings with optional profile information.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - phone: The coach's phone number (optional).
    ///   - dateOfBirth: The coach's date of birth (optional).
    ///   - firstName: The coach's first name (optional).
    ///   - lastName: The coach's last name (optional).
    ///   - membershipDetails: Membership details (optional).
    func updateCoachSettings(id: String, phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) async throws
    
    
    /// Finds a user by their unique ID.
    /// - Parameter id: The unique ID of the user.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    func findUserWithId(id: String) async throws -> DBUser?
    
    
    /// Updates the main user information.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - email: The user's email.
    ///   - userTpe: The user's type (`coach` or `player`).
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    ///   - dob: The user's date of birth.
    ///   - phone: The user's phone number (optional).
    ///   - country: The user's country (optional).
    ///   - userId: The unique ID of the user (e.g., auth UID).
    func updateUserDTO(id: String, email: String, userTpe: UserType, firstName: String, lastName: String, dob: Date, phone: String?, country: String?, userId: String) async throws
    
    
    /// Updates a user's date of birth.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - dob: The updated date of birth.
    func updateUserDOB(id: String, dob: Date) async throws
    
    
    /// Updates a user's settings with optional profile information.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - dateOfBirth: The user's date of birth (optional).
    ///   - firstName: The user's first name (optional).
    ///   - lastName: The user's last name (optional).
    ///   - phone: The user's phone number (optional).
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws
}
