//
//  LocalUserRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation

/// A local in-memory implementation of `UserRepository`.
/// Useful for unit tests or preview data without hitting Firestore.
public final class LocalUserRepository: UserRepository {
    
    /// Local in-memory storage for users, keyed by document ID
    private var users: [DBUser] = []
    
    public init(users: [DBUser]? = nil) {
        // If no coach provided, fallback to default JSON
        self.users = users ?? TestDataLoader.load("TestUsers", as: [DBUser].self)
    }

    
    /// Creates a new user in the repository.
    /// - Parameter userDTO: The Data Transfer Object containing the new user's details.
    /// - Returns: The generated document ID (or unique identifier) for the new user.
    public func createNewUser(userDTO: UserDTO) async throws -> String {
        let id = UUID().uuidString
        let user = DBUser(id: id, userDTO: userDTO)
        users.append(user)
        return id
    }
    
    
    /// Retrieves a user by their user ID.
    /// - Parameter userId: The unique ID of the user.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    public func getUser(userId: String) async throws -> DBUser? {
        guard let user = users.first(where: { $0.userId == userId }) else {
            throw UserError.userNotFound
        }
        return user
    }
    
    public func getAllUsers(userIds: [String]) async throws -> [DBUser]? {
        var tmpUsers: [DBUser] = []
        for userId in userIds {
            let tmp = try await getUser(userId: userId)
            if tmp != nil {
                tmpUsers.append(tmp!)
            }
        }
        return tmpUsers
    }
    
    
    /// Retrieves a user by their Firestore document ID.
    /// - Parameter id: The Firestore document ID.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    public func getUserWithDocId(id: String) async throws -> DBUser? {
        guard let user = users.first(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        return user

    }
    
    
    /// Retrieves a user by their email address.
    /// - Parameter email: The user's email.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    public func getUserWithEmail(email: String) async throws -> DBUser? {
        guard email.contains("@") else {
            throw UserError.userInvalidEmail
        }
        guard let user = users.first(where: { $0.email == email }) else {
            return nil
        }
        return user

    }
    
    
    /// Updates a coach's profile information.
    /// - Parameter user: The updated `DBUser` object representing the coach.
    public func updateCoachProfile(user: DBUser) async throws {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else {
            throw UserError.userNotFound
        }
        users[index] = user
    }
    
    
    /// Updates a coach's settings with optional profile information.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - phone: The coach's phone number (optional).
    ///   - dateOfBirth: The coach's date of birth (optional).
    ///   - firstName: The coach's first name (optional).
    ///   - lastName: The coach's last name (optional).
    ///   - membershipDetails: Membership details (optional).
    public func updateCoachSettings(id: String, phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) async throws {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        if let phone = phone {
            users[index].phone = phone
        }
        if let dateOfBirth = dateOfBirth {
            users[index].dateOfBirth = dateOfBirth
        }
        if let firstName = firstName {
            users[index].firstName = firstName
        }
        if let lastName = lastName {
            users[index].lastName = lastName
        }
        // TODO: Add the membership details to database and here!
    }
    
    
    /// Finds a user by their unique ID.
    /// - Parameter id: The unique ID of the user.
    /// - Returns: The `DBUser` object if found, otherwise `nil`.
    public func findUserWithId(id: String) async throws -> DBUser? {
        return users.first(where: { $0.id == id })
    }
    
    
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
    public func updateUserDTO(id: String, email: String, userTpe: UserType, firstName: String, lastName: String, dob: Date, phone: String?, country: String?, userId: String) async throws {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        users[index].email = email
        users[index].userType = userTpe
        users[index].firstName = firstName
        users[index].lastName = lastName
        users[index].dateOfBirth = dob
        users[index].phone = phone
        users[index].country = country
        users[index].userId = userId
    }
    
    
    /// Updates a user's date of birth.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - dob: The updated date of birth.
    public func updateUserDOB(id: String, dob: Date) async throws {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        users[index].dateOfBirth = dob
    }
    
    
    /// Updates a user's settings with optional profile information.
    /// - Parameters:
    ///   - id: The document ID of the user.
    ///   - dateOfBirth: The user's date of birth (optional).
    ///   - firstName: The user's first name (optional).
    ///   - lastName: The user's last name (optional).
    ///   - phone: The user's phone number (optional).
    public func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        guard let index = users.firstIndex(where: { $0.id == id }) else {
            throw UserError.userNotFound
        }
        if let dateOfBirth = dateOfBirth { users[index].dateOfBirth = dateOfBirth }
        if let firstName = firstName { users[index].firstName = firstName }
        if let lastName = lastName { users[index].lastName = lastName }
        if let phone = phone { users[index].phone = phone }
    }
}
