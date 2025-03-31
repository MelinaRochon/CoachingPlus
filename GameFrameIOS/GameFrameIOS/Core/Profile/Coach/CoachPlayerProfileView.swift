//
//  CoachPlayerProfileView.swift
//  GameFrameIOS
//  Coach views the player's profile!
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/*** Player profile */
struct CoachPlayerProfileView: View {
    //@State var playerId: String = "";
    @State var playerDocId: String = ""
    @State var userDocId: String = ""
    
    @State private var guardianName: String = "" // Bind to TextField
    @State private var guardianEmail: String = "" // Bind to TextField
    @State private var guardianPhone: String = "" // Bind to TextField
    @State private var nickname: String = ""
    @State private var jerseyNum: Int = 0
    
    @State private var isEditing: Bool = false
    
    let genders = ["Female", "Male", "Other"]
    
    @StateObject private var profileModel = CoachProfileViewModel()
    
    var body: some View {
        NavigationStack {
            
            VStack{
                
                
                // profile picture
                /*if let selectedImage = inputImage {
                 Image(uiImage: selectedImage).profileImageStyle()
                 } else {
                 profile.defaultProfilePicture
                 .profileImageStyle()
                 .onTapGesture {
                 showImagePicker = true
                 }
                 //.onChange(of: inputImage) {_ in loadImage()}
                 .sheet(isPresented: $showImagePicker) {
                 ImagePicker(image: $inputImage)
                 }
                 }*/
                
                // Header
                
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
                            //.disabled(true)
                            if let player = profileModel.player {
                                HStack {
                                    Text("Gender")
                                    Spacer()
                                    Text(player.gender ?? "").foregroundStyle(.secondary)
                                }
                            }
                            //.disabled(true)
                            
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
