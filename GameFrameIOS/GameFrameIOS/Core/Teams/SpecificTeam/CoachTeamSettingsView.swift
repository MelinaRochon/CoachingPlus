//
//  CoachTeamSettingsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI


/// A view that allows a coach to manage and review the settings of a specific team.
///
/// ## Features:
/// - Displays team information such as name, nickname, age group, sport, gender, and access code.
/// - Allows the coach to copy the team’s access code for sharing.
/// - Shows a list of players associated with the team.
/// - Provides a navigation toolbar with a "Done" button to dismiss the view.
struct CoachTeamSettingsView: View {
    
    /// Temporary storage for the list of players associated with the team.
    @State var players: [User_Status] = []
    
    /// Environment value to dismiss the current view and return to the previous screen.
    @Environment(\.dismiss) var dismiss

    /// Tracks whether the "Copied!" message should be displayed when the access code is copied.
    @State private var showCopiedMessage = false

    /// The team whose settings are being displayed.
    @State var team: DBTeam
    
    /// Tracks whether the view is currently in editing mode.
    @State private var isEditing = false
    
    /// Holds the team’s **name** while editing.
    @State private var name: String = ""
    
    /// Holds the team’s **nickname** while editing.
    @State private var nickname: String = ""
    
    /// Holds the team’s **age group** while editing.
    @State private var ageGroup: String = "None"
    
    /// Holds the team’s **gender** while editing.
    @State private var gender: String = "Mixed"
    
    /// Observable object that manages team data operations.
    @StateObject private var teamModel = TeamModel()
    
    var body: some View {
        // Navigation view that allows for navigation between views and displaying a toolbar.
        NavigationView {
            VStack {
                // Check if the team data is available and unwrap it.
                // Team Name Title
                if !isEditing {
                    Text(team.name)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                }
                
                Divider()
                
                // List displaying the various team settings (nickname, age group, sport, gender, access code).
                teamList.listStyle(.plain)
                
                // Show "Copied!" message
                if showCopiedMessage {
                    Text("Copied!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                        .padding(.top, 5)
                }
                
                Spacer()
            }
            .task {
                do {
                    nickname = team.teamNickname
                    ageGroup = team.ageGrp
                    gender = team.gender
                    name = team.name
                } catch {
                    print(error.localizedDescription)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !isEditing {
                        Button {
                            withAnimation {
                                isEditing = true
                            }
                        } label : {
                            Text("Edit")
                        }
                    } else {
                        Button {
                            withAnimation {
                                isEditing = false
                            }
                            
                            nickname = team.teamNickname
                            ageGroup = team.ageGrp
                            gender = team.gender
                            name = team.name
                        } label : {
                            Text("Cancel")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                    if !isEditing {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done").font(.subheadline)
                        }
                    } else {
                        Button {
                            savingTeamSettings()
                            withAnimation {
                                isEditing = false
                            }
                        } label : {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }

    
    /// A reusable computed view that displays the team’s settings and players in a `List`.
    ///
    /// ## Features:
    /// - **Team Settings section**:
    ///   - Displays the team’s name, nickname, age group, sport, gender, and access code.
    ///   - In **editing mode**, allows inline editing with `TextField` and `CustomPicker` components.
    ///   - Provides a copy button for the team’s access code with a temporary "Copied!" tooltip.
    ///
    /// - **Players section** (shown only when not editing):
    ///   - Lists all players associated with the team.
    ///   - If no players are available, displays a placeholder message.
    var teamList: some View {
        List {
            // Section Title
            Section(header: Text("Team Settings")) {
                // Team Name
                if isEditing {
                    HStack {
                        label(text: "Team Name", systemImage: "figure.indoor.soccer")
                        Spacer()
                        TextField("Name", text: $name).foregroundColor(.primary).multilineTextAlignment(.trailing)
                    }
                }
                
                // Team Nickname
                HStack {
                    label(text: "Nickname", systemImage: "person.2.fill")
                    Spacer()
                    if isEditing {
                        TextField("Nickname", text: $nickname).foregroundColor(.primary).multilineTextAlignment(.trailing)
                    } else {
                        Text(team.teamNickname)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Age Group
                HStack {
                    label(text: "Age Group", systemImage: "calendar.and.person")
                    Spacer()
                    if isEditing {
                        CustomPicker(
                            title: "",
                            options: AppData.ageGroupOptions,
                            displayText: { $0 },
                            selectedOption: $ageGroup
                        ).frame(height: 20)
                    } else {
                        Text(team.ageGrp)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Sport
                HStack {
                    label(text: "Sport", systemImage: "soccerball")
                    Spacer()
                    Text(team.sport)
                        .foregroundColor(.secondary)
                }
                
                // Gender
                HStack {
                    label(text: "Gender", systemImage: "figure")
                    Spacer()
                    if isEditing {
                        CustomPicker(
                            title: "",
                            options: AppData.genderOptions,
                            displayText: { $0 },
                            selectedOption: $gender
                        ).frame(height: 20)
                    } else {
                        Text(team.gender.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
                                            
                // Access Code with Copy Button & Tooltip
                HStack {
                    label(text: "Access Code", systemImage: "qrcode")
                    Spacer()
                    Text(team.accessCode ?? "N/A")
                        .foregroundColor(.secondary).padding(.trailing, 5)
                    
                    // Copy Button
                    Button(action: {
                        UIPasteboard.general.string = team.accessCode ?? ""
                        showCopiedMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopiedMessage = false
                        }
                    }) {
                        Image(systemName: "doc.on.doc.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !isEditing {
                Section(header: Text("Players")) {
                    if !players.isEmpty {
                        ForEach(players, id: \.playerDocId) { player in
                            label(text: "\(player.firstName) \(player.lastName)", systemImage: "person.circle")
                        }
                    } else {
                        Text("No players found.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    
    /// Saves the updated team settings to Firestore (or the data model).
    /// - Compares the current field values with the existing `team` object.
    /// - Only sends changed values to `updatingTeamSettings`, otherwise passes `nil`.
    /// - Updates the local `team` object so UI stays in sync.
    private func savingTeamSettings() {
        Task {
            do {
                var teamNickname: String? = nickname
                var teamAgeGrp : String? = ageGroup
                var teamGender : String? = gender
                var teamName : String? = name
                                
                if nickname == team.teamNickname {
                    teamNickname = nil
                } else {
                    team.teamNickname = nickname
                }
                
                if ageGroup == team.ageGrp {
                    teamAgeGrp = nil
                } else {
                    team.ageGrp = ageGroup
                }
                
                if gender == team.gender {
                    teamGender = nil
                } else {
                    team.gender = gender
                }
                
                if name == team.name {
                    teamName = nil
                } else {
                    team.name = name
                }
                
                try await teamModel.updatingTeamSettings(id: team.id, name: teamName, nickname: teamNickname, ageGrp: teamAgeGrp, gender: teamGender)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    /// A reusable SwiftUI view that displays a horizontal label with a red SF Symbol icon and text.
    ///
    /// - Parameters:
    ///   - text: The text to display next to the icon.
    ///   - systemImage: The name of the SF Symbol to use as the icon.
    ///
    /// - Returns: A `View` containing an `HStack` with a red icon and a label.
    @ViewBuilder
    private func label(text: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 25)
                .foregroundStyle(.red) // Red icon
            Text(text)
                .foregroundStyle(.primary) // Default text color
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    CoachTeamSettingsView(players: [], team: team)
}
