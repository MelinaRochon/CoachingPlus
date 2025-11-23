//
//  CoachPlayerProfileView.swift
//  GameFrameIOS
//  Coach views the player's profile!
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import GameFrameIOSShared

/**
 This view represents a coach's interface for viewing and editing a player's profile.

 The `CoachPlayerProfileView` allows the coach to view detailed information about a player's profile,
 including their name, nickname, jersey number, gender, date of birth, and guardian information (if available).
 The coach can toggle between viewing the player's profile and editing specific information, such as the nickname
 and jersey number.

 ## Key Features:
 - **Profile Picture**: Displays a default system image if the player does not have a custom profile image.
 - **Personal Information**: Shows the player's name, email, jersey number, and other personal details (birthdate, gender).
 - **Guardian Information**: Displays the player's guardian name, email, and phone number, if provided.
 - **Feedback Section**: Shows a list of game-related feedback (e.g., key moments from games) with placeholders for the actual data.
 - **Edit Mode**: The coach can toggle between view mode and edit mode. In edit mode, fields like the nickname and jersey number can be modified.
 
 ## Fetching Data:
 - The player profile data is asynchronously loaded when the view appears, using the `.task` modifier.
 - The `profileModel.loadPlayer()` function fetches the player's profile and updates the UI with the latest data.
 - If the coach updates the player's nickname or jersey number, the changes are sent back to the database using the `profileModel.updatePlayerInformation()` function.

 ## Usage:
 - The `CoachPlayerProfileView` is typically used in a coach's section of the app, allowing them to view and modify player details.
 - It is designed to be navigated within a `NavigationStack` and can be integrated into the app's navigation hierarchy.
 */
struct CoachPlayerProfileView: View {
    // MARK: - State Properties
        
    /// Player document ID - used to fetch data for a specific player.
    @State var playerDocId: String = ""
    
    /// User document ID - used to fetch data for the associated user (coach).
    @State var userDocId: String = ""
    
    @State var teamDocId: String
    
    /// Guardian details are bound to the respective TextFields, so the user can view/edit them.
    @State private var guardianName: String = "" // Guardian's name
    @State private var guardianEmail: String = "" // Guardian's email
    @State private var guardianPhone: String = "" // Guardian's phone number
    
    /// Player profile details such as nickname and jersey number.
    @State private var nickname: String = "" // Nickname of the player
    @State private var jerseyNum: Int = 0 // Jersey number of the player
    
    /// State variable to track whether the profile is being edited.
    @State private var isEditing: Bool = false
     
    /// State variable to track whether the player profile is being removed.
    @State private var removePlayer: Bool = false
        
    /// The view model responsible for handling the player's profile data.
    @StateObject private var profileModel = CoachProfileViewModel()
    @StateObject private var playerModel = PlayerProfileModel()
    @StateObject private var userModel = UserModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    @State private var dob: Date?

    @State private var gender: String = ""
     
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
     
    @State private var dismissOnRemove: Bool = false
     
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            VStack{
                if let user = profileModel.user {
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
                        
                        Text("\(firstName) \(lastName)").font(.title)
                        if let playerTeamInfo = profileModel.playerTeamInfo {
                            Text("# \(playerTeamInfo.jerseyNum)").font(.subheadline)
                        }
                        Text(user.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                    }
                    
                    // Player information
                    List {
                        Section {
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
                            if !phone.isEmpty {
                                
                                HStack {
                                    Text("Phone").foregroundStyle(.secondary)
                                    Spacer()
                                    Text(phone).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Text("Nickname").foregroundStyle(.secondary)
                                Spacer()
                                TextField("Nickname", text: $nickname).multilineTextAlignment(.trailing).foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Gender").foregroundStyle(.secondary)
                                Spacer()
                                Text(gender).foregroundStyle(.secondary)
                            }
                        }
                        
                        if ((guardianName != "") || (guardianEmail != "") || (guardianPhone != "")) {
                            Section (header: Text("Guardian Information")) {
                                if guardianName != "" {
                                    HStack {
                                        Text("Name").foregroundStyle(.secondary)
                                        Spacer()
                                        
                                        Text(guardianName).foregroundStyle(.secondary)
                                    }
                                }
                                
                                if guardianEmail != "" {
                                    HStack {
                                        Text("Email").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(guardianEmail).foregroundStyle(.secondary)
                                    }
                                }
                                
                                if guardianPhone != "" {
                                    HStack {
                                        Text("Phone").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(guardianPhone).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        // TODO: - Add the feedback section associated to the player
                        
                    }
                }
            }
            .alert("Removing Player", isPresented: $removePlayer) {
                Button(role: .destructive) {
                    
                } label: {
                    Text("Remove")
                }
            } message: {
                Text("Are you sure you want to remove this player from the team? This action cannot be undone.")
            }
            
            .fullScreenCover(isPresented: $isEditing) {
                CoachEditPlayerProfileView(
                    profileModel: profileModel,
                    playerDocId: playerDocId,
                    userDocId: userDocId,
                    dob: $dob,
                    gender: $gender,
                    firstName: $firstName,
                    lastName: $lastName,
                    phone: $phone,
                    guardianName: $guardianName,
                    guardianEmail: $guardianEmail,
                    guardianPhone: $guardianPhone,
                    jerseyNum: $jerseyNum,
                    nickname: $nickname,
                    isEditing: $isEditing,
                    teamDocId: teamDocId,
                    dismissOnRemove: $dismissOnRemove
                )
            }
            .onChange(of: dismissOnRemove) { newValue in
                Task {
                    do {
                        try await profileModel.removePlayer(teamDocId: teamDocId)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try await profileModel.loadPlayer(userDocId: userDocId, playerDocId: playerDocId) // get the player's information
                    if let player = profileModel.player {
                        guardianName = player.guardianName ?? ""
                        guardianEmail = player.guardianEmail ?? ""
                        guardianPhone = player.guardianPhone ?? ""
                        gender = player.gender ?? ""
                    }
                    if let playerTeamInfo = profileModel.playerTeamInfo {
                        nickname = playerTeamInfo.nickName ?? ""
                        jerseyNum = playerTeamInfo.jerseyNum
                    }
                    if let user = profileModel.user {
                        firstName = user.firstName
                        lastName = user.lastName
                        dob = user.dateOfBirth
                        phone = user.phone ?? ""
                    }

                } catch {
                    print("Error when loading player. \(error)")
                }
            }
            .toolbar {
                // Edit button
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isEditing {
                        Button {
                            withAnimation {
                                isEditing.toggle()
                            } // edit the player's profile
                        } label : {
                            Text("Edit")
                        }
                    }
                }
            }
            .onAppear {
                profileModel.setDependencies(dependencies)
                userModel.setDependencies(dependencies)
                playerModel.setDependencies(dependencies)
            }
        }
    }
     
     
}


struct CoachEditPlayerProfileView: View {
    
    @ObservedObject var profileModel: CoachProfileViewModel
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Player document ID - used to fetch data for a specific player.
    @State var playerDocId: String
    
    /// User document ID - used to fetch data for the associated user (coach).
    @State var userDocId: String
    
    @Binding var dob: Date?
    @Binding var gender: String
     
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var phone: String

    @Binding var guardianName: String // Guardian's name
    @Binding var guardianEmail: String // Guardian's email
    @Binding var guardianPhone: String // Guardian's phone number
    @Binding var jerseyNum: Int // Guardian's phone number

    /// Player profile details such as nickname and jersey number.
    @Binding var nickname: String // Nickname of the player
    @State private var todayDate: Date = Date()
    
    /// State variable to track whether the profile is being edited.
    @Binding var isEditing: Bool
    
    @State var teamDocId: String
    
    @State private var removePlayerFromTeam: Bool = false
    
    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @Binding var dismissOnRemove: Bool
    
    @State private var teamId: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = profileModel.user {
                    List {
                        Section {
                            HStack {
                                Text("First Name").foregroundStyle(.primary)
                                Spacer()
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
                                Text(user.email).foregroundStyle(.secondary).disabled(true).multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("Date of birth")
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
                        
                        Section {
                            HStack {
                                Text("Nickname")
                                Spacer()
                                TextField("Nickname", text: $nickname).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                            }
                            
                            HStack {
                                Text("Gender").foregroundStyle(.secondary)
                                Spacer()
                                Text(gender).foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Jersey #").foregroundStyle(.primary)
                                Spacer()
                                TextField("0", text: Binding(get: { String(jerseyNum)}, set: { val in
                                    // Convert String back to Int and update the player model
                                    if let newInt = Int(val) {
                                        jerseyNum = newInt
                                    }
                                }))
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.primary)
                                .keyboardType(.numberPad)
                            }
                        }
                        
                        Section (header: Text("Guardian Information")) {
                            HStack {
                                Text("Name")
                                Spacer()
                                TextField("Name", text: $guardianName).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                            }
                            
                            HStack {
                                Text("Email")
                                Spacer()
                                TextField("Email", text: $guardianEmail)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundStyle(.primary)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            HStack {
                                Text("Phone")
                                Spacer()
                                TextField("(XXX)-XXX-XXXX", text: $guardianPhone)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.trailing)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.phonePad)
                                    .onChange(of: guardianPhone) { newVal in
                                        guardianPhone = formatPhoneNumber(newVal)
                                    }
                            }
                        }
                        
                        Section {
                            Button("Remove player") {
                                Task {
                                    removePlayerFromTeam.toggle()
                                }
                            }
                            .confirmationDialog(
                                "Are you sure you want to remove this player from the team?",
                                isPresented: $removePlayerFromTeam,
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
            .toolbar {
                // Edit button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        Task {
                            do {
                                try await profileModel.loadPlayer(userDocId: userDocId, playerDocId: playerDocId) // get the player's information
                                if let player = profileModel.player {
                                    guardianName = player.guardianName ?? ""
                                    guardianEmail = player.guardianEmail ?? ""
                                    guardianPhone = player.guardianPhone ?? ""
                                    gender = player.gender ?? ""
                                }
                                if let playerTeamInfo = profileModel.playerTeamInfo {
                                    nickname = playerTeamInfo.nickName ?? ""
                                    jerseyNum = playerTeamInfo.jerseyNum
                                }
                                if let user = profileModel.user {
                                    firstName = user.firstName
                                    lastName = user.lastName
                                    dob = user.dateOfBirth
                                    phone = user.phone ?? ""
                                }
                                
                            } catch {
                                print("Error when loading player. \(error)")
                            }
                        }
                        withAnimation {
                            isEditing.toggle()
                        } // edit the player's profile
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // send the info to the database
                        Task {
                            savingUserSettings()
                            savingPlayerInformation()
                        }
                        withAnimation {
                            isEditing.toggle()
                        } // edit the player's profile
                    } label : {
                        Text("Save")
                    }
                    .disabled(!saveProfileIsValid)
                }
            }
            .onAppear {
                profileModel.setDependencies(dependencies)
                
                Task {
                    do {
                        teamId = try await profileModel.getTeamId(teamDocId: teamDocId)
                    } catch TeamError.teamNotFound {
                        // TODO: Manage error
                        return
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func savingPlayerInformation() {
        Task {
            if let player = profileModel.player, let playerTeamInfo = profileModel.playerTeamInfo, let teamId = teamId {
                var playerJersey: Int? = jerseyNum
                var playerNickname: String? = nickname
                var playerGuardianName: String? = guardianName
                var playerGuardianEmail: String? = guardianEmail
                var playerGuardianPhone: String? = guardianPhone
                var playerGender: String? = gender
                
                if jerseyNum == playerTeamInfo.jerseyNum {
                    playerJersey = nil
                }
                
                if nickname == playerTeamInfo.nickName {
                    playerNickname = nil
                }
                
                profileModel.updatePlayerTeamInfoSettings(
                    playerDocId: player.id,
                    teamId: teamId,
                    jersey: playerJersey,
                    nickname: playerNickname
                )
                
                if guardianName == player.guardianName {
                    playerGuardianName = nil
                }
                
                print("guardianEmail == \(guardianEmail)")
                if guardianEmail == player.guardianEmail {
                    playerGuardianEmail = nil
                }
                
                if guardianPhone == player.guardianPhone {
                    playerGuardianPhone = nil
                }
                
                if gender == player.gender {
                    playerGender = nil
                }
  
                profileModel.updatePlayerSettings(
                    id: player.id,
                    guardianName: playerGuardianName,
                    guardianEmail: playerGuardianEmail,
                    guardianPhone: playerGuardianPhone,
                    gender: playerGender
                )
            }
        }
    }
    
    private func savingUserSettings() {
        Task {
            do {
                if var user = profileModel.user {
                    var userFirstName: String? = firstName
                    var userLastName: String? = lastName
                    var userDateOfBirth: Date? = dob
                    var userPhone: String? = phone
                    
                    if firstName == user.firstName {
                        userFirstName = nil
                    } else {
                        user.firstName = firstName
                    }
                    
                    if lastName == user.lastName {
                       userLastName = nil
                    } else {
                        user.lastName = lastName
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
                    } else {
                        user.phone = phone
                    }
                    
                    try await profileModel.updateUserSettings(
                        id: user.id,
                        dateOfBirth: userDateOfBirth,
                        firstName: userFirstName,
                        lastName: userLastName,
                        phone: userPhone
                    )
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    CoachPlayerProfileView(playerDocId: "", userDocId: "", teamDocId: "")
}


extension CoachEditPlayerProfileView: UserEditProfileProtocol {
    var saveProfileIsValid: Bool {
        var isDobToday: Bool = true
        if let dob = dob, !Calendar.current.isDateInToday(dob) {
            isDobToday = false
        }
        
        if let user = profileModel.user, let player = profileModel.player, let playerTeamInfo = profileModel.playerTeamInfo {
            return (user.firstName != firstName || user.lastName != lastName)
            && (!firstName.isEmpty && isValidName(firstName))
            && (!lastName.isEmpty && isValidName(lastName))
            || (user.dateOfBirth != dob && dob != nil && isDobToday != true)
            || (user.phone != phone && ((user.phone?.isEmpty) != nil)  && isValidPhoneNumber(phone))
            || (player.guardianName != guardianName && (guardianName != "" || ((player.guardianName?.isEmpty) != nil)))
            || (player.guardianPhone != guardianPhone && ((guardianPhone != "" || (player.guardianPhone?.isEmpty) != nil)) && isValidPhoneNumber(guardianPhone))
            || (player.guardianEmail != guardianEmail && ((guardianEmail != "" || (player.guardianEmail?.isEmpty) != nil)) && isValidEmail(guardianEmail))
            || (playerTeamInfo.jerseyNum != jerseyNum)
            || (playerTeamInfo.nickName != nickname && ((playerTeamInfo.nickName?.isEmpty) != nil))
        }
        return false
    }
}
