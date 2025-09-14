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
    @State private var gender: String = "Mixed"
    
    /// Observable object that manages team data operations.
    @StateObject private var teamModel = TeamModel()
    
    @State private var removeTeam: Bool = false
    @Binding var dismissOnRemove: Bool
    
    var body: some View {
        // Navigation view that allows for navigation between views and displaying a toolbar.
        NavigationView {
            VStack {
                // Check if the team data is available and unwrap it.
                // Team Name Title
                if !isEditing {
//                    Text(team.name)
//                        .font(.largeTitle)
//                        .bold()
//                        .multilineTextAlignment(.leading)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 5)
//                        .padding(.bottom, 5)
//                        .padding(.horizontal)
//                        .foregroundColor(.primary)
                }
                
//                Divider()
                
                // List displaying the various team settings (nickname, age group, sport, gender, access code).
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
                    
                    Divider()
                    teamList.listStyle(.plain)
                } else {
                    teamList.listStyle(.insetGrouped)
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
                if userType == .coach {
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
//                        CustomUIFields.imageLabel(text: "Team Name", systemImage: "figure.indoor.soccer")
                        Text("Team Name")
                        Spacer()
                        TextField("Name", text: $name).foregroundColor(.primary).multilineTextAlignment(.trailing)
                    }
                }
                
                // Team Nickname
                HStack {
                    if isEditing {
                        Text("Nickname")
                        Spacer()
                        TextField("Nickname", text: $nickname).foregroundColor(.primary).multilineTextAlignment(.trailing)
                    } else {
                        CustomUIFields.imageLabel(text: "Nickname", systemImage: "person.2.fill")
                        Spacer()

                        Text(team.teamNickname)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Age Group
                HStack {
                    if isEditing {
                        Text("Age Group")
                        Spacer()
                        CustomPicker(
                            title: "",
                            options: AppData.ageGroupOptions,
                            displayText: { $0 },
                            selectedOption: $ageGroup
                        ).frame(height: 20)
                    } else {
                        CustomUIFields.imageLabel(text: "Age Group", systemImage: "calendar.and.person")
                        Spacer()
                        Text(team.ageGrp)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Sport
                HStack {
                    if isEditing {
                        Text("Sport").foregroundStyle(.secondary)
                    } else {
                        CustomUIFields.imageLabel(text: "Sport", systemImage: "soccerball")
                    }
                    Spacer()
                    Text(team.sport)
                        .foregroundColor(.secondary)
                }
                
                // Gender
                HStack {
                    if isEditing {
                        Text("Gender")
                        Spacer()
                        CustomPicker(
                            title: "",
                            options: AppData.genderOptions,
                            displayText: { $0 },
                            selectedOption: $gender
                        ).frame(height: 20)
                    } else {
                        CustomUIFields.imageLabel(text: "Gender", systemImage: "figure")
                        Spacer()
                        Text(team.gender.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Access Code with Copy Button & Tooltip
                if userType == .coach {
                    HStack {
                        if isEditing {
                            Text("Access Code").foregroundStyle(.secondary)
                        } else {
                            CustomUIFields.imageLabel(text: "Access Code", systemImage: "qrcode")
                        }
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
            }
            
            if isEditing {
                Section {
                    Button("Delete team") {
                        Task {
                            removeTeam.toggle()
                        }
                    }
                    .confirmationDialog(
                        "Are you sure you want to delete this team? All games and recordings will be permanently deleted.",
                        isPresented: $removeTeam,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive, action: {
                            withAnimation {
                                isEditing.toggle()
                            }
                            dismiss()
                            dismissOnRemove = true
                        }) {
                            Text("Delete")
                        }
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
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])

    TeamSettingsView(userType: .coach, team: team, dismissOnRemove: .constant(false))
}
