//
//  PlayerProfileView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/**
  This file defines the `PlayerProfileView` SwiftUI view, which is responsible for displaying
  and editing the player's profile information in the "GameFrameIOS" application. It allows
  users (coaches or players) to view and modify various details about a player's profile, such as:

  - Name and nickname
  - Jersey number
  - Guardian information (name, email, phone)
  - Date of birth and gender
  - Profile picture (optional)

  The view includes functionality for:
  - Viewing the player's current information in a non-editable format
  - Switching to an editable mode where the user can modify certain fields
  - Saving or canceling changes
  - Logging out and resetting the password

  The view uses a `PlayerProfileModel` view model to handle the business logic, data fetching,
  and updating player information. It also supports conditional sections for displaying feedback,
  and allows for managing user interactions via the toolbar for saving or editing information.

  The view is integrated with the app's navigation system, providing a seamless user experience for
  managing player profiles.
*/
struct PlayerProfileView: View {
    
    /// A binding to control whether the landing page should be displayed
    @Binding var showLandingPageView: Bool
    
    /// ViewModel to handle the player data and operations
    @StateObject private var viewModel = PlayerProfileModel()
    @StateObject private var userModel = UserModel()
    
    /// Boolean flag to toggle between viewing and editing the profile
    @State private var isEditing = false // Edit the profile
    
    /// State properties to hold editable user information
    @State private var guardianName: String = "" // Name of the guardian (editable)
    @State private var guardianEmail: String = "" // Guardian's email (editable)
    @State private var guardianPhone: String = "" // Guardian's phone (editable)
    @State private var jersey: Int = 0 // Player's jersey number (editable)
    @State private var nickname: String = "" // Player's nickname (editable)
    @State private var inputImage: UIImage? // Image for the player profile (not yet implemented)
    
    @State private var dob: Date?
    @State private var todayDate: Date = Date()
    
    @State private var gender: String = "Select"

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @EnvironmentObject private var dependencies: DependencyContainer
    @State private var teamId: String?

        
    /// Initializer to bind the showLandingPageView state
    init(showLandingPageView: Binding<Bool>) {
        self._showLandingPageView = showLandingPageView
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    if let user = viewModel.user {
                        VStack {
                            Image(systemName: "person.crop.circle").resizable().frame(width: 80, height: 80).foregroundStyle(.gray)
                                .clipShape(Circle())
                                .clipped()
                                .overlay(){
                                    ZStack{
                                        // border
                                        RoundedRectangle(cornerRadius: 100).stroke(.white, lineWidth: 4)
                                    }
                                }
                            
                            // The player is not editing its profile
                            if !isEditing {
                                Text("\(firstName) \(lastName)").font(.title)
                                    .accessibilityIdentifier("page.player.profile.name")
                                Text(user.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                            }
                            
                        }
                        .frame(maxWidth: .infinity) // Ensures full width for better alignment
                        
                        // Player information
                        List {
                            Section {
                                // Show email, name and player number if the user is editing
                                // Here you bind the `viewModel.player.jerseyNum` directly
                                if isEditing {
                                    HStack {
                                        Text("First Name")
                                        TextField("First Name", text: $firstName).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                                    }
                                    HStack {
                                        Text("Last Name").foregroundStyle(.primary)
                                        Spacer()
                                        TextField("Last Name", text: $lastName).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                                    }
                                    
                                    HStack {
                                        Text("Email").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(user.email).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                                    }
                                }
                                
                                if !isEditing {
                                    if let dateOfBirth = user.dateOfBirth {
                                        HStack {
                                            Text("Date of birth").foregroundStyle(.secondary)
                                            Spacer()
                                            Text(dateOfBirth, formatter: {
                                                let f = DateFormatter()
                                                f.dateFormat = "MMM dd, yyyy"
                                                return f
                                            }())
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                        }
                                    }
                                } else {
                                    HStack {
                                        Text("Date of birth").foregroundStyle(.primary)
                                        Spacer()
                                        DatePicker(
                                            "",
                                            selection: Binding(
                                                get: { dob ?? todayDate },
                                                set: { dob = $0 }
                                            ),
                                            in: ...todayDate,
                                            displayedComponents: .date
                                        )
                                        .labelsHidden()
                                        .frame(height: 20)
                                    }
                                }
                                
                                if !phone.isEmpty && !isEditing {
                                    HStack {
                                        Text("Phone").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(phone)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                } else if isEditing {
                                    HStack {
                                        Text("Phone").foregroundStyle(.primary)
                                        Spacer()
                                        TextField("(XXX)-XXX-XXXX", text: $phone)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.trailing)
                                            .autocapitalization(.none)
                                            .autocorrectionDisabled(true)
                                            .keyboardType(.phonePad)
                                            .onChange(of: phone) { newVal in
                                                phone = formatPhoneNumber(newVal)
                                            }
                                    }
                                }
                            }
                            
                            Section {
//                                HStack {
//                                    Text("Nickname").foregroundStyle(isEditing ? .primary : .secondary)
//                                    Spacer()
//                                    TextField("Nickname", text: $nickname).disabled(!isEditing)
//                                        .multilineTextAlignment(.trailing)
//                                        .foregroundStyle(isEditing ? .primary : .secondary)
//                                }
                                    
                                if gender != "Select" && !isEditing {
                                    HStack {
                                        Text("Gender").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(gender).foregroundStyle(.secondary)
                                    }
                                } else if isEditing {
                                    HStack {
                                        Text("Gender").foregroundStyle(.primary)
                                        Spacer()
                                        CustomPicker(
                                            title: "",
                                            options: AppData.userGenderOptions,
                                            displayText: { $0 },
                                            selectedOption: $gender
                                        ).frame(height: 20)
                                    }
                                }
                            }
                            
                            if (((guardianName != "") || (guardianEmail != "") || (guardianPhone != "")) || isEditing) {
                                Section (header: Text("Guardian Information")) {
                                    if ((guardianName != "") || isEditing) {
                                        HStack {
                                            Text("Name").foregroundStyle(isEditing ? .primary : .secondary)
                                            Spacer()
                                            TextField("Name", text: $guardianName)
                                                .disabled(!isEditing)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundStyle(isEditing ? .primary : .secondary)
                                        }
                                    }
                                    
                                    if ((guardianEmail != "") || isEditing) {
                                        HStack {
                                            Text("Email").foregroundStyle(isEditing ? .primary : .secondary)
                                            Spacer()
                                            TextField("Email", text: $guardianEmail)
                                                .disabled(!isEditing)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundStyle(isEditing ? .primary : .secondary)
                                        }
                                    }
                                    
                                    if ((guardianPhone != "") || isEditing) {
                                        HStack {
                                            Text("Phone").foregroundStyle(isEditing ? .primary : .secondary)
                                            Spacer()
                                            TextField("Phone", text: $guardianPhone)
                                                .disabled(!isEditing)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundStyle(isEditing ? .primary : .secondary)
                                                .autocapitalization(.none)
                                                .autocorrectionDisabled(true)
                                                .keyboardType(.phonePad)
                                                .onChange(of: guardianPhone) { newVal in
                                                    guardianPhone = formatPhoneNumber(newVal)
                                                }
                                        }
                                    }
                                }
                            }
                            
                            if !isEditing {
                                // TODO: - Add the feedback section of feedback associated to the player
                                
                                Section {
                                    // Reset password button
                                    Button("Reset password") {
                                        Task {
                                            do {
                                                try await viewModel.resetPassword()
                                                print("Password reset")
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                    
                                    // Logout button
                                    Button{
                                        Task {
                                            do {
                                                try viewModel.logOut()
                                                showLandingPageView = true
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    } label: {
                                        Text("Log out")
                                    }
                                    .accessibilityIdentifier("page.profile.player.logout")
                                }
                            }
                        }
                        .frame(minHeight: 800) // Ensure the list has enough height
                    }
                }.task {
                    print("Loading current user...")
                    try? await viewModel.loadCurrentPlayer()
                    
                    // Set the player's values - to edit
                    if let player = viewModel.player {
                        guardianName = player.guardianName ?? ""
                        guardianEmail = player.guardianEmail ?? ""
                        guardianPhone = player.guardianPhone ?? ""
//                        jersey = player.jerseyNum
//                        nickname = player.nickName ?? ""
                        if let playerGender = player.gender, !playerGender.isEmpty {
                            gender = playerGender
                        } else {
                            gender = "Select"
                        }
                        print("player = \(player)")
                    }
                    
                    if let playerTeamInfo = viewModel.playerTeamInfo {
                        jersey = playerTeamInfo.jerseyNum ?? 0
                        nickname = playerTeamInfo.nickName ?? ""
                    }
                    
                    if let user = viewModel.user {
                        firstName = user.firstName
                        lastName = user.lastName
                        dob = user.dateOfBirth // ?? Date()
                        phone = user.phone ?? ""
                        print("user = \(user)")
                    }
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isEditing {
                        Button(action: editInfo) {
                            Text("Edit")
                        }
                        
                    } else {
                        Button(action: saveInfo) {
                            Text("Save")
                        }
                        .disabled(!saveProfileIsValid)
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: cancelInfo) {
                            Text("Cancel")
                        }
                    }
                }
            }
            .onAppear {
                userModel.setDependencies(dependencies)
                viewModel.setDependencies(dependencies)
                
//                Task {
//                    do {
//                        teamId = try await viewModel.getTeamId(teamDocId: teamDocId)
//                        
//                    } catch TeamError.teamNotFound {
//                        // TODO: Manage error
//                        return
//                    }
//                }
            }
        }
        .accessibilityIdentifier("page.player.profile")
    }
    
    
    /// Toggle editing mode
    private func editInfo() {
        withAnimation {
            isEditing.toggle()
        }
    }
    
    /// Toggles the editing mode on and off and removes all unsaved data
    private func cancelInfo() {
        withAnimation {
            isEditing.toggle()
        }
        
        Task {
            try? await viewModel.loadCurrentPlayer()
            
            // Remove unsaved data
            if let player = viewModel.player {
                if let userPhone = player.guardianPhone {
                    guardianPhone = userPhone
                }
//                jersey = player.jerseyNum
//                nickname = player.nickName ?? ""
                guardianName = player.guardianName ?? ""
                guardianEmail = player.guardianEmail ?? ""
                if let playerGender = player.gender, !playerGender.isEmpty {
                    gender = playerGender
                } else {
                    gender = "Select"
                }
            }
            
            if let playerTeamInfo = viewModel.playerTeamInfo {
                jersey = playerTeamInfo.jerseyNum ?? 0
                nickname = playerTeamInfo.nickName ?? ""
            }
            
            if let user = viewModel.user {
                firstName = user.firstName
                lastName = user.lastName
                dob = user.dateOfBirth // ?? Date()
                phone = user.phone ?? ""
            }
        }
    }
    
    /// Save updated player information
    private func saveInfo() {
        Task {
            savingUserSettings()
            savingPlayerInformation()
            
            print("gender is: \(gender), gender in pllayer is: \(viewModel.player?.gender ?? "")")
            withAnimation {
                isEditing.toggle()
            }
        }

    }
    
    private func savingPlayerInformation() {
        Task {
            if let player = viewModel.player, let playerTeamInfo = viewModel.playerTeamInfo, let teamId = teamId {
                var playerJersey: Int? = jersey
                var playerNickname: String? = nickname
                var playerGuardianName: String? = guardianName
                var playerGuardianEmail: String? = guardianEmail
                var playerGuardianPhone: String? = guardianPhone
                var playerGender: String? = gender
                                
                if jersey == playerTeamInfo.jerseyNum {
                    playerJersey = nil
                }
                
                if nickname == playerTeamInfo.nickName {
                    playerNickname = nil
                }
                
                viewModel.updatePlayerTeamInfoSettings(
                    playerDocId: player.id,
                    teamId: teamId,
                    jersey: playerJersey,
                    nickname: playerNickname
                )

                if guardianName == player.guardianName {
                    playerGuardianName = nil
                }
                
                if guardianEmail == player.guardianEmail {
                    playerGuardianEmail = nil
                }
                
                if guardianPhone == player.guardianPhone {
                    playerGuardianPhone = nil
                }
                
                if gender == player.gender {
                    playerGender = nil
                }
                
                viewModel.updatePlayerSettings(
                    id: player.id,
//                    jersey: playerJersey,
//                    nickname: playerNickname,
                    guardianName: playerGuardianName,
                    guardianEmail: playerGuardianEmail,
                    guardianPhone: playerGuardianPhone,
                    gender: playerGender
                )
                
            } else {
                print("tyheres nbo player")
            }
        }
    }
    
    private func savingUserSettings() {
        Task {
            do {
                if var user = viewModel.user {
                    var userFirstName: String? = firstName
                    var userLastName: String? = lastName
                    var userDateOfBirth: Date? = dob
                    var userPhone: String? = phone
                    
                    if firstName == user.firstName {
                        userFirstName = nil
                    }
                    
                    if lastName == user.lastName {
                       userLastName = nil
                    }
                    
                    if let newDOB = dob {
                        if Calendar.current.isDateInToday(newDOB) || newDOB == user.dateOfBirth {
                            userDateOfBirth = nil
                            dob = user.dateOfBirth
                        } else {
                            user.dateOfBirth = newDOB
                        }
                    } else {
                        userDateOfBirth = nil
                    }
                    
                    if phone == user.phone {
                        userPhone = nil
                    }
                    
                    try await userModel.updateUserSettings(id: user.id, dateOfBirth: userDateOfBirth, firstName: userFirstName, lastName: userLastName, phone: userPhone)
                    
                    user.firstName = firstName
                    user.lastName = lastName
                    user.dateOfBirth = dob
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

#Preview {
    PlayerProfileView(showLandingPageView: .constant(false))
}


extension PlayerProfileView: UserEditProfileProtocol {
    var saveProfileIsValid: Bool {
        var isDobToday: Bool = true
        if let dob = dob, !Calendar.current.isDateInToday(dob) {
            isDobToday = false
        }

        if let user = viewModel.user, let player = viewModel.player, let playerTeamInfo = viewModel.playerTeamInfo {
            return (user.firstName != firstName || user.lastName != lastName)
            && (!firstName.isEmpty && isValidName(firstName))
            && (!lastName.isEmpty && isValidName(lastName))
            || (player.gender != gender && gender != "Select")
            || (user.dateOfBirth != dob && dob != nil && isDobToday != true)
            || (user.phone != phone && ((user.phone?.isEmpty) != nil)  && isValidPhoneNumber(phone))
            || (player.guardianName != guardianName && (guardianName != "" || ((player.guardianName?.isEmpty) != nil)))
            || (player.guardianPhone != guardianPhone && ((guardianPhone != "" || (player.guardianPhone?.isEmpty) != nil)) && isValidPhoneNumber(guardianPhone))
            || (player.guardianEmail != guardianEmail && ((guardianEmail != "" || (player.guardianEmail?.isEmpty) != nil)) && isValidEmail(guardianEmail))
//            || (player.nickName != nickname && ((player.nickName?.isEmpty) != nil))
            || (playerTeamInfo.nickName != nickname && ((playerTeamInfo.nickName?.isEmpty) != nil))

        }
        return false
    }
}
