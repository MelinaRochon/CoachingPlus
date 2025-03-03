//
//  PlayerProfileView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

@MainActor
final class PlayerProfileViewModel: ObservableObject {
    
    /** To log out the user */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    /** To reset the user's password **/
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // TO DO - Create error
        }
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await AuthenticationManager.shared.resetPassword(email: email) // NEED TO VERIFY USER GETS EMAIL
    }
}
/*** Player profile */
struct PlayerProfileView: View {
    @Binding var showLandingPageView: Bool
    @StateObject private var viewModel = PlayerProfileViewModel()
    
    @Binding var player: Player
    let genders = ["Female", "Male", "Other"]
    init(player: Binding<Player>, showLandingPageView: Binding<Bool>) {
        self._player = player
        self._showLandingPageView = showLandingPageView
    }
    
    var body: some View {
        NavigationStack {
            
            VStack{
                // Header
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
                        
                    Text(player.name).font(.title)
                    Text("# \(player.jersey)").font(.subheadline)
                    Text(player.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                    
                }
                
                // Player information
                List {
                    Section {
                        HStack {
                            Text("Date of birth")
                            Spacer()
                            Text("\(player.dob.formatted(.dateTime.year().month(.twoDigits).day()))").foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Gender")
                            Spacer()
                            switch player.gender {
                                case 0: Text("Female").foregroundStyle(.secondary)
                                case 1: Text("Male").foregroundStyle(.secondary)
                                case 2: Text("Other").foregroundStyle(.secondary)
                                default: Text("Unknown").foregroundStyle(.secondary)
                            }
                        }.disabled(true)
                        
                        
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(player.guardianName).foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(player.guardianEmail).foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(player.guardianPhone).foregroundStyle(.secondary)
                        }.disabled(true)
                       
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
            
        }
    }
}

#Preview {
    PlayerProfileView(player: .constant(.init(name: "Mel Rochon", dob: Date(), jersey: 34, gender: 0, email: "mroch@uottawa.ca", profilePicture: nil, guardianName: "Jane Doe", guardianEmail: "jane@g.com", guardianPhone: "613-098-9999")), showLandingPageView: .constant(false))
}
