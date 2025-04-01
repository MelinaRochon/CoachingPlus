//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI

struct GetTeam: Equatable {
    var teamId: String
    var name: String
    var nickname: String
}


/**
 This file contains the `CoachAddPlayersView` structure, which provides a form for coaches to add a new player to a team.
 The view allows coaches to input essential player information such as first name, last name, email, nickname, jersey number,
 and guardian details like name, email, and phone number.

 The form also validates inputs and ensures that certain fields, such as the player's name and email, are filled in
 before the "Add" button is enabled. Upon submission, the player is added to the team, and the view is dismissed.
 
 This file also contains a utility function to format phone numbers as they are entered by the user.
*/
struct CoachAddPlayersView: View {
    
    /// ViewModels to manage the data and logic related to adding players
//    @ObservedObject var teamModel: TeamModel
    
    /// Observes and manages the team-related data, such as team details, players, and team operations.
    
    /// A state object that handles the logic related to the players (e.g., adding and managing players).
    @StateObject private var playerModel = PlayerModel()

    /// A state object responsible for managing user-related data (e.g., user authentication, user information).
    @StateObject private var userModel = UserModel()

    /// A state object to manage the player invitations (e.g., sending, tracking, and managing invites).
    @StateObject private var inviteModel = InviteModel()

    /// A state object to handle user authentication and related login/logout functionality.
    @StateObject private var authenticationModel = AuthenticationModel()

    /// Environment value used to dismiss the current view and go back to the previous screen, such as the "Create Team" view.
    @Environment(\.dismiss) var dismiss

    /// A list of possible gender options available for selection (e.g., for player registration).
    let genders = ["Female", "Male", "Other"]

    /// Holds the player's first name input by the user.
    @State private var firstName = ""

    /// Holds the player's last name input by the user.
    @State private var lastName = ""

    /// Stores the jersey number for the player (used for identification in the team).
    @State private var jersey: Int = 0

    /// Holds the player's nickname input by the user.
    @State private var nickname: String = ""

    /// Holds the player's email address input by the user (used for communication and notifications).
    @State private var email = ""

    /// Holds the name of the player's guardian (usually required for underage players).
    @State private var guardianName: String = ""

    /// Holds the guardian's email address for communication and emergencies.
    @State private var guardianEmail: String = ""

    /// Holds the guardian's phone number for communication, in case of emergencies or notifications.
    @State private var guardianPhone: String = ""

    /// A boolean to control the visibility of an error alert, indicating invalid data or issues in player addition.
    @State private var showErrorAlert: Bool = false
    
    @State var team: DBTeam
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("First name", text: $firstName).foregroundStyle(.secondary)
                        TextField("Last name", text: $lastName).foregroundStyle(.secondary)
                    }
                    
                    Section(footer: Text("The invite will be sent to this email address.")) {
                        TextField("Email address", text: $email).foregroundStyle(.secondary).multilineTextAlignment(.leading).textContentType(.emailAddress).keyboardType(.emailAddress).autocapitalization(.none)
                    }
                    
                    Section (header: Text("Optional Player Information")) {
                        TextField("Player Nickname", text: $nickname).foregroundStyle(.secondary)
                        HStack {
                            Text("Jersey #")
                            Spacer()
                            // Will need to make this only for int -> make sure it doesn't allow + or -
                            TextField("Jersey", value: $jersey, format: .number).foregroundStyle(.primary).multilineTextAlignment(.trailing).keyboardType(.numberPad)
                        }
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        TextField("Guardian Name", text: $guardianName).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        TextField("Guardian Email", text: $guardianEmail).foregroundStyle(.secondary).multilineTextAlignment(.leading).keyboardType(.emailAddress).textContentType(.emailAddress)
                        TextField("Guardian Phone", text: $guardianPhone).foregroundStyle(.secondary).multilineTextAlignment(.leading).keyboardType(.phonePad).textContentType(.telephoneNumber).onChange(of: guardianPhone) { newVal in
                            guardianPhone = formatPhoneNumber(newVal)
                        }
                    }
                }
                
            }
            .navigationTitle(Text("Adding a New Player")).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack {
                            Text("Cancel")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        Task {
                            do {
//                                if let team = teamModel.team {
//                                    try await TeamManager.shared.doesTeamExist(teamId: team.teamId)
                                    
                                    authenticationModel.email = email
                                    let verifyEmail = try await authenticationModel.verifyEmailAddress()
                                    
                                    if verifyEmail != nil {
                                        // A user exists. Error
                                        showErrorAlert = true
                                        return
                                    }
                                    // Create a new user
                                    let user = UserDTO(userId: nil, email: email, userType: "Player", firstName: firstName, lastName: lastName)
                                    let userDocId = try await userModel.addUser(userDTO: user)
                                    
                                    // Create a new player
                                    let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [team.teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
                                    let playerDocId = try await playerModel.addPlayer(playerDTO: player)
                                    
                                    // Create a new invite
                                    let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: team.teamId)
                                    let inviteDocId = try await inviteModel.addInvite(inviteDTO: invite)
                                    
                                    let canDismiss = try await playerModel.addPlayerToTeam(teamId: team.teamId, inviteDocId: inviteDocId) // to add player
                                    
                                    if canDismiss {
                                        dismiss() // Dismiss the full-screen cover
                                    }
//                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .disabled(!addPlayerToTeamIsValid)
                }
            }
            .alert("A user with the specified email already exists.", isPresented: $showErrorAlert) {
                Button(role: .cancel) {
                    // reset email and password
                    dismiss()
                } label: {
                    Text("OK")
                }
            }
        }
    }
}


/// Extension of the `CoachAddPlayersView` that conforms to the `PlayerProtocol`.
/// This extension provides a computed property to validate the player's data before adding them to the team.
extension CoachAddPlayersView: PlayerProtocol {
    /// A computed property that checks if the player's data is valid for adding to the team.
    /// The player's first name, last name, and email must not be empty, and the email must contain "@".
    var addPlayerToTeamIsValid: Bool {
        return !firstName.isEmpty               // Ensure first name is not empty
            && !lastName.isEmpty               // Ensure last name is not empty
            && !email.isEmpty                 // Ensure email is not empty
            && email.contains("@")            // Ensure email contains '@' symbol for basic validation
    }
}


#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    CoachAddPlayersView(team: team)
}
