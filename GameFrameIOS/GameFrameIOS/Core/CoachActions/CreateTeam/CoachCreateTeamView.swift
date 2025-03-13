//
//  CoachCreateTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import SFSymbolsPicker
import SwiftData

/***
 This structure is the 'Create a New Team' form. It is called when the used is on the All Teams page and wants to add a new team to their list.
 The coach can add players.
 
 Note: This form is only accessible to the coach.
 */
struct CoachCreateTeamView: View {
    //@State var team: Team
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    //@State var player: Player
    //@Query private var players: [Player]
    //@Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CreateTeamViewModel()
    
    //    let auth: AuthDataResultModel  // Pass the authenticated user
    let sportOptions = ["Soccer", "Hockey", "Basketball"]
    let genderOptions = ["Female", "Male", "Mixed", "Other"]
    let ageGroupOptions = ["U3", "U4", "U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15", "U16", "U17", "U18", "18+", "Senior", "None"]
    
    @State private var icon = ""
    @State private var logoIsPresented = false
    @State private var selectedSportLabel = "Soccer"
    @State private var selectedGenderLabel = "Mixed"
    @State private var selectedAgeGroupLabel = "None"

    var body: some View {
        NavigationView {
            VStack {
                Text("Creating a New Team").font(.title3).bold().padding(.bottom)
                
                Form {
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Team Name", text: $viewModel.name).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Picker("Sport", selection: $selectedSportLabel)
                            {
                                ForEach(sportOptions, id: \.self) {sport in
                                    Text(sport).tag(sport)
                                }
                            }
                        }
                        HStack {
                            Text("Logo")
                            Spacer()
                            
                            //                                                        Button(action: { logoIsPresented.toggle()}) {
                            //                                                            Text("Choose").contentShape(Rectangle())
                            //                                                        }.sheet(isPresented: $logoIsPresented, content: {
                            //                                                            SymbolsPicker(selection: $viewModel.icon, title: "Choose your team's logo", autoDismiss: true) {
                            //                                                                Image(systemName: "xmark.diamond.fill")
                            //                                                            }
                            //                                                        })
                            //
                            //                                                        Image(systemName: viewModel.logoURL)//.foregroundStyle(team.color)
                            //                                                    }
                            HStack {
                                ColorPicker("Team Colour", selection: Binding(
                                    get: { viewModel.colour },
                                    set: { newColor in
                                        DispatchQueue.main.async {
                                            viewModel.updateColour(from: newColor)
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                        }
                        
                        Section {
                            Picker("Gender", selection: $selectedGenderLabel)
                            {
                                ForEach(genderOptions, id: \.self) {gender in
                                    Text(gender).tag(gender)
                                }
                            }
                            HStack {
                                Picker("Age group", selection: $selectedAgeGroupLabel)
                                {
                                    ForEach(ageGroupOptions, id: \.self) {
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
                            Text("John Doe")
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
                        Button(action: { /* Action will need to be added -> complete team form */
                            
                            viewModel.sport = selectedSportLabel
                            viewModel.gender = selectedGenderLabel
                            viewModel.ageGrp = selectedAgeGroupLabel
                            print(selectedSportLabel)
                            print(selectedGenderLabel)
                            print(selectedAgeGroupLabel)

                            Task{
                                do {
                                    try await viewModel.createTeam()
                                } catch {
                                    viewModel.alertMessage = "Error: \(error.localizedDescription)"
                                    viewModel.showAlert = true
                                }
                            }
                            viewModel.test()
                            
                        }) {
                            Text("Create")
                        }//.disabled(viewModel.isLoading) // Disable if loading
                    }
                }.alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text("Message"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
                
        }
    }
}
    #Preview {
        CoachCreateTeamView()
        
        //    CoachCreateTeamView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "U10", players: ""))
    }

