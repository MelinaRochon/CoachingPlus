//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI
import GameFrameIOSShared

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
    @StateObject private var playerTeamInfoModel = PlayerTeamInfoModel()

    @EnvironmentObject private var dependencies: DependencyContainer

    /// Environment value used to dismiss the current view and go back to the previous screen, such as the "Create Team" view.
    @Environment(\.dismiss) var dismiss

    /// Holds the player's first name input by the user.
    @State private var firstName = ""

    /// Holds the player's last name input by the user.
    @State private var lastName = ""

    /// Stores the jersey number for the player (used for identification in the team).
    @State private var jersey: Int = 0

    /// Holds the player's nickname input by the user.
    @State private var nickname: String = ""

    /// Holds the player's email address input by the user (used for communication and notifications).
    @State var email: String

    /// Holds the name of the player's guardian (usually required for underage players).
    @State private var guardianName: String = ""

    /// Holds the guardian's email address for communication and emergencies.
    @State private var guardianEmail: String = ""

    /// Holds the guardian's phone number for communication, in case of emergencies or notifications.
    @State private var guardianPhone: String = ""
    
    @State private var selectedPositions: Set<SoccerPosition> = []

    @State var team: DBTeam
    
    @Binding var isViewDismissed: Bool
        
    // MARK: - View

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    CustomUIFields.customTitle("Player Profile Setup", subTitle: "Please provide the player’s basic information before inviting them to join the team.")
                    
                    VStack {
                        CustomUIFields.customDivider("Player Information")
                            .padding(.top, 30)
                        CustomTextField(label: "First Name", text: $firstName)
                        CustomTextField(label: "Last Name", text: $lastName)
                        CustomTextField(label: "Email", text: $email, icon: "envelope", type: .email, disabled: true)
                        
                        CustomUIFields.customDivider("Guardian Information (Optional)")
                            .padding(.top, 30)
                        CustomTextField(label: "Guardian Name", text: $guardianName, isRequired: false)
                        CustomTextField(label: "Guardian Email", text: $guardianEmail, isRequired: false, icon: "envelope", type: .email)
                        CustomTextField(label: "Guardian Phone", placeholder: "(XXX)-XXX-XXXX", text: $guardianPhone, isRequired: false, icon: "phone", type: .phone)
                    }
                    .padding(.horizontal, 15)
                }
                .padding(.bottom, 30)
                ReviewPlayerDetailsView(
                    firstName: firstName,
                    lastName: lastName,
                    guardianName: guardianName,
                    guardianEmail: guardianEmail,
                    guardianPhone: guardianPhone,
                    selectedPositions: $selectedPositions,
                    nickname: $nickname,
                    jersey: $jersey,
                    playerNickname: nickname,
                    playerJersey: jersey,
                    playerSelectedPositions: selectedPositions,
                )
                
            }
            .toolbarBackground(.clear, for: .bottomBar)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")   // your icon
                                .font(.headline)
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            
                            // Player was not found. Create a new user, player and playerTeamInfo
                            // Update the team so the player is added to its roster
                            
                            // Create a new user
                            let user = UserDTO(userId: nil, email: email, userType: .player, firstName: firstName, lastName: lastName)
                            let userDocId = try await userModel.addUser(userDTO: user)
                            
                            // Create a new player
                            let player = PlayerDTO(
                                playerId: nil,
                                gender: team.gender,
                                profilePicture: nil,
                                teamsEnrolled: [team.teamId],
                                guardianName: guardianName,
                                guardianEmail: guardianEmail,
                                guardianPhone: guardianPhone
                            )
                            
                            let playerDocId = try await dependencies.playerManager.createNewPlayer(playerDTO: player)
                            
                            // Add the player information for the specific team id
                            let playerTeamInfoDTO = PlayerTeamInfoDTO(
                                id: team.teamId,
                                playerDocId: playerDocId,
                                nickname: nickname,
                                jerseyNum: jersey,
                                positions: Array(selectedPositions),
                                joinedAt: Date()
                            )
                            
                            // Create the player team info object
                            _ = try await playerTeamInfoModel.createPlayerTeamInfo(playerTeamInfoDTO: playerTeamInfoDTO)
                            
                            
                            // Create a new invite
                            let invite = InviteDTO(
                                userDocId: userDocId,
                                playerDocId: playerDocId,
                                email: email,
                                status: .unverified,
                                dateVerified: nil
                            )
                            let inviteDocId = try await inviteModel.addInvite(inviteDTO: invite)
                            
                            // Add invitation to the user's invite
                            let teamInviteDTO = TeamInviteDTO(
                                teamId: team.teamId,
                                status: .pending,
                                dateAccepted: nil
                            )
                            
                            _ = try await inviteModel.addTeamInvite(inviteDocId: inviteDocId, teamInviteDTO: teamInviteDTO)
                            
                            let canDismiss = try await playerModel.addPlayerToTeam(teamDocId: team.id, inviteDocId: inviteDocId)
                            
                            if canDismiss {
                                isViewDismissed = true
                                dismiss() // Dismiss the full-screen cover
                            }
                        }
                    } label : {
                        HStack {
                            Text("Request User to Join Roster")
                                .font(.body).bold()
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(addPlayerToTeamIsValid ? Color.black : Color.secondary))
                    }.disabled(!addPlayerToTeamIsValid)
                }
            }
            .onAppear {
                userModel.setDependencies(dependencies)
                inviteModel.setDependencies(dependencies)
                playerModel.setDependencies(dependencies)
                playerTeamInfoModel.setDependencies(dependencies)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


// MARK: - Add Player validation

/// Extension of the `CoachAddPlayersView` that conforms to the `PlayerProtocol`.
/// This extension provides a computed property to validate the player's data before adding them to the team.
extension CoachAddPlayersView: PlayerProtocol {
    /// A computed property that checks if the player's data is valid for adding to the team.
    /// The player's first name, last name, and email must not be empty, and the email must contain "@".
    var addPlayerToTeamIsValid: Bool {
        return !firstName.isEmpty && isValidName(firstName) // Ensure first name is not empty
            && !lastName.isEmpty && isValidName(lastName)   // Ensure last name is not empty
            && !email.isEmpty && isValidEmail(email)        // Check for a basic email format
            && (guardianPhone.isEmpty || isValidPhoneNumber(guardianPhone))
            && (guardianName.isEmpty || isValidName(guardianName))
            && (guardianEmail.isEmpty || isValidEmail(guardianEmail))
    }
}
