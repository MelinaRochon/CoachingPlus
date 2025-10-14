//
//  AuthenticationModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-30.
//

import Foundation


/**
 ViewModel responsible for managing authentication-related data and operations.
 */
@MainActor
final class AuthenticationModel: ObservableObject {
    
    // MARK: - Authentication Information
    /// User's email for authentication.
    @Published var email: String = ""
    
    /// User's password for authentication.
    @Published var password: String = ""
    
    // MARK: - Sign Up Information
    /// User's first name.
    @Published var firstName = ""
    
    /// User's last name.
    @Published var lastName = ""
    
    /// User's date of birth.
    @Published var dateOfBirth = Date()
    
    /// User's phone number.
    @Published var phone = ""
    
    /// User's country (default: Canada).
    @Published var country = "Canada"
    
    /// User's time zone.
    @Published var timeZone = ""
    
    /// Team access code entered by the user.
    @Published var teamAccessCode: String = ""
    
    /// ID of the team the user belongs to.
    @Published var teamId: String = ""
    
    /// Name of the team the user belongs to.
    @Published var teamName: String = ""
    
    /// Controls the visibility of an alert when the team access code is invalid.
    @Published var showInvalidCodeAlert: Bool = false
    
    
    // MARK: - Authentication Functions
    
    /// Returns the string representation of the user type.
    /// - Parameter type: The `UserType` enum value.
    /// - Returns: A string representation ("Coach" or "Player").
    func getUserType(for type: UserType) -> String {
        switch type {
        case .coach:
            return "Coach"
        case .player:
            return "Player"
        default:
            return "Unknown"
        }
    }
    
    
    /// Handles user sign-in by validating credentials and using the authentication manager.
    /// This function will sign in a user using their email and password, and handle errors if the sign-in fails.
    /// - Throws: An error if the sign-in attempt fails (e.g., incorrect credentials or network issues).
    func signIn() async throws {
        // Attempt to sign in using Firebase Authentication.
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    

    /// Handles user sign-up by verifying the email and creating a new user in the system.
    /// This function handles both the creation of a new user in Firebase and also the creation of a user record in the database.
    /// It verifies whether the user already exists and performs different actions based on the user type (player or coach).
    /// - Parameter userType: The type of user being created, either "Coach" or "Player".
    /// - Throws: An error if the sign-up fails (e.g., email already in use or issues with team validation).
    func signUp(userType: UserType) async throws {
        let userManager = UserManager()
        let teamManager = TeamManager()
        let verifyUser =  try await verifyEmailAddress()
        if let verifyUser = verifyUser {
            if verifyUser.userId != nil {
                print("User already exists with this email. Abort")
                return
            }
        }
        
        // Create a new user in Firebase Authentication.
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        
        // Create a new DTO
        let user = UserDTO(userId: authDataResult.uid, email: authDataResult.email, userType: userType, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, country: country)
        try await userManager.createNewUser(userDTO: user)
        
        // Handle user creation based on type (Player or Coach).
        if (userType == .player) {
            // Verify if the team access code entered is valid
            guard let team = try await teamManager.getTeamWithAccessCode(accessCode: teamAccessCode) else {
                print("Error. Not a valid team access code. ")
                return
            }
            
            guard let invite = try await InviteManager.shared.getInviteByEmailAndTeamId(email: email, teamId: teamId) else {
                print("Invite for this player does not exists. Creating a new user.")
                
                // new user. Create a user and player, and add the playerId in the team
                let user = UserDTO(userId: authDataResult.uid, email: email, userType: .player, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, country: country)
                let userDocId = try await userManager.createNewUser(userDTO: user)
                print("UserManager created at user doc: \(userDocId)")
                
                // create a new player,
                let player = PlayerDTO(playerId: authDataResult.uid, jerseyNum: 0, nickName: nil, gender: team.gender, profilePicture: nil, teamsEnrolled: [team.teamId], guardianName: nil, guardianEmail: nil, guardianPhone: nil)
                let playerDocId = try await PlayerManager.shared.createNewPlayer(playerDTO: player)
                print("Player doc id was created! \(playerDocId)")
                
                let subdocId = team.teamId // <- we store per-team info using team.teamId as the subdoc id

                let dto = PlayerTeamInfoDTO(id: subdocId, playerId: playerDocId, nickname: nil, jerseyNum: nil, joinedAt: nil) // nil => server time
                _ = try await PlayerTeamInfoManager.shared.createNewPlayerTeamInfo(playerDocId: playerDocId, playerTeamInfoDTO: dto)

                // Add player to team
                try await teamManager.addPlayerToTeam(id: team.id, playerId: authDataResult.uid)
                return  // TODO: Might need to delete the existing user from the database otherwise, will never be able to create an account with that email
            }
            
            // update the user document
            print("update user")
            try await userManager.updateUserDTO(id: invite.userDocId, email: email, userTpe: userType, firstName: firstName, lastName: lastName, dob: dateOfBirth, phone: phone, country: country, userId: authDataResult.uid)
            
            // update the player document
            print("update player")
            try await PlayerManager.shared.updatePlayerId(id: invite.playerDocId, playerId: authDataResult.uid)
            
            // Create playerTeamInfo under players/{playerDocId}/playerTeamInfo/{team.teamId}
            let subdocId = team.teamId
            let dto = PlayerTeamInfoDTO(id: subdocId, playerId: invite.playerDocId, nickname: nil, jerseyNum: nil, joinedAt: nil)
            _ = try await PlayerTeamInfoManager.shared.createNewPlayerTeamInfo(playerDocId: invite.playerDocId, playerTeamInfoDTO: dto)

            // Look for the correct team
            guard let team = try await teamManager.getTeam(teamId: invite.teamId) else {
                print("Team looking for does not exist. Abort")
                return
            }
            // Add user in the players array
            try await teamManager.addPlayerToTeam(id: team.id, playerId: authDataResult.uid)
            
            // update the status of the player
            // Set to accepted
            try await InviteManager.shared.updateInviteStatus(id: invite.id, newStatus: "Accepted")
        } else {
            // Create a new coach entry in the database.
            try await CoachManager.shared.addCoach(coachId: authDataResult.uid)
        }
    }
    
    
    /// Validates the team access code entered by the user.
    /// This function checks if the provided team access code corresponds to a valid team in the system.
    /// - Returns: A `DBTeam` object if the access code is valid, otherwise throws a `TeamValidationError`.
    /// - Throws: A `TeamValidationError` if the access code is invalid.
    func validateTeamAccessCode() async throws -> DBTeam {
        let teamManager = TeamManager()
        guard let team = try await teamManager.getTeamWithAccessCode(accessCode: teamAccessCode) else {
            print("Invalid access code")
            throw TeamValidationError.invalidAccessCode
        }
        
        self.teamId = team.teamId
        return team
    }
    
    
    /// Checks if the email is already registered in the system.
    /// This function queries the database to check if the provided email exists and returns the corresponding user object.
    /// - Returns: A `DBUser` object if the email exists, otherwise `nil`.
    /// - Throws: An error if the query to check the email fails.
    func verifyEmailAddress() async throws -> DBUser? {
        let userManager = UserManager()
        // verify the email address.
        guard let user = try await userManager.getUserWithEmail(email: email) else {
            print("User does not exist")
            return nil
        }
        return user
    }
    
    
    /// Verifies that a user with the given email does not already exist.
    /// This function checks if the user ID already exists for the email and prevents the creation of a new user with the same ID.
    /// - Throws: An error if the user ID already exists.
    func verifyUserIdDoesNotExist() async throws {
        // verify the email address.
        let user = try await verifyEmailAddress()
        // If the user ID exists, the process is aborted.
        guard user?.userId == nil else {
            print("A user and player exists with this userId.")
            throw TeamValidationError.userExists
        }
    }
    
    /// Resets all account-related fields to their default values.
    /// This function clears all fields used for user registration or authentication, essentially resetting the account creation form.
    func resetAccountFields() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        phone = ""
        country = "Canada"
        timeZone = ""
        teamAccessCode = ""
    }
}

