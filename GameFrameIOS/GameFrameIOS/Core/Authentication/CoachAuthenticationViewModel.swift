//
//  AuthenticationViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
import FirebaseFirestore

@MainActor
/** Observable object to be called when the coach wants to authenticate by performing one of the
 following action: signIn, signUp. */
final class authenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()
    @Published var phone = ""
    @Published var country = "Canada"
    @Published var timeZone = ""
    @Published var teamAccessCode: String = ""
    @Published var teamId: String = "" // team id
    @Published var teamName: String = ""
    
    @Published var showInvalidCodeAlert: Bool = false // Controls alert visibility
    @Published var showSignUpScreen: Bool = false // Controls navigation if valid
    let db = Firestore.firestore()

    func signIn(userType: String) async throws {
        print("SignIn Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        //try await AuthenticationManager.shared.signInUser(email: email, password: password)
        let authDataResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
        print("user id: \(authDataResult.uid)")

        try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        // just for test purpose
//        let coach = DBCoach(coachId: authDataResult.uid)
//        try await CoachManager.shared.addCoach(coach: coach)
//        
//        // add team - only for testing purpose
//        try await CoachManager.shared.addTeamToCoach(coachId: authDataResult.uid, teamId: "zzlZyozdFYaQeUR5gsr7")
        
        // Following function should not be used! Should only be used for testing purpose
        //try await createUserOfType(userType: userType, userId: authDataResult.uid)
    }
    
    func signUp(userType: String) async throws {
        print("\(userType) SignUp Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        guard email.contains("@") else {
            print("Not a valid email")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = UserDTO(userId: authDataResult.uid, email: authDataResult.email, userType: userType, firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, country: country)
        try await UserManager.shared.createNewUser(userDTO: user)
        
        // create a new user, according to type
        if (userType == "Player") {
            // TO DO - Get the gender from the team and the teamId
            let player = PlayerDTO(playerId: authDataResult.uid, jerseyNum: 0, gender: "", profilePicture: nil, teamsEnrolled: ["zzlZyozdFYaQeUR5gsr7"])
            try await PlayerManager.shared.createNewPlayer(playerDTO: player)
        } else {
            // Create a new coach
            try await CoachManager.shared.addCoach(coachId: authDataResult.uid)
        }
    }
    
    /** Should ONLY be used for testing purposes. */
    func createUserOfType(userType: String, userId: String) async throws {
        print ("--- Creating a new user of type player ")
        
        if (userType == "Player") {
//            let player = DBPlayer(playerId: userId)
//            try await PlayerManager.shared.createNewPlayer(player: player)
            let player = PlayerDTO(playerId: userId, jerseyNum: 0, gender: "", profilePicture: nil, teamsEnrolled: ["zzlZyozdFYaQeUR5gsr7"])
            try await PlayerManager.shared.createNewPlayer(playerDTO: player)
        }
    }
    
    func checkIfPlayerAccountExists() async throws -> Bool? {
        // check using the email address and the team access code
        guard !teamAccessCode.isEmpty, !email.isEmpty else {
            print("Need to enter a valid email address and team access code")
            return nil
        }
        
        // verify the access code
        guard let team = try await TeamManager.shared.getTeamWithAccessCode(accessCode: teamAccessCode) else {
            print("Access code invalid")
            return nil
        }
        
        self.teamId = team.teamId

        // verify the email address.
        guard let user = try await UserManager.shared.getUserWithEmail(email: email) else {
            print("User does not exist")
            return false
        }
        // if user id -> return, otherwise continue
        
        // verify the email address exists inside an invite
        guard let invite = try await InviteManager.shared.getInviteByEmailAndTeamId(email: email, teamId: team.teamId) else {
            print("Invite for this player does not exists. Might be a problem.")
            return false // TO DO - Might need to delete the existing user from the database otherwise, will never be able to create an account with that email
        }
        
        // an account already exists for that email address and that team
        return true
    }
    
    func checkIfUserIdExists() async throws -> Bool {
        guard let user = try await UserManager.shared.getUserWithEmail(email: email) else {
            print("User does not exist")
            return false
        }
        
        // if user id -> return, otherwise continue
        guard user.userId == nil else {
            print("User id already exists. Trying to access a user that already exists. Abort")
            return true
        }

        return false
    }
    
    func loadPlayerInfo(email: String, teamId: String) async throws {
        // Get the team with the teamId
        guard !email.isEmpty else {
            print("Email is empty. Cannot load user info")
            return
        }
        
        guard !teamId.isEmpty else {
            print("Team ID is empty. Cannot load user info")
            return
        }
        
        // Get the invite to load thed data
        guard let invite = try await InviteManager.shared.getInviteByEmailAndTeamId(email: email, teamId: teamId) else {
            print("Invite for this player does not exists. Might be a problem.")
            return  // TO DO - Might need to delete the existing user from the database otherwise, will never be able to create an account with that email
        }
        
        // Get the team name
        guard let team = try await TeamManager.shared.getTeam(teamId: invite.teamId) else {
            print("Error. Couldn't get the team. Aborting")
            return
        }
        self.teamName = team.name // set the team name
                
        // Retrive the user document
        guard let user = try await UserManager.shared.findUserWithId(id: invite.userDocId) else {
            print("Error. Could not find the user document. Aborting")
            return
        }
        if (user.email != email) {
            print("Error. Emails do not match. Aborting")
            return
        }
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.dateOfBirth = user.dateOfBirth ?? Date()
        self.phone = user.phone ?? ""
        self.country = user.country ?? "Canada"
    }
    
    func playerSignUp() async throws {
        print("PLAYER SignUp Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        guard email.contains("@") else {
            print("Not a valid email")
            return
        }
        
        guard !firstName.isEmpty, !lastName.isEmpty else {
            print("No first name or last name found.")
            return
        }
        
        // create a new authenticated user
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)

        guard let team = try await TeamManager.shared.getTeam(teamId: teamId) else {
            print("Team looking for does not exist. Abort. teamId: \(teamId)")
            return
        }
        
        guard let invite = try await InviteManager.shared.getInviteByEmailAndTeamId(email: email, teamId: teamId) else {
            print("Invite for this player does not exists. Creating a new user.")
            
            // new user. Create a user and player, and add the playerId in the team
            let user = UserDTO(userId: authDataResult.uid, email: email, userType: "Player", firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth, phone: phone, country: country)
            let userDocId = try await UserManager.shared.createNewUser(userDTO: user)
            print("UserManager created at user doc: \(userDocId)")

            // create a new player,
            let player = PlayerDTO(playerId: authDataResult.uid, jerseyNum: 0, nickName: nil, gender: team.gender, profilePicture: nil, teamsEnrolled: [teamId], guardianName: nil, guardianEmail: nil, guardianPhone: nil)
                let playerDocId = try await PlayerManager.shared.createNewPlayer(playerDTO: player)
            print("Player doc id was created! \(playerDocId)")
            
            // Add player to team
            try await TeamManager.shared.addPlayerToTeam(id: team.id, playerId: authDataResult.uid)
            return  // TO DO - Might need to delete the existing user from the database otherwise, will never be able to create an account with that email
            
        }
                
        // update the user document
        try await UserManager.shared.updateUserDTO(id: invite.userDocId, email: email, userTpe: "Player", firstName: firstName, lastName: lastName, dob: dateOfBirth, phone: phone, country: country, userId: authDataResult.uid)

        // update the player document
        try await PlayerManager.shared.updatePlayerId(id: invite.playerDocId, playerId: authDataResult.uid)
        
        // update the team document
        // Remove user from the invites array ??
        
        // Look for the correct team
        guard let team = try await TeamManager.shared.getTeam(teamId: invite.teamId) else {
            print("Team looking for does not exist. Abort")
            return
        }
        // Add user in the players array
        try await TeamManager.shared.addPlayerToTeam(id: team.id, playerId: authDataResult.uid)
        
        
        // update the status of the player
        // Set to accepted
        try await InviteManager.shared.updateInviteStatus(id: invite.id, newStatus: "Accepted")
        print("it worked!")
    }
    
    // validating if team access code is valid
        func validateTeamAccessCode() async {
            do {
                let snapshot = try await db.collection("teams")
                    .whereField("access_code", isEqualTo: teamAccessCode)
                    .getDocuments()
                print("Query for access codes executed, found \(snapshot.documents.count) results")
                if let document = snapshot.documents.first {
                    self.teamId = document.documentID // Store the valid team ID
                    self.teamName = document["name"] as? String ?? "Unknown Team"
                    self.showSignUpScreen = true // Allow navigation to sign-up
                } else {
                    self.showInvalidCodeAlert = true // Show alert in UI
                }
            } catch {
                print("Error checking team access code: \(error.localizedDescription)")
                self.showInvalidCodeAlert = true // Show error alert
            }
        }
}
