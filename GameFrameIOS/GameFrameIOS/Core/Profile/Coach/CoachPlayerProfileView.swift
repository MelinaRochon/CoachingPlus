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
    
    /// Array containing possible genders for the player.
    let genders = ["Female", "Male", "Other"]
    
    /// The view model responsible for handling the player's profile data.
    @StateObject private var profileModel = CoachProfileViewModel()
    
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
                        
                        Text("\(user.firstName) \(user.lastName)").font(.title)
                        if !isEditing {
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
                                        Text("Jersey #").foregroundStyle(.primary)
                                        Spacer()
                                        TextField("Jersey #", text: Binding(get: { String(jerseyNum)}, set: { val in
                                            // Convert String back to Int and update the player model
                                            if let newInt = Int(val) {
                                                jerseyNum = newInt
                                            }
                                        }))
                                        .multilineTextAlignment(.trailing)
                                    }
                                }
                                
                                HStack {
                                    Text("Nickname")
                                    Spacer()
                                    TextField("Nickname", text: $nickname).multilineTextAlignment(.trailing).disabled(!isEditing).foregroundStyle(isEditing ? .primary : .secondary)
                                }
                            }
                            
                            HStack {
                                Text("Date of birth")
                                Spacer()
                                Text("\(user.dateOfBirth?.formatted(.dateTime.year().month().day()) ?? "Unknown")")
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            if let player = profileModel.player {
                                HStack {
                                    Text("Gender")
                                    Spacer()
                                    Text(player.gender ?? "").foregroundStyle(.secondary)
                                }
                            }
                        }
                                                    
                        if ((guardianName != "") || (guardianEmail != "") || (guardianPhone != "")) {
                            
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
                        
                        // TODO: - Add the feedback section associated to the player
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
                        nickname = player.nickName ?? ""
                        jerseyNum = player.jerseyNum ?? 0
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
                            isEditing.toggle() // edit the player's profile
                        } label : {
                            Text("Edit")
                        }
                    } else {
                        Button {
                             // send the info to the database
                            Task {
                                do {
                                    profileModel.updatePlayerInformation(jersey: jerseyNum, nickname: nickname)
                                    print("Player updated")
                                } catch {
                                    print("Error when updating the player's information. \(error)")
                                }
                            }
                            isEditing.toggle() // edit the player's profile
                        } label : {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CoachPlayerProfileView(playerDocId: "", userDocId: "")
}
