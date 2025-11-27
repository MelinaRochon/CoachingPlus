//
//  CoachTeamSettingsView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI
import GameFrameIOSShared

/// A view that allows a coach to manage and review the settings of a specific team.
///
/// ## Features:
/// - Displays team information such as name, nickname, age group, sport, gender, and access code.
/// - Allows the coach to copy the team’s access code for sharing.
/// - Shows a list of players associated with the team.
/// - Provides a navigation toolbar with a "Done" button to dismiss the view.
struct TeamSettingsView: View {
        
    @State var userType: UserType
        
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
    @State private var gender: String = "Select"
    
    /// Observable object that manages team data operations.
    @StateObject private var teamModel = TeamModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    @State private var removeTeam: Bool = false
    @Binding var dismissOnRemove: Bool
    
    var body: some View {
        // Navigation view that allows for navigation between views and displaying a toolbar.
        NavigationView {
            ScrollView {
                VStack {
                    // List displaying the various team settings (nickname, age group, sport, gender, access code).
                    if !isEditing {
                        Text(team.name)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)

                        teamList
                            .font(.callout)
                    } else {
                        teamDetails_editing
                            .font(.callout)
                    }
                    
                    // Show "Copied!" message
                    if showCopiedMessage {
                        Text("Copied!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .transition(.opacity)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal, 15)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        withAnimation {
                            isEditing = false
                        }
                        
                        nickname = team.teamNickname
                        ageGroup = team.ageGrp
                        gender = team.gender
                        name = team.name
                        dismiss()
                    }
                }
                
                if userType == .coach {
                    if isEditing {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save", systemImage: "checkmark") {
                                savingTeamSettings()
                                withAnimation {
                                    isEditing = false
                                }
                                dismiss()
                            }
                            .disabled(!saveTeamIfValid)
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                }
            }
            .onAppear {
                teamModel.setDependencies(dependencies)
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
        VStack {
            CustomUIFields.customDivider("Game Details")
                .padding(.top, 15)
            
            HStack {
                CustomUIFields.imageLabel(text: "Nickname", systemImage: "person.2.fill")
                Spacer()
                Text(team.teamNickname)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                CustomUIFields.imageLabel(text: "Age Group", systemImage: "calendar.and.person")
                Spacer()
                Text(team.ageGrp)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                CustomUIFields.imageLabel(text: "Sport", systemImage: "soccerball")
                Spacer()
                Text(team.sport)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                CustomUIFields.imageLabel(text: "Gender", systemImage: "figure")
                Spacer()
                Text(team.gender.capitalized)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            Divider()
            
            HStack {
                CustomUIFields.imageLabel(text: "Access Code", systemImage: "qrcode")
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
            .padding(.vertical, 5)
            
            Divider()
        }
    }
    
    var teamDetails_editing: some View {
        VStack {
            CustomUIFields.customDivider("Game Details")
                .padding(.top, 15)
            
            CustomTextField(label: "Team Name", text: $name, isRequired: true)
            CustomTextField(label: "Team Nickkname", text: $nickname, isRequired: true)
            CustomMenuDropdown(
                label: "Age group",
                placeholder: "Select an age group",
                onSelect: {
                    hideKeyboard()
                },
                options: AppData.ageGroupOptions,
                selectedOption: $ageGroup
            )
            
            
            CustomTextField(label: "Sport", text: $team.sport, disabled: true)
            
            CustomMenuDropdown(
                label: "Gender",
                placeholder: "Select a gender",
                onSelect: {
                    hideKeyboard()
                    
                },
                options: AppData.genderOptions,
                selectedOption: $gender
            )
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
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    TeamSettingsView(userType: .coach, team: team, dismissOnRemove: .constant(false))
}

extension TeamSettingsView {
    var saveTeamIfValid: Bool {
        return (name != team.name || nickname != team.teamNickname || gender != team.gender)
        && (!name.isEmpty && !nickname.isEmpty )
    }
}
