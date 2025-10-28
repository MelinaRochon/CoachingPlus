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
    
    @State private var dob: Date = Date()
    @State private var gender: String = ""
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @EnvironmentObject private var dependencies: DependencyContainer

        
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
                                    Text("# \((jersey == -1) ? "TBD" : String(jersey))").font(.subheadline)
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
                                
                                HStack {
                                    Text("Date of birth").foregroundStyle(isEditing ? .primary : .secondary)
                                    Spacer()
                                    if !isEditing {
                                        if let dateOfBirth = user.dateOfBirth {
                                            Text("\(dob.formatted(.dateTime.year().month(.twoDigits).day()))")
                                                .foregroundStyle(.secondary)
                                                .multilineTextAlignment(.trailing)
                                        } else {
                                            Text("N/A").foregroundStyle(.secondary)
                                                .multilineTextAlignment(.trailing)
                                        }
                                    } else {
                                        DatePicker(
                                            "",
                                            selection: $dob,
                                            in: ...Date(),
                                            displayedComponents: .date
                                        )
                                        .labelsHidden()
                                        .frame(height: 20)
                                    }
                                }
                                
                                HStack {
                                    Text("Phone").foregroundStyle(.secondary)
                                    Spacer()
                                    TextField("(XXX)-XXX-XXXX", text: $phone).disabled(!isEditing)
                                        .foregroundStyle(isEditing ? .primary : .secondary)
                                        .multilineTextAlignment(.trailing)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled(true)
                                        .keyboardType(.phonePad)
                                        .onChange(of: phone) { newVal in
                                            phone = formatPhoneNumber(newVal)
                                        }
                                }
                            }
                            
                            Section {
                                HStack {
                                    Text("Nickname").foregroundStyle(isEditing ? .primary : .secondary)
                                    Spacer()
                                    TextField("", text: $nickname).disabled(!isEditing)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(isEditing ? .primary : .secondary)
                                }
                                
                                HStack {
                                    Text("Gender").foregroundStyle(isEditing ? .primary : .secondary)
                                    Spacer()
                                    if !isEditing {
                                        Text(gender ?? "" ).foregroundStyle(.secondary)
                                    } else {
                                        CustomPicker(
                                            title: "",
                                            options: AppData.genderOptions,
                                            displayText: { $0 },
                                            selectedOption: $gender
                                        ).frame(height: 20)
                                    }
                                }
                                
                                if isEditing {
                                    
                                    HStack {
                                        Text("Jersey #").foregroundStyle(isEditing ? .primary : .secondary)
                                        Spacer()
                                        TextField("Jersey #", text: Binding(get: { String(jersey)}, set: { val in
                                            // Convert String back to Int and update the player model
                                            if let newInt = Int(val) {
                                                jersey = newInt
                                            }
                                        }))
                                        .multilineTextAlignment(.trailing)
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
                                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                viewModel.removeGuardianName()
                                                guardianName = "" // reset the guardian name
                                            } label: {
                                                Image(systemName: "trash")
                                            }
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
                                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                viewModel.removeGuardianEmail()
                                                guardianEmail = ""
                                            } label: {
                                                Image(systemName: "trash")
                                            }
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
                                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                viewModel.removeGuardianPhone()
                                                guardianPhone = ""
                                                
                                            } label: {
                                                Image(systemName: "trash")
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
                        jersey = player.jerseyNum
                        nickname = player.nickName ?? ""
                        gender = player.gender ?? "Other"
                    }
                    
                    if let user = viewModel.user {
                        firstName = user.firstName
                        lastName = user.lastName
                        dob = user.dateOfBirth ?? Date()
                        phone = user.phone ?? ""
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
                jersey = player.jerseyNum
                nickname = player.nickName ?? ""
                guardianName = player.guardianName ?? ""
                guardianEmail = player.guardianEmail ?? ""
                gender = player.gender ?? "Other"
            }
            
            if let user = viewModel.user {
                firstName = user.firstName
                lastName = user.lastName
                dob = user.dateOfBirth ?? Date()
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
            if let player = viewModel.player {
                var playerJersey: Int? = jersey
                var playerNickname: String? = nickname
                var playerGuardianName: String? = guardianName
                var playerGuardianEmail: String? = guardianEmail
                var playerGuardianPhone: String? = guardianPhone
                var playerGender: String? = gender
                
                if jersey == player.jerseyNum {
                    playerJersey = nil
                }
                
                if nickname == player.nickName {
                    playerNickname = nil
                }
                
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
                
                viewModel.updatePlayerSettings(id: player.id, jersey: playerJersey, nickname: playerNickname, guardianName: playerGuardianName, guardianEmail: playerGuardianEmail, guardianPhone: playerGuardianPhone, gender: playerGender)
                
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
                    
                    if dob == user.dateOfBirth {
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
