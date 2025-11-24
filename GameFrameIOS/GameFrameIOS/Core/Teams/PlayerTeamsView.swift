//
//  PlayerTeamsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI
import GameFrameIOSShared

struct PlayerTeamsView: View {
    
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
    @StateObject private var inviteModel = InviteModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    @StateObject private var playerTeamInfoModel = PlayerTeamInfoModel()

    /// Holds the list of teams that the player is currently part of
    /// This state variable stores the teams fetched from the backend or database. It is updated when the data is loaded.
    @State private var teams: [DBTeam]?
    @State private var invites: [Invite] = []
    @State private var teamInvites: [DBTeam] = []
    
    @State private var isLoadingTeamRequests: Bool = false
    @State private var isLoadingMyTeams: Bool = false
    
    /// Controls whether an alert should be shown when an invalid access code is entered
    /// This state variable is triggered if the player submits a group code that doesn't match any team.
    @State private var showErrorAccessCode: Bool = false

    /// Controls whether an error alert should be shown if there is an issue adding the player to the team
    /// If an error occurs when trying to add the player to the team, this flag will display a related alert.
    @State private var showError: Bool = false
    
    @State var selectedIndex: Int = 0

    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Divider() // This adds a divider after the title
                    
                    CustomSegmentedPicker(
                        selectedIndex: $selectedIndex,
                        options: [
                            (title: "My Teams", icon: "person.and.person.fill"),
                            (title: "Team Requests", icon: "bell.badge"),
                        ],
                        onSegmentTapped: { index in
                            Task { try await refreshData(for: index) }
                        }
                    )
                    
                    if selectedIndex == 0 {
                        // Show the player's teams that they are registered on
                        CustomListSection(
//                            title: "My Teams",
                            titleContent: {
                                AnyView(
                                CustomUIFields.customDivider("My Teams")
                            )},
                            items: teams ?? [],
                            isLoading: isLoadingMyTeams,
                            rowLogo: "tshirt",
                            isLoadingProgressViewTitle: "Searching for my teams…",
                            noItemsFoundIcon: "person.2.slash.fill",
                            noItemsFoundTitle: "No teams found at this time.",
                            noItemsFoundSubtitle: "Try joining a team using a team access code.",
                            destinationBuilder: { team in
                                PlayerMyTeamView(selectedTeam: team)
                            },
                            rowContent: { team in
                                AnyView(
                                    VStack (alignment: .leading, spacing: 4) {
                                        Text(team.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.black)
                                        Text(team.sport)
                                            .font(.caption)
                                            .padding(.leading, 1)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.gray)
                                    }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                )
                            }
                        )
                    } else {
                        VStack {
                            CustomUIFields.customDivider("Team Requests")
                            
                            if isLoadingTeamRequests {
                                VStack {
                                    ProgressView("Searching for requests…")
                                        .padding()
                                        .background(.white)
                                        .cornerRadius(12)
                                }
                            } else {
                                if !teamInvites.isEmpty {
                                    ScrollView {
                                        ForEach(teamInvites.indices, id: \.self) { index in
                                            let team = teamInvites[index]
                                            let invite = invites[index]
                                            PlayerJoinTeamInviteCardView(
                                                teamName: team.name,
                                                onAccept: {
                                                    // Add player to team
                                                    // Set the team invite to accepted
                                                    Task {
                                                        do {
                                                            try await teamModel.playerAcceptedInvite(inviteDocId: invite.id, teamId: team.teamId, teamDocId: team.id, playerDocId: invite.playerDocId)
                                                            // Remove from team_invites
                                                            teamInvites.remove(at: index)
                                                        } catch {
                                                            print("hit error")
                                                            // TODO: Take care of throw errors
                                                            return
                                                        }
                                                    }
                                                },
                                                onDecline: {
                                                    Task {
                                                        // Remove team invite from database
                                                        // Remove from team_invites
                                                        do {
                                                            try await teamModel.playerDeclineInvite(inviteDocId: invite.id, teamId: team.teamId, teamDocId: team.id)
                                                            teamInvites.remove(at: index)
                                                        } catch {
                                                            print("hit error onDecline")
                                                            // TODO: Take care of throw errors
                                                            return
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                                } else {
                                    VStack {
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                            .padding(.bottom, 2)
                                        
                                        Text("No team requests found at this time").font(.headline).foregroundStyle(.secondary)
                                        Text("Try again later")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 10)
                                    
                                }
                            }
                        }.padding(.horizontal, 15)
                    }
                    
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
                    }
                    .padding(.bottom, 85)
                }
                
                if isSaving {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView("Joining Team…")
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                }
            }
            .transaction { $0.animation = nil }
            .navigationTitle(Text("Teams"))
            .onAppear {
                teamModel.setDependencies(dependencies)
                playerTeamInfoModel.setDependencies(dependencies)
                playerTeamInfoModel.setDependencies(dependencies)
                inviteModel.setDependencies(dependencies)
            }
            .sheet(isPresented: $showTextField, onDismiss: {
                showTextField = false  // Hide input field
                showInitialView = true // Bring back initial text & button
            }) {
                PlayerAddTeamAccessCodeView(
                    groupCode: $groupCode,
                    onSubmit: {
                        onSubmit()
                    }
                )
                .presentationCornerRadius(20)
                .presentationDetents([.height(230)])
                .presentationBackgroundInteraction(.disabled)
                .interactiveDismissDisabled(true)
            }
        }
        .task {
            do {
                try await refreshData(for: selectedIndex)
            } catch {
                print("Error. Aborting... \(error)")
            }
        }
        .alert("Invalid access code entered", isPresented: $showErrorAccessCode) {
            Button("OK", role: .cancel) {
                showTextField = false  // Hide input field
            }
        }
        .alert("Error when trying to add team. Please try again later", isPresented: $showError) {
            Button("OK", role: .cancel) {
                showTextField = false  // Hide input field
            }
        }
    }
    
    @MainActor
    func refreshData(for index: Int) async throws {
        if index == 0 {
            print("Refreshing teams data")
            do {
                isLoadingMyTeams = true
                self.teams = try await teamModel.loadAllTeams()
                isLoadingMyTeams = false
            } catch {
                isLoadingMyTeams = false
                print("Error. Aborting... \(error)")
            }
        } else {
            do {
                isLoadingTeamRequests = true
                // Find all team requests for the player
                (self.invites, self.teamInvites) = try await inviteModel.getAllTeamInvites()
                isLoadingTeamRequests = false
            } catch UserError.userNotFound {
                // TODO: Take care of this throw error
            } catch InviteError.inviteNotFound {
                isLoadingTeamRequests = false
            } catch InviteError.teamInviteNotFound {
                isLoadingTeamRequests = false
            } catch {
                print("Error. Aborting... \(error)")
            }
        }
    }
    
    private func onSubmit() {
        Task {
            isSaving = true
            showTextField = false
            print("Submitted Code: \(groupCode)")
            hideKeyboard()
            
            do {
                // Validate the code
                let tmpTeam = try await teamModel.validateTeamAccessCode(accessCode: groupCode)

                // Add the player to the team
                guard let newTeam = try await teamModel.addingPlayerToTeam(team: tmpTeam) else {
                    print("Error when adding player to team")
                    return
                }

                let teamId = newTeam.teamId
                guard !teamId.isEmpty else {
                    throw NSError(domain: "JoinTeam", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "Missing team id"])
                }

                let auth = try dependencies.authenticationManager.getAuthenticatedUser()
                let uid = auth.uid
                guard !uid.isEmpty else { return }

                let playerDocId = try await playerTeamInfoModel.findPlayerDocId(playerId: uid)
                let teamInviteExists = try await inviteModel.doesTeamInviteExistsWithPlayerDocId(
                    playerDocId: playerDocId,
                    teamId: teamId
                )

                // If no invite existed → create player info entry
                if !teamInviteExists {
                    async let createTask = playerTeamInfoModel.createPlayerTeamInfo(
                        playerTeamInfoDTO: PlayerTeamInfoDTO(
                            id: teamId,
                            playerDocId: playerDocId,
                            nickname: nil,
                            jerseyNum: 0,
                            joinedAt: nil
                        )
                    )
                    _ = try await createTask
                }

                // UI Updates
                isSaving = false
                groupCode = ""

                if teams == nil {
                    teams = []
                }
                teams?.append(newTeam)

            } catch {
                print("Join team error: \(error)")
                isSaving = false
                groupCode = ""
                showErrorAccessCode = true
            }
        }
    }
}

#Preview {
    PlayerTeamsView()
}
