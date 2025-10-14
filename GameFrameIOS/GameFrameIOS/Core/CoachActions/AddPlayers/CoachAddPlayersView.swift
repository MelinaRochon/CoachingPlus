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
    
    // MARK: - State Properties

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
    
    // MARK: - View

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: tmpCoachAddPlayerView( team: team)) {
                    Text("Tmp coach add player view")
                }
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
                    Button{
                        Task {
                            do {
                                authenticationModel.email = email
                                let verifyEmail = try await authenticationModel.verifyEmailAddress()
                                
                                if verifyEmail != nil {
                                    // A user exists. Error
                                    showErrorAlert = true
                                    return
                                }
                                // Create a new user
                                let user = UserDTO(userId: nil, email: email, userType: .player, firstName: firstName, lastName: lastName)
                                let userDocId = try await userModel.addUser(userDTO: user)
                                
                                // Create a new player
                                let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [team.teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
                                let playerDocId = try await PlayerManager().createNewPlayer(playerDTO: player)
                                
                                // Create a new invite
                                let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: team.teamId)
                                let inviteDocId = try await inviteModel.addInvite(inviteDTO: invite)
                                
                                let canDismiss = try await playerModel.addPlayerToTeam(teamDocId: team.id, inviteDocId: inviteDocId)
                                    
                                if canDismiss {
                                    dismiss() // Dismiss the full-screen cover
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Add").foregroundStyle(addPlayerToTeamIsValid ? .red : .gray)
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


// MARK: - Add Player validation

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


extension tmpCoachAddPlayerView: PlayerProtocol {
    /// A computed property that checks if the player's data is valid for adding to the team.
    /// The player's first name, last name, and email must not be empty, and the email must contain "@".
    var addPlayerToTeamIsValid: Bool {
        return !firstName.isEmpty               // Ensure first name is not empty
            && !lastName.isEmpty               // Ensure last name is not empty
            && !email.isEmpty                 // Ensure email is not empty
            && email.contains("@")            // Ensure email contains '@' symbol for basic validation
    }
}


struct tmpCoachAddPlayerView: View {
    
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
    
    @State private var playerExists: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !playerExists {
                //                ScrollView{
                Spacer().frame(height: 20)
                VStack(spacing: 5) {
                    Text("Invite a player to join").font(.title) //.multilineTextAlignment(.center)
                    //                    Text("Invite a player to join \(team.name)").font(.title3).multilineTextAlignment(.center).bold()
                    Text(team.name).font(.title3).multilineTextAlignment(.center)
                }
                VStack(spacing: 10) {
                    Text("Enter their email address").font(.footnote).foregroundStyle(.gray).multilineTextAlignment(.center).padding(.top, 30)
                    //                        CustomUIFields.customTextField("Email", text: $email)
                    TextField("Player Email", text: $email)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal, 15)
                
                Spacer()
                VStack {
                    Button {
                        Task {
                            do {
                                authenticationModel.email = email
                                let verifyEmail = try await authenticationModel.verifyEmailAddress()
                                
                                if verifyEmail != nil {
                                    // A user exists. Error
                                    // TODO: Send an email invite to the player
                                    playerExists.toggle()
                                }
                                // Create a new user
                                let user = UserDTO(userId: nil, email: email, userType: .player, firstName: firstName, lastName: lastName)
                                let userDocId = try await userModel.addUser(userDTO: user)
                                
                                // Create a new player
                                let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [team.teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
                                let playerDocId = try await PlayerManager().createNewPlayer(playerDTO: player)
                                
                                // Create a new invite
                                let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: team.teamId)
                                let inviteDocId = try await inviteModel.addInvite(inviteDTO: invite)
                                
                                let canDismiss = try await playerModel.addPlayerToTeam(teamDocId: team.id, inviteDocId: inviteDocId)
                                
                                if canDismiss {
                                    dismiss() // Dismiss the full-screen cover
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label : {
                        CustomUIFields.signInAccountButton("Send Invite").padding(.top, 5).padding(.horizontal, 10)
                    }
                }
                //                }
            } else {
                    Text("Invite to \(email) was sent!").font(.title3)
                    Form {
                        
//                        Section {
//                            TextField("First name", text: $firstName).foregroundStyle(.secondary)
//                            TextField("Last name", text: $lastName).foregroundStyle(.secondary)
//                        }
                        
                        Section {
                            TextField("Email address", text: $email).foregroundStyle(.secondary).multilineTextAlignment(.leading).textContentType(.emailAddress).keyboardType(.emailAddress).autocapitalization(.none).disabled(true)
                        }
                        
                        Section (header: Text("Optional Player Information")) {
                            TextField("Player Nickname", text: $nickname).foregroundStyle(.secondary)
                            HStack {
                                Text("Jersey #")
                                Spacer()
                                // Will need to make this only for int -> make sure it doesn't allow + or -
                                TextField("Jersey", value: $jersey, format: .number).foregroundStyle(.primary).multilineTextAlignment(.trailing).keyboardType(.numberPad)
                            }
//                            TextField("Medical Information")
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
                    Button{
                        Task {
                            do {
                                authenticationModel.email = email
                                let verifyEmail = try await authenticationModel.verifyEmailAddress()
                                
                                if verifyEmail != nil {
                                    // A user exists. Error
                                    showErrorAlert = true
                                    return
                                }
                                // Create a new user
                                let user = UserDTO(userId: nil, email: email, userType: .player, firstName: firstName, lastName: lastName)
                                let userDocId = try await userModel.addUser(userDTO: user)
                                
                                // Create a new player
                                let player = PlayerDTO(playerId: nil, jerseyNum: jersey, gender: team.gender, profilePicture: nil, teamsEnrolled: [team.teamId], guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
                                let playerDocId = try await PlayerManager().createNewPlayer(playerDTO: player)
                                
                                // Create a new invite
                                let invite = InviteDTO(userDocId: userDocId, playerDocId: playerDocId, email: email, status: "Pending", dateAccepted: nil, teamId: team.teamId)
                                let inviteDocId = try await inviteModel.addInvite(inviteDTO: invite)
                                
                                let canDismiss = try await playerModel.addPlayerToTeam(teamDocId: team.id, inviteDocId: inviteDocId)
                                    
                                if canDismiss {
                                    dismiss() // Dismiss the full-screen cover
                                }
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Add").foregroundStyle(addPlayerToTeamIsValid ? .red : .gray)
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
