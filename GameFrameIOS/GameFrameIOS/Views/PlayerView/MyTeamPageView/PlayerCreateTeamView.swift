//
//  PlayerCreateTeamView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI
import SFSymbolsPicker
import SwiftData

/***
 This structure is the 'Create a New Team' form. It is called when the used is on the All Teams page and wants to add a new team to their list.
 The coach can add players.
 
 Note: This form is only accessible to the coach.
 */
struct PlayerCreateTeamView: View {
    @State var team: Team
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    //@State var player: Player
    //@Query private var players: [Player]
    //@Environment(\.modelContext) private var modelContext
    
    let sports = ["Soccer", "Hockey", "Basketball"]
    let genders = ["Female", "Male", "Other"]
    let ageGroupes = ["U3", "U4", "U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15", "U16", "U17", "U18", "18+", "Senior"]
    @State private var icon = ""
    @State private var logoIsPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Creating a New Team").font(.title3).bold().padding(.bottom)
                
                Form {
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Team Name", text: $team.name).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Picker("Sport", selection: $team.sport)
                            {
                                ForEach(sports.indices, id: \.self) {i in
                                    Text(self.sports[i])
                                }
                            }
                        }
                        HStack {
                            Text("Logo")
                            Spacer()
                            
                            Button(action: { logoIsPresented.toggle()}) {
                                Text("Choose").contentShape(Rectangle())
                            }.sheet(isPresented: $logoIsPresented, content: {
                                SymbolsPicker(selection: $team.icon, title: "Choose your team's logo", autoDismiss: true) {
                                    Image(systemName: "xmark.diamond.fill")
                                }
                            })
                            
                            Image(systemName: team.icon).foregroundStyle(team.color)
                        }
                        HStack {
                            ColorPicker("Color", selection: $team.color)
                        }
                    }
                    
                    Section {
                        Picker("Gender", selection: $team.gender)
                        {
                            ForEach(genders.indices, id: \.self) {i in
                                Text(self.genders[i])
                            }
                        }
                        HStack {
                            Picker("Age group", selection: $team.ageGrp)
                            {
                                ForEach(ageGroupes, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                    }
                                        
                    Section(header:
                        HStack {
                            Text("Adding Players").font(.headline).bold()
                            Spacer()
                        NavigationLink(destination: CoachAddPlayersView(player: .init(name: "Melina Rochon", dob: Date(), jersey: 34, gender: 1, email: "moch072@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))) {
                                
                                 // Open create new team form
                                Text("Add +")
                            }
                    }){
                        Text("John Dow")
                        /*List {
                            ForEach(players) { player in
                                NavigationLink {
                                    Text("Item at")
                                } label: {
                                    Text(player.name)
                                }
                            }
                        }*/
                    }
                    /** Check if the list is scrollable!! Make sure it is. */
                    
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
                    Button(action: { /* Action will need to be added -> complete team form */}) {
                        Text("Create")
                    }
                }
            }
                
        }
    }
}

#Preview {
    PlayerCreateTeamView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "U10", players: ""))
}
