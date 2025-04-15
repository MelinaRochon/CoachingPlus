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
    
    /// Boolean flag to toggle between viewing and editing the profile
    @State private var isEditing = false // Edit the profile
    
    /// State properties to hold editable user information
    @State private var guardianName: String = "" // Name of the guardian (editable)
    @State private var guardianEmail: String = "" // Guardian's email (editable)
    @State private var guardianPhone: String = "" // Guardian's phone (editable)
    @State private var jersey: Int = 0 // Player's jersey number (editable)
    @State private var nickname: String = "" // Player's nickname (editable)
    @State private var inputImage: UIImage? // Image for the player profile (not yet implemented)
    
    /// Gender options for the player
    let genders = ["Female", "Male", "Other"]
    
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
                                Text("\(user.firstName) \(user.lastName)").font(.title)
                                if let player = viewModel.player {
                                    Text("# \((player.jerseyNum == -1) ? "TBD" : String(player.jerseyNum))").font(.subheadline)
                                }
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
                                        Text("Name").foregroundStyle(.secondary)
                                        Spacer()
                                        Text("\(user.firstName) \(user.lastName)").multilineTextAlignment(.trailing).foregroundStyle(.secondary)
                                    }
                                    
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
                                    
                                    HStack {
                                        Text("Email").foregroundStyle(.secondary)
                                        Spacer()
                                        Text(user.email).foregroundStyle(.secondary)
                                    }
                                }
                                
                                HStack {
                                    Text("Nickname").foregroundStyle(isEditing ? .primary : .secondary)
                                    Spacer()
                                    TextField("", text: $nickname).disabled(!isEditing)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundStyle(isEditing ? .primary : .secondary)
                                }
                                
                                HStack {
                                    Text("Date of birth").foregroundStyle(.secondary)
                                    Spacer()
                                    if let dateOfBirth = user.dateOfBirth {
                                        Text("\(dateOfBirth.formatted(.dateTime.year().month(.twoDigits).day()))")
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                                
                                HStack {
                                    Text("Gender").foregroundStyle(.secondary)
                                    Spacer()
                                    if let player = viewModel.player {
                                        Text(player.gender ?? "Unknown").foregroundStyle(.secondary)
                                    }
                                }.disabled(!isEditing)
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
                                            }.tint(.red)
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
                                            }.tint(.red)
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
                                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                viewModel.removeGuardianPhone()
                                                guardianPhone = ""
                                                
                                            } label: {
                                                Image(systemName: "trash")
                                            }.tint(.red)
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
                                    }.foregroundStyle(.red)
                                    
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
                                        Text("Log out").foregroundStyle(.red)
                                    }                                    
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
                    }
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isEditing {
                        Button(action: editInfo) {
                            Text("Edit").foregroundStyle(.red)
                        }
                        
                    } else {
                        Button(action: saveInfo) {
                            Text("Save").foregroundStyle(.red)
                        }
                    }
                }
                
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: editInfo) {
                            Text("Cancel").foregroundStyle(.red)
                        }
                    }
                }
            }
        }
    }
    
    
    /// Toggle editing mode
    private func editInfo() {
        withAnimation {
            isEditing.toggle()
        }
    }
    
    
    /// Save updated player information
    private func saveInfo() {
        withAnimation {
            isEditing.toggle()
            viewModel.updatePlayerInformation(jersey: jersey, nickname: nickname, guardianName: guardianName, guardianEmail: guardianEmail, guardianPhone: guardianPhone)
        }
    }
    
}

#Preview {
    PlayerProfileView(showLandingPageView: .constant(false))
}
