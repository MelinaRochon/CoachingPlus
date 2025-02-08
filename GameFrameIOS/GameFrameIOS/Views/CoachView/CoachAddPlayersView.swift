//
//  CoachAddPlayersView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import SwiftUI

struct CoachAddPlayersView: View {
    @Environment(\.dismiss) var dismiss // Go back to the create Team view
    @State var player: Player
    let genders = ["Female", "Male", "Other"]
    //@Environment(\.modelContext) private var modelContext
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: player.dob)!
        let max = Calendar.current.date(byAdding: .year, value: 1, to: player.dob)!
            return min...max
        }
    
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Adding a Player").font(.title3).bold().padding(.bottom)
                Form {
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Name", text: $player.name).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        
                        DatePicker(selection: $player.dob, in: dateRange, displayedComponents: .date) {
                            Text("Date of birth")
                        }
                        
                        HStack {
                            Text("Jersey #")
                            Spacer()
                            // Will need to make this only for int -> make sure it doesn't allow + or -
                            TextField("Jersey", value: $player.jersey, format: .number).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.numberPad)
                        }
                    }
                    
                    Section {
                        Picker("Gender", selection: $player.gender)
                        {
                            ForEach(genders.indices, id: \.self) {i in
                                Text(self.genders[i])
                            }
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            TextField("Email address", text: $player.email).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Guardian Name", text: $player.guardianName).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            TextField("Guardian Email", text: $player.guardianEmail).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.emailAddress)
                        }
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            TextField("XXX-XXX-XXXX", text: $player.guardianPhone).foregroundStyle(.secondary).multilineTextAlignment(.trailing).keyboardType(.phonePad)
                        }
                    }
                }
                
                
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                                    Button(action: {
                                        dismiss() // Dismiss the full-screen cover
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                            Text("Back")
                                        }
                                    }
                                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        //modelContext.insert(player)
                        // Player's state is added to database
                        // Go back to the Creating new team page -> new player should be shown in the list
                    }
                }
            }
        }
        
        
    }
}

#Preview {
    CoachAddPlayersView(player: .init(name: "Melina Rochon", dob: Date(), jersey: 34, gender: 1, email: "moch072@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))
}
