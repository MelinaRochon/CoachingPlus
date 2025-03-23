//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI

struct CoachAddPlayersView: View {
    
    @StateObject private var viewModel = AddPlayersViewModel() // view Model to load the data 
    @State var teamId: String
    @Environment(\.dismiss) var dismiss // Go back to the create Team view

    let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("First name", text: $viewModel.firstName).foregroundStyle(.secondary) //.multilineTextAlignment(.trailing)
                        TextField("Last name", text: $viewModel.lastName).foregroundStyle(.secondary) //.multilineTextAlignment(.trailing)
                    }
                    
                    Section(footer: Text("The invite will be sent to this email address.")) {
                        TextField("Email address", text: $viewModel.email).foregroundStyle(.secondary).multilineTextAlignment(.leading).textContentType(.emailAddress).keyboardType(.emailAddress).autocapitalization(.none)
                    }
                    
                    Section (header: Text("Optional Player Information")) {
                        TextField("Player Nickname", text: $viewModel.nickname).foregroundStyle(.secondary) //.multilineTextAlignment(.trailing)
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
                        TextField("Guardian Phone", text: $viewModel.guardianPhone).foregroundStyle(.secondary).multilineTextAlignment(.leading).keyboardType(.phonePad).textContentType(.telephoneNumber)
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
                    }
                }
            }
        }
    }
    
    func formatPhoneNumber(_ number: String) -> String {
        // Keep only digits
        let digits = number.filter { $0.isNumber }
        
        var result = ""
        let mask = "(XXX)-XXX-XXXX"
        var index = digits.startIndex

        for ch in mask where index < digits.endIndex {
            if ch == "X" {
                result.append(digits[index])
                index = digits.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

#Preview {
    CoachAddPlayersView(teamId: "")
}
