//
//  CoachPlayerProfileView.swift
//  GameFrameIOS
//  Coach views the player's profile!
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

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
 */struct CoachPlayerProfileView: View {
    // MARK: - State Properties
        
    /// Player document ID - used to fetch data for a specific player.
    @State var playerDocId: String = ""
    
    /// User document ID - used to fetch data for the associated user (coach).
    @State var userDocId: String = ""
    
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
     
    @State private var dob: Date = Date()
    @State private var gender: String = ""
     
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""

    
    // MARK: - View
    
    var body: some View {
        NavigationStack {
            VStack{
                if let user = profileModel.user {
                    VStack {
                        if !isEditing {
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
                            if let player = profileModel.player {
                                Text("# \(player.jerseyNum)").font(.subheadline)
                            }
                            Text(user.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                        }
                    }
                    
                    // Player information
                    List {
                        Section {
                            if let player = profileModel.player {
                                if isEditing {
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
                                    
                                    
                                }
                                HStack {
                                    Text("Date of birth")
                                    Spacer()
                                    if !isEditing {
                                        if user.dateOfBirth != nil {
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
                                    Text("Phone").foregroundStyle(.primary)
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
                        }
                        
                        Section {
                            if let player = profileModel.player {
                                HStack {
                                    Text("Nickname")
                                    Spacer()
                                    TextField("Nickname", text: $nickname).multilineTextAlignment(.trailing).disabled(!isEditing).foregroundStyle(isEditing ? .primary : .secondary)
                                }
                                
                                HStack {
                                    Text("Gender").foregroundStyle(!isEditing ? .primary : .secondary)
                                    Spacer()
//                                    if !isEditing {
                                        Text(gender).foregroundStyle(.secondary)
//                                    } else {
//                                        CustomPicker(
//                                            title: "",
//                                            options: AppData.genderOptions,
//                                            displayText: { $0 },
//                                            selectedOption: $gender
//                                        ).frame(height: 20)
//                                    }
                                }
                                
                                if isEditing {
                                    HStack {
                                        Text("Jersey #").foregroundStyle(.primary)
                                        Spacer()
                                        TextField("Jersey #", text: Binding(get: { String(jerseyNum)}, set: { val in
                                            // Convert String back to Int and update the player model
                                            if let newInt = Int(val) {
                                                jerseyNum = newInt
                                            }
                                        }))
                                        .multilineTextAlignment(.trailing)
                                        .disabled(!isEditing)
                                        .foregroundStyle(isEditing ? .primary : .secondary)
                                    }
                                }
                            }
                        }
                            
                                                    
                        if isEditing {
                            Section (header: Text("Guardian Information")) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    TextField("Name", text: $guardianName).multilineTextAlignment(.trailing).disabled(!isEditing).foregroundStyle(isEditing ? .primary : .secondary)
                                }

                                HStack {
                                    Text("Email")
                                    Spacer()
                                    TextField("Email", text: $guardianEmail).multilineTextAlignment(.trailing).disabled(!isEditing).foregroundStyle(isEditing ? .primary : .secondary)
                                }

                                HStack {
                                    Text("Phone")
                                    Spacer()
                                    TextField("Phone", text: $guardianPhone).multilineTextAlignment(.trailing).disabled(!isEditing).foregroundStyle(isEditing ? .primary : .secondary)
                                }
                            }
                        } else if !isEditing && ((guardianName != "") || (guardianEmail != "") || (guardianPhone != "")) {
                            Section (header: Text("Guardian Information")) {
                                if guardianName != "" {
                                    HStack {
                                        Text("Name")
                                        Spacer()
                                        
                                        Text(guardianName).foregroundStyle(.secondary)
                                    }
                                }
                                
                                if guardianEmail != "" {
                                    HStack {
                                        Text("Email")
                                        Spacer()
                                        Text(guardianEmail).foregroundStyle(.secondary)
                                    }
                                }
                                
                                if guardianPhone != "" {
                                    HStack {
                                        Text("Phone")
                                        Spacer()
                                        Text(guardianPhone).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        if isEditing {
                            Button("Cancel") {
                                Task {
                                    do {
                                        try await profileModel.loadPlayer(userDocId: userDocId, playerDocId: playerDocId) // get the player's information
                                        if let player = profileModel.player {
                                            guardianName = player.guardianName ?? ""
                                            guardianEmail = player.guardianEmail ?? ""
                                            guardianPhone = player.guardianPhone ?? ""
                                            nickname = player.nickName ?? ""
                                            jerseyNum = player.jerseyNum
                                            gender = player.gender ?? ""
                                        }
                                        if let user = profileModel.user {
                                            firstName = user.firstName
                                            lastName = user.lastName
                                            dob = user.dateOfBirth ?? Date()
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
                        
                        // TODO: - Add the feedback section associated to the player
                        
//                        Section {
//                            Button(role: .destructive) {
//                                removePlayer.toggle()
//                            } label: {
//                                Text("Remove player")
//                            }
//                        }
                    }
                }
            }
            .alert("Removing Player", isPresented: $removePlayer) {
//                Button("Cancel") {
//                    // Nothing...
//                }
                
                Button(role: .destructive) {
                    
                } label: {
                    Text("Remove")
                }
            } message: {
                Text("Are you sure you want to remove this player from the team? This action cannot be undone.")
            }
            .task {
                do {
                    try await profileModel.loadPlayer(userDocId: userDocId, playerDocId: playerDocId) // get the player's information
                    if let player = profileModel.player {
                        guardianName = player.guardianName ?? ""
                        guardianEmail = player.guardianEmail ?? ""
                        guardianPhone = player.guardianPhone ?? ""
                        nickname = player.nickName ?? ""
                        jerseyNum = player.jerseyNum
                        gender = player.gender ?? ""
                    }
                    if let user = profileModel.user {
                        firstName = user.firstName
                        lastName = user.lastName
                        dob = user.dateOfBirth ?? Date()
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
                    } else {
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
                    }
                }
            }
        }
    }
     
     private func savingPlayerInformation() {
         Task {
             if let player = profileModel.player {
                 var playerJersey: Int? = jerseyNum
                 var playerNickname: String? = nickname
                 var playerGuardianName: String? = guardianName
                 var playerGuardianEmail: String? = guardianEmail
                 var playerGuardianPhone: String? = guardianPhone
                 var playerGender: String? = gender
                 
                 if jerseyNum == player.jerseyNum {
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
                 
                 playerModel.updatePlayerSettings(id: player.id, jersey: playerJersey, nickname: playerNickname, guardianName: playerGuardianName, guardianEmail: playerGuardianEmail, guardianPhone: playerGuardianPhone, gender: playerGender)
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
                     
                     if dob == user.dateOfBirth {
                         userDateOfBirth = nil
                     } else {
                         user.dateOfBirth = dob
                     }
                     
                     if phone == user.phone {
                         userPhone = nil
                     } else {
                         user.phone = phone
                     }
                     
                     try await userModel.updateUserSettings(id: user.id, dateOfBirth: userDateOfBirth, firstName: userFirstName, lastName: userLastName, phone: userPhone)
                 }
             } catch {
                 print(error.localizedDescription)
             }
         }
     }
}

#Preview {
    CoachPlayerProfileView(playerDocId: "", userDocId: "")
}
