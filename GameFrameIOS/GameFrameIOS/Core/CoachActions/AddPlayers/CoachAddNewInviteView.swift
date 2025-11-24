//
//  CoachAddNewInviteView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI
import GameFrameIOSShared

struct CoachAddNewInviteView: View {
    
    /// A state object that handles the logic related to the players (e.g., adding and managing players).
    @StateObject private var playerModel = PlayerModel()
        
    /// A state object to manage the player invitations (e.g., sending, tracking, and managing invites).
    @StateObject private var inviteModel = InviteModel()
    
    /// A state object to handle user authentication and related login/logout functionality.
    @StateObject private var authenticationModel = AuthenticationModel()
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
    @State private var email = ""
        
    /// A boolean to control the visibility of an error alert, indicating invalid data or issues in player addition.
    @State private var showErrorAlert: Bool = false
    
    @State var team: DBTeam
    
    @State private var playerExists: Bool = false
    
    @State private var isLoading: Bool = false
    
    // Alerts variables
    @State private var playerNotFound: Bool = false
    @State private var verifiedPlayerExists: Bool = false
    @State private var unverifiedPlayerExists: Bool = false
    @State private var coachWasFoundAlert: Bool = false
    @State private var playerInviteAlreadyExistsForTeamAlert: Bool = false
    @State private var playerAlreadyAddedToTeamAlert: Bool = false
    
    @State private var searchedPlayerDocId: String?
    @State private var searchInviteDocId: String?
    
    @State private var selectedPositions: Set<SoccerPosition> = []
    
    @State private var playersAndInvitesForTeam: [String] = []
    @FocusState private var isFocused: Bool
    
    @State private var isViewDismissed: Bool = false
    
    var body: some View {
        NavigationView {
            
                VStack {
                    CustomUIFields.customPageTitle("Adding player to roster", subTitle: "Invite a player to join your team")
                        .padding(.bottom, 10)
                    
                    VStack(alignment: .leading ,spacing: 0) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter their email address").font(.footnote).fontWeight(.medium)
                            HStack {
                                TextField("Player Email", text: $email)
                                    .frame(height: 40)
                                    .padding(.horizontal)
                                    .background(RoundedRectangle(cornerRadius: 8)
                                        .stroke(isFocused ? Color.black : Color.gray, lineWidth: 1)
                                    )
                                    .foregroundColor(.black)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.emailAddress)
                                    .focused($isFocused)
                                    .onSubmit {
                                        hideKeyboard()
                                    }
                                
                                
                                Button {
                                    Task {
                                        isLoading = true
                                        resetFlags()
                                        do {
                                            try await searchEmailInDatabase()
                                        } catch {
                                            print(error)
                                        }
                                        isLoading = false  // ← END LOADING
                                    }
                                    
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 50, height: 40)
                                    .background(loginIsValid ? .black : Color.black.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(!loginIsValid)
                            }
                            
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                    }
                    .padding(.bottom, 15)
                    
                    Divider()
                    
                    ScrollView {
                    VStack (alignment: .center) {
                        if playerNotFound {
                            VStack(alignment: .center) {
                                VStack {
                                    Image(systemName: "person.fill.questionmark")
                                        .font(.system(size: 30))
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 2)
                                    
                                    Text("Player Not Found")
                                        .font(.headline)
                                    
                                    Text("We couldn't find any player associated with this email address.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }.padding(.vertical)
                                NavigationLink {
                                    CoachAddPlayersView(email: authenticationModel.email, team: team, isViewDismissed: $isViewDismissed)
                                } label: {
                                    HStack {
                                        Text("Add a new player").font(.body).bold()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200, height: 40)
                                    .background(Capsule().fill(.black))
                                }
                            }
                        }
                        
                        if unverifiedPlayerExists || verifiedPlayerExists {
                            VStack(alignment: .center) {
                                // Show the player card's info
                                NavigationLink {
                                    UpdatingPlayerInfoView(
                                        selectedPositions: $selectedPositions,
                                        nickname: $nickname, jersey: $jersey,
                                        playerNickname: nickname,
                                        playerJersey: jersey,
                                        playerSelectedPositions: selectedPositions
                                    )
                                } label: {
                                    PlayerCardView(
                                        firstName: firstName,
                                        lastName: lastName,
                                        email: authenticationModel.email,
                                        profileImage: nil,
                                        isVerified: verifiedPlayerExists ? true : false
                                    )
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    
                    if isLoading {
                        VStack {
                            ProgressView("Searching…")
                                .padding()
                                .background(.white)
                                .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
                .alert("Searching for an invalid player email address.", isPresented: $coachWasFoundAlert) {
                    Button("OK") {
                        resetFlags()
                        email = ""
                    }
                } message: {
                    Text("The email you are looking for is invalid.")
                }
                .alert("Invitation for this player was already sent.", isPresented: $playerInviteAlreadyExistsForTeamAlert) {
                    Button("OK") {
                        resetFlags()
                        email = ""
                    }
                } message: {
                    Text("This player was already added to your roster.")
                }
                .alert("Player is already on the team roster", isPresented: $playerAlreadyAddedToTeamAlert) {
                    Button("OK") {
                        resetFlags()
                        email = ""
                    }
                } message: {
                    Text("This player was already added to your roster.")
                }
                .alert("A user with the specified email already exists.", isPresented: $showErrorAlert) {
                    Button(role: .cancel) {
                        // reset email and password
                        dismiss()
                    } label: {
                        Text("OK")
                    }
                }
                .onChange(of: isViewDismissed) {
                    dismiss()
                }
                .onAppear {
                    authenticationModel.setDependencies(dependencies)
                    inviteModel.setDependencies(dependencies)
                    playerModel.setDependencies(dependencies)
                    playerTeamInfoModel.setDependencies(dependencies)
                    
                    Task {
                        // Get all the players and invites for this team
                        if let players = team.players {
                            playersAndInvitesForTeam.append(contentsOf: players)
                        }
                        if let invites = team.invites {
                            playersAndInvitesForTeam.append(contentsOf: invites)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack {
                            Text("Cancel")
//                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        Task {
                            do {
                                try await sendingInvite()
                            } catch {
                                print(error)
                            }
                        }
                    } label : {
                        HStack {
                            if verifiedPlayerExists {
                                Text("Send Request to Join Roster")
                                    .font(.body).bold()
                            } else if unverifiedPlayerExists {
                                Text("Send Invite")
                                    .font(.body).bold()
                            }
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(Color.black))
                    }
                    .opacity(!unverifiedPlayerExists && !verifiedPlayerExists ? 0 : 1)
                }
            }
        }
        
        .scrollDismissesKeyboard(.immediately)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbarBackground(Color.white, for: .bottomBar)
    }
    
    
    private func resetFlags() {
        playerNotFound = false
        unverifiedPlayerExists = false
        verifiedPlayerExists = false
    }
    
    private func searchEmailInDatabase() async throws {
        authenticationModel.email = email
        email = "" // Reset the email address
        hideKeyboard()
        // Try to get the user's info using the email address entered in the textfield, if found
        guard let user = try await authenticationModel.verifyEmailAddress() else {
            // Player not found in database. Create a new invite
            isLoading = false
            playerNotFound = true
            return
        }
        
        // User was found in the database
        // Get user's info using the email address entered in the textfield
        do {
            // Check if the player has an invite and if so, if its pending or was accepted
            let invite = try await inviteModel.findInviteUsingUserDocIdAndUserEmailAddress(
                userDocId: user.id,
                email: authenticationModel.email
            )
            
            searchInviteDocId = invite.id
            do {
                // Check if the player's invite
                let wasInviteCreatedForThisTeam = try await inviteModel.doesPlayerHaveInviteForThisTeam(inviteDocId: invite.id, email: email, teamId: team.teamId)
                // Make sure the invite was not already added for this team
                if playersAndInvitesForTeam.contains(invite.id) || wasInviteCreatedForThisTeam {
                    // Player invite was already added to team
                    playerInviteAlreadyExistsForTeamAlert = true
                    isLoading = false
                    return
                }
                
                let player = try await playerModel.findPlayerWithPlayerDocId(playerDocId: invite.playerDocId)
                
                // Keep the player's doc id for later on
                searchedPlayerDocId = player.id
                
                if invite.status == .unverified {
                    // Player was never verified, but an invite exists in the database
                    // Show the "if invite was found" form
                    unverifiedPlayerExists = true
                    
                } else if invite.status == .verified {
                    // Player was verified (found)
                    verifiedPlayerExists = true
                }
            } catch PlayerError.playerNotFound {
                isLoading = false
                return
            } catch InviteError.errorWhenCreatingTeamInvite {
                print("Error happended when trying to create a team invite")
                // TODO: Take care of this error
                isLoading = false
                return
            }
        } catch InviteError.inviteNotFound {
            // Check if the user is a valid player
            do {
                if let userId = user.userId, userId != "" {
                    let player = try await playerModel.findPlayerWithUserId(userId: userId, teamId: team.teamId)
                    
                    // Make sure the invite was not already added for this team
                    if playersAndInvitesForTeam.contains(player.id) {
                        // Player invite was already added to team
                        playerAlreadyAddedToTeamAlert = true
                    }
                    
                    // Keep the player's doc id for later on
                    searchedPlayerDocId = player.id
                    
                    // A verified player (player that either accepted an invitation from a previous team or player that created an account) exists
                    verifiedPlayerExists = true
                }
            } catch PlayerError.playerNotFound {
                // User is a coach. Cannot invite a coach
                isLoading = false
                coachWasFoundAlert = true
                return
            } catch PlayerError.playerAlreadyAddedToTeam {
                isLoading = false
                playerAlreadyAddedToTeamAlert = true
            }
        }
        
        // Store the user's name to show player's card later on
        firstName = user.firstName
        lastName = user.lastName

    }
    
    private func sendingInvite() async throws {
        // Verified user & unverified user
        // Add the player information for the specific team id
        if let playerDocId = searchedPlayerDocId {
            let playerTeamInfoDTO = PlayerTeamInfoDTO(
                id: team.teamId,
                playerDocId: playerDocId,
                nickname: nickname,
                jerseyNum: jersey,
                positions: Array(selectedPositions),
                joinedAt: Date()
            )
            
            // Add invitation to the user's invite
            let teamInviteDTO = TeamInviteDTO(
                teamId: team.teamId,
                status: .pending,
                dateAccepted: nil
            )
            
            if let inviteDocId = searchInviteDocId {
                
                print("found a search invite doc id")
                _ = try await inviteModel.addTeamInvite(inviteDocId: inviteDocId, teamInviteDTO: teamInviteDTO)
                
                // Create the player team info object
                _ = try await playerTeamInfoModel.createPlayerTeamInfo(playerTeamInfoDTO: playerTeamInfoDTO)
                let canDismiss = try await playerModel.addPlayerToTeam(teamDocId: team.id, inviteDocId: inviteDocId)
                
                if canDismiss {
                    dismiss() // Dismiss the full-screen cover
                }
            }
        }
    }
}


extension CoachAddNewInviteView: PlayerProtocol {
    /// A computed property that checks if the player's data is valid for adding to the team.
    /// The player's first name, last name, and email must not be empty, and the email must contain "@".
    var addPlayerToTeamIsValid: Bool {
        return !firstName.isEmpty && isValidName(firstName) // Ensure first name is not empty
        && !lastName.isEmpty && isValidName(lastName)   // Ensure last name is not empty
        && !email.isEmpty && isValidEmail(email)        // Check for a basic email format
    }
}

extension CoachAddNewInviteView: AuthenticationLoginProtocol {
    // Computed property to validate login credentials
    var loginIsValid: Bool {
        return isValidEmail(email) && !email.isEmpty // isValidName(authenticationModel.email)
    }
}
