//
//  PlayerProfileView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/*** Player profile */
struct PlayerProfileView: View {
    @Binding var showLandingPageView: Bool
    @StateObject private var viewModel = PlayerProfileModel()

    @State private var isEditing = false // Edit the profile
    
    // Fields that can be updated by the user
    @State private var guardianName: String = "" // Bind to TextField
    @State private var guardianEmail: String = "" // Bind to TextField
    @State private var guardianPhone: String = "" // Bind to TextField
    @State private var jersey: Int = 0
    @State private var nickname: String = ""
    @State private var inputImage: UIImage?
    
    let genders = ["Female", "Male", "Other"]
    
    init( showLandingPageView: Binding<Bool>) {
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
                                    //                                    if let jerseyNum = player.jerseyNum {
                                    //Image(systemName: "\(String(jerseyNum)).circle").resizable().frame(width: 30, height: 30).foregroundStyle(.white).clipShape(Circle())
                                    //                                    }
                                    Text("# \((player.jerseyNum == -1) ? "TBD" : String(player.jerseyNum))").font(.subheadline)
                                    
                                }
                                
                                if let email = user.email {
                                    Text(email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                                }
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
                                        if let email = user.email {
                                            Text(email).foregroundStyle(.secondary)
                                        }
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
                                // Feedback section
                                Section (header: Text("Feedback")) {
                                    HStack (alignment: .center) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text("Key moment #2").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text("mm/dd/yyyy, hh:mm:ss").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    HStack (alignment: .center) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text("Key moment #1").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text("mm/dd/yyyy, hh:mm:ss").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                
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
                                    Button("Log out") {
                                        Task {
                                            do {
                                                try viewModel.logOut()
                                                showLandingPageView = true
                                            } catch {
                                                print(error)
                                            }
                                        }
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
                        Button(action: editInfo) {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
    }
    
    private func editInfo() {
        withAnimation {
            isEditing.toggle()
        }
    }
    
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
