//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI

/**
 This file contains the `CoachAddPlayersView` structure, which provides a form for coaches to add a new player to a team.
 The view allows coaches to input essential player information such as first name, last name, email, nickname, jersey number,
 and guardian details like name, email, and phone number.

 The form also validates inputs and ensures that certain fields, such as the player's name and email, are filled in
 before the "Add" button is enabled. Upon submission, the player is added to the team, and the view is dismissed.
 
 This file also contains a utility function to format phone numbers as they are entered by the user.
*/
struct CoachAddPlayersView: View {
    
    // ViewModel to manage the data and logic related to adding players
    @StateObject private var viewModel = AddPlayersViewModel() // view Model to load the data
    
    // Team ID passed to the view, needed for adding the player to the correct team
    @State var teamId: String
    @Environment(\.dismiss) var dismiss // Go back to the create Team view

    let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("First name", text: $viewModel.firstName).foregroundStyle(.secondary)
                        TextField("Last name", text: $viewModel.lastName).foregroundStyle(.secondary)
                    }
                    
                    Section(footer: Text("The invite will be sent to this email address.")) {
                        TextField("Email address", text: $viewModel.email).foregroundStyle(.secondary).multilineTextAlignment(.leading).textContentType(.emailAddress).keyboardType(.emailAddress).autocapitalization(.none)
                    }
                    
                    Section (header: Text("Optional Player Information")) {
                        TextField("Player Nickname", text: $viewModel.nickname).foregroundStyle(.secondary)
                        HStack {
                            Text("Jersey #")
                            Spacer()
                            // Will need to make this only for int -> make sure it doesn't allow + or -
                            TextField("Jersey", value: $viewModel.jersey, format: .number).foregroundStyle(.primary).multilineTextAlignment(.trailing).keyboardType(.numberPad)
                        }
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        TextField("Guardian Name", text: $viewModel.guardianName).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        TextField("Guardian Email", text: $viewModel.guardianEmail).foregroundStyle(.secondary).multilineTextAlignment(.leading).keyboardType(.emailAddress).textContentType(.emailAddress)
                        TextField("Guardian Phone", text: $viewModel.guardianPhone).foregroundStyle(.secondary).multilineTextAlignment(.leading).keyboardType(.phonePad).textContentType(.telephoneNumber).onChange(of: viewModel.guardianPhone) { newVal in
                            viewModel.guardianPhone = formatPhoneNumber(newVal)
                        }
                    }
                }
                
            }
            .navigationTitle(Text("Adding a New Player")).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        HStack {
                            Text("Cancel")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        Task {
                            do {
                                let canDismiss = try await viewModel.addPlayerToTeam(teamId: teamId) // to add player
                                if canDismiss {
                                    dismiss() // Dismiss the full-screen cover
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }.disabled(viewModel.firstName == "" || viewModel.lastName == "" || viewModel.email == "" || !viewModel.email.contains("@"))
                }
            }
        }
    }
}

#Preview {
    CoachAddPlayersView(teamId: "")
}
