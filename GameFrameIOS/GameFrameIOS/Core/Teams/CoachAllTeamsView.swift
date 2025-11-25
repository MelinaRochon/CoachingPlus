//
//  CoachAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared


/// `CoachAllTeamsView` is a SwiftUI view that displays a list of all teams that a coach manages. It allows the coach to:
/// - View the list of teams they are associated with.
/// - Navigate to a detailed view of each team (via `CoachMyTeamView`).
/// - Create a new team by tapping the "Add +" button, which opens a modal sheet for creating a new team.
///
/// ### Key Features:
/// 1. **List of Teams**: Displays a list of all teams the coach is managing, fetched asynchronously via the `TeamModel`.
///    - If there are no teams, it shows a message: "No teams found."
/// 2. **Create Team**: The coach can create a new team by tapping the "Add +" button in the navigation bar. This opens a sheet (`CoachCreateTeamView`) for team creation.
/// 3. **Team Navigation**: Each team in the list is clickable. Tapping a team navigates to the `CoachMyTeamView`, where the coach can view or edit team details.
/// 4. **Data Handling**: The list of teams is fetched asynchronously on view load using the `teamModel.loadAllTeams()` method, and the view is refreshed after creating a new team.
///
/// ### Data Flow:
/// - The `teams` state variable holds the list of teams fetched asynchronously when the view appears.
/// - A `Button` allows the coach to toggle the visibility of a sheet to create a new team. Upon dismissal, the team list is refreshed.
///
/// ### Use Case:
/// - This view is typically used in the profile section of a coach's dashboard, allowing them to manage their teams in an organized manner.
/// - Coaches can manage multiple teams and quickly navigate to a specific team's details.
struct CoachAllTeamsView: View {
    
    // A view model for managing and loading teams data.
    @StateObject private var teamModel = TeamModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Holds the list of teams that the coach is managing. This is fetched asynchronously.
    @State private var teams: [DBTeam]?

    /// A boolean flag that controls the visibility of the "Create Team" view. When true, the Create Team sheet is presented.
    @State private var showCreateTeam: Bool = false
    
    @State private var isLoadingMyTeams: Bool = false

    
    var body: some View {
        NavigationStack {
//            ScrollView {
                //            VStack(alignment: .leading, spacing: 4) {
                //                Text("Teams").font(Font.largeTitle.bold())
//                                Divider() // This adds a divider after the title
//                                    .padding(.bottom, 30)
                //            }
                //            .padding(.top, 0)
                
                VStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Teams").font(Font.largeTitle.bold()).padding(.horizontal, 15)
                        Divider()
                    }

//                    Divider() // This adds a divider after the title
                        .padding(.bottom, 30)
                    CustomListSection(
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
                        noItemsFoundSubtitle: "Try adding a team or try again later.",
                        destinationBuilder: { team in
                            CoachMyTeamView(selectedTeam: team)
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
                    Spacer()
//                }
                //            .toolbarBackground(.visible, for: .navigationBar)
                //            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            }
//            .navigationTitle(Text("Teams"))
//            .navigationBarTitleDisplayMode(.automatic)
//            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateTeam.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("page.coach.teams.add")
                }
            }
            .task {
                do {
                    isLoadingMyTeams = true
                    self.teams = try await teamModel.loadAllTeams()
                    isLoadingMyTeams = false
                    
                } catch {
                    isLoadingMyTeams = false
                    print("Error. Aborting... \(error)")
                }
            }
            .onAppear {
                teamModel.setDependencies(dependencies)
            }
        }
        .sheet(isPresented: $showCreateTeam, onDismiss: refreshTeams) {
            CoachCreateTeamView()

        }
        .accessibilityIdentifier("page.coach.teams")
    }
    
    /// Function to refresh the list of teams after creating a new team
    private func refreshTeams() {
        Task {
            do {
                isLoadingMyTeams = true
                // Reload the list of teams after creating a new one
                self.teams = try await teamModel.loadAllTeams()
                isLoadingMyTeams = false
            } catch {
                // Print an error message if the refresh fails
                print("Error occured when refreshing teams. Aborting... \(error)")
            }
        }
    }
}

#Preview {
    CoachAllTeamsView()
}
