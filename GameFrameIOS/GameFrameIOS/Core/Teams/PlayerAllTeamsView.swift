//
//  PlayerAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI
//import FirebaseFirestore

/// `PlayerAllTeamsView` is a SwiftUI view that displays a list of teams a player is associated with.
/// This view also provides functionality for the player to enter a "group code" to join a new team.
///
/// ### Key Features:
/// 1. **List of Teams**: Displays the player's current teams in a list. If no teams are found, a message "No teams found." is shown.
///    - Each team in the list is tappable and navigates to `PlayerMyTeamView` where the player can interact with the team's details.
/// 2. **Group Code for Joining Teams**: The player can enter a group code to join a new team. When the user taps "Enter Code", a text field appears where the player can enter the group code.
///    - If the group code is valid, the player is added to the team. Otherwise, an error message is shown.
/// 3. **Error Handling**: If the group code is invalid or there is an error when adding the player to the team, error alerts are displayed.
struct PlayerAllTeamsView: View {
    
    /// Controls the visibility of the text field for entering the group code
    /// This state variable determines whether the user should see the input field
    /// for entering a team access code or not.
    @State private var showTextField = false

    /// Stores the group code entered by the player
    /// This is a temporary variable that holds the code entered by the player
    /// to join a new team. It is submitted when the player clicks the "Submit" button.
    @State private var groupCode: String = ""

    /// Tracks whether the initial view (the "Have a Group Code?" text and the "Enter Code" button) should be shown
    /// This is used to toggle between the initial "Have a Group Code?" message and the input field for the code.
    /// When the player decides to enter a code, this view will hide and show the code entry field instead.
    @State private var showInitialView = true

    /// A state object that holds the team model, which handles team-related data and logic
    /// This object is used to fetch the list of teams, validate access codes, and add the player to a team.
    @StateObject private var teamModel = TeamModel()
    @StateObject private var playerTeamInfoModel = PlayerTeamInfoModel()

    /// Holds the list of teams that the player is currently part of
    /// This state variable stores the teams fetched from the backend or database. It is updated when the data is loaded.
    @State private var teams: [DBTeam]?

    /// Controls whether an alert should be shown when an invalid access code is entered
    /// This state variable is triggered if the player submits a group code that doesn't match any team.
    @State private var showErrorAccessCode: Bool = false

    /// Controls whether an error alert should be shown if there is an issue adding the player to the team
    /// If an error occurs when trying to add the player to the team, this flag will display a related alert.
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: HStack {
                        Text("My Teams") // Section header text
                    }) {
                        if let teams = teams {
                            if !teams.isEmpty {
                                ForEach(teams, id: \.name) { team in
                                    NavigationLink(destination: PlayerMyTeamView(selectedTeam: team)
                                    ) {
                                        HStack {
                                            Image(systemName: "tshirt").foregroundStyle(.red) // TODO: Will need to change the team's logo in the future
                                            Text(team.name)
                                        }
                                    }
                                }
                            } else {
                                Text("No teams found.").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                
                Spacer()
                VStack {
                    // Show initial text & button if `showInitialView` is true
                    if showInitialView {
                        HStack {
                            Text("Have a Group Code?")
                                .font(.footnote)
                            
                            Button(action: {
                                withAnimation {
                                    showTextField = true  // Show input field
                                    showInitialView = false // Hide initial view
                                }
                            }) {
                                HStack {
                                    Text("Enter Code").font(.subheadline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .cornerRadius(30)
                            }
                            .padding()
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Show text field & submit button when `showTextField` is true
                    if showTextField {
                        HStack {
                            TextField("Your Code", text: $groupCode)
                                .padding(.horizontal, 8)
                                .cornerRadius(40).frame(width: 190)
                                .frame(height: 35)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.black).autocapitalization(.none)
                                .font(.subheadline)
                            
                            Button(action: {
                                withAnimation {
                                    showTextField = false  // Hide input field
                                    showInitialView = true // Bring back initial text & button
                                }
                                print("Submitted Code: \(groupCode)") // Handle submission
                                // check accesscode entered
                                Task {
                                    do {
                                        let tmpTeam = try await teamModel.validateTeamAccessCode(accessCode: groupCode)
                                        do {
                                            let newTeam = try await teamModel.addingPlayerToTeam(team: tmpTeam)
                                            teams!.append(newTeam!)
                                            groupCode = "" // Reset input field

                                            let teamId = newTeam?.teamId ?? ""
                                            guard !teamId.isEmpty else {
                                                throw NSError(domain: "JoinTeam", code: 1,
                                                              userInfo: [NSLocalizedDescriptionKey: "Missing team id"])
                                            }
                                            let auth = try AuthenticationManager.shared.getAuthenticatedUser()

                                            // Build the DTO
                                                let dto = PlayerTeamInfoDTO(
                                                    id: teamId,
                                                    playerId: auth.uid,
                                                    nickname: nil,
                                                    jerseyNum: nil,
                                                    joinedAt: nil           // nil => server timestamp
                                                )

                                                _ = try await playerTeamInfoModel.createPlayerTeamInfo(playerTeamInfoDTO: dto)

                                        } catch {
                                            print("Error when adding user to team. \(error)")
                                            showError = true
                                        }
                                        
                                        
                                    } catch {
                                        showErrorAccessCode = true
                                        print("Error when submitting a team's access code. \(error)")
                                    }
                                }
                                
                            }) {
                                HStack {
                                    Text("Submit").font(.subheadline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .cornerRadius(30)
                                
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding()
                        .transition(.opacity) // Smooth fade-in/out effect
                    }
                }
                .padding(.bottom, 85)
            }
            .transaction { $0.animation = nil }
            .navigationTitle(Text("Teams"))
        }
        .task {
            do {
                self.teams = try await teamModel.loadAllTeams()
            } catch {
                print("Error. Aborting... \(error)")
            }
        }
        .alert("Invalid access code entered", isPresented: $showErrorAccessCode) {
            Button("OK", role: .cancel) {
                groupCode = "" // Reset input field
            }
        }
        .alert("Error when trying to add team. Please try again later", isPresented: $showError) {
            Button("OK", role: .cancel) {
                groupCode = "" // Reset input field
            }
        }
    }
}

#Preview {
    PlayerAllTeamsView()
}
