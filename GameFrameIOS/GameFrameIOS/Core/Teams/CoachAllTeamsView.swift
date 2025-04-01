//
//  CoachAllTeamsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI


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

    // Holds the list of teams that the coach is managing. This is fetched asynchronously.
    @State private var teams: [DBTeam]?

    // A boolean flag that controls the visibility of the "Create Team" view. When true, the Create Team sheet is presented.
    @State private var showCreateTeam: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: HStack {
                        Text("My Teams") // Section header text
                        Spacer() // Push the button to the right
                        Button{
                            showCreateTeam.toggle()
                        } label: {
                            Text("Add +")
                        }
                    }) {
                        if let teams = teams {
                            if !teams.isEmpty {
                                ForEach(teams, id: \.name) { team in
                                    NavigationLink(destination: CoachMyTeamView(selectedTeam: team))
                                    {
                                        HStack {
                                            Image(systemName: "tshirt") // TODO: Will need to change the team's logo in the future
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
            }
            .navigationTitle(Text("Teams"))
            .task {
                do {
                    self.teams = try await teamModel.loadAllTeams()
                    
                } catch {
                    print("Error. Aborting... \(error)")
                }
            }
            
        }
        .sheet(isPresented: $showCreateTeam, onDismiss: refreshTeams) {
            CoachCreateTeamView()
        }
        
    }
    
    /// Function to refresh the list of teams after creating a new team
    private func refreshTeams() {
        Task {
            do {
                // Reload the list of teams after creating a new one
                self.teams = try await teamModel.loadAllTeams()
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
