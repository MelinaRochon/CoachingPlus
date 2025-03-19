//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI

struct CoachAddPlayersView: View {
    
    @StateObject private var viewModel = AddPlayersViewModel()
    @State var teamId: String
    @Environment(\.dismiss) var dismiss // Go back to the create Team view
//    @State var player: Player
    let genders = ["Female", "Male", "Other"]
    //@Binding var path = NavigationPath // Stores the navigation history
    //@Environment(\.modelContext) private var modelContext
    
//    var dateRange: ClosedRange<Date> {
//        let min = Calendar.current.date(byAdding: .year, value: -1, to: player.dob)!
//        let max = Calendar.current.date(byAdding: .year, value: 1, to: player.dob)!
//            return min...max
//        }
    
    var body: some View {
        
        NavigationView {
            VStack {
                //Text("Adding a Player").font(.title3).bold().padding(.bottom)
                Form {
                    Section {
                        HStack {
                            Text("First name")
                            Spacer()
                            TextField("First name", text: $viewModel.firstName).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Last name")
                            Spacer()
                            TextField("Last name", text: $viewModel.lastName).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                    }
                    Section {
//                        DatePicker(selection: $player.dob, in: dateRange, displayedComponents: .date) {
//                            Text("Date of birth")
//                        }
                        
                        HStack {
                            Text("Jersey #")
                            Spacer()
                            // Will need to make this only for int -> make sure it doesn't allow + or -
                            TextField("Jersey", value: $viewModel.jersey, format: .number).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Nickname")
                            Spacer()
                            TextField("Nickname", text: $viewModel.nickname).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Section(footer: Text("The invite will be sent to this email address.")) {
                        HStack {
                            Text("Email")
                            Spacer()
                            TextField("Email address", text: $viewModel.email).foregroundStyle(.secondary).multilineTextAlignment(.trailing).textContentType(.emailAddress).keyboardType(.emailAddress).autocapitalization(.none)
                        }
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Guardian Name", text: $viewModel.guardianName).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            TextField("Guardian Email", text: $viewModel.guardianEmail).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.emailAddress).textContentType(.emailAddress)
                        }
                        
                        HStack {
                            Text("Phone")
                            Spacer()
//                            TextField("XXX-XXX-XXXX", text: Binding (get: {$viewModel.guardianPhone}, set: { val in $viewModel.guardianPhone = formatPhoneNumber(val)})).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.phonePad)
                            TextField("XXX-XXX-XXXX", text: $viewModel.guardianPhone).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.phonePad).textContentType(.telephoneNumber)
                        }
                    }
                }
                
            }.navigationTitle(Text("Adding a New Player")).navigationBarTitleDisplayMode(.inline)
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
                        // create player!
                        Task {
                            do {
                                try await viewModel.addPlayerToTeam(teamId: teamId) // to add player
                                //showSignInView = false
                                //return
                                dismiss() // Dismiss the full-screen cover
                            } catch {
                                print(error)
                            }
                        }
                        //modelContext.insert(player)
                        // Player's state is added to database
                        // Go back to the Creating new team page -> new player should be shown in the list
                    }
                }
            }
        }
//        .navigationBarBackButtonHidden(true)
        
        
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
//    player: .init(name: "Melina Rochon", dob: Date(), jersey: 34, gender: 1, email: "moch072@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))
}
