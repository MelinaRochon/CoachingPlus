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
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    @StateObject private var viewModel = CreateTeamViewModel()
    
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
                Form {
                    Section (footer: Text("Team nickname cannot exceed 10 characters.")) {
                        TextField("Team Name", text: $viewModel.name).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        TextField("Nickname", text: $viewModel.nickname).foregroundStyle(.secondary).multilineTextAlignment(.leading).onChange(of: viewModel.nickname) { nickname in
                            if nickname.count > 10 {
                                viewModel.nickname = String(nickname.prefix(10)) // Truncate excess characters. Don't accept more than 10
                            }
                        }
                    }
                    
                    Section (header: Text("Additional Details")) {
                        HStack {
                            Picker("Sport", selection: $selectedSportLabel)
                            {
                                ForEach(sportOptions, id: \.self) {sport in
                                    Text(sport).tag(sport)
                                }
                            }
                        }
                        
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
                    
                    Section(header: Text("Optional Details")) {
                        HStack {
                            Text("Logo")
                            Spacer()
                            
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
                    }
                }
            }.toolbar {
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
                    Button(action: { /* Action will need to be added -> complete team form */
                        
                        viewModel.sport = selectedSportLabel
                        viewModel.gender = selectedGenderLabel
                        viewModel.ageGrp = selectedAgeGroupLabel
                        
                        Task{
                            do {
                                let canWeDismiss = try await viewModel.createTeam()
                                if (canWeDismiss) {
                                    dismiss() // Dismiss the full-screen cover
                                }
                            } catch {
                                viewModel.alertMessage = "Error: \(error.localizedDescription)"
                                viewModel.showAlert = true
                            }
                        }
                        viewModel.test()
                    }) {
                        Text("Create")
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Message"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }.navigationTitle(Text("Creating a New Team")).navigationBarTitleDisplayMode(.inline)
        }.navigationBarBackButtonHidden(true) // disabled the back button as we have a sheet
    }
}

#Preview {
    CoachCreateTeamView()
}

