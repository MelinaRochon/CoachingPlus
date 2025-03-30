//
//  CoachCreateTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import SFSymbolsPicker
import SwiftData

/** This structure defines the 'Create a New Team' form.
 This view is presented when a coach wants to add a new team to their list from the All Teams page.
 
 ### Features:
 It allows the coach to set details about the team including the team name, nickname, sport, gender, age group, and team logo.
 
 ### Note:
 This form is only accessible to the coach.
 */
struct CoachCreateTeamView: View {
    // Dismiss environment variable for going back to the Teams page
    @Environment(\.dismiss) var dismiss
    
    // ViewModel to manage team creation and related state
    @StateObject private var viewModel = CreateTeamViewModel()
    
    // Options for sport, gender, and age group selection
    let sportOptions = ["Soccer", "Hockey", "Basketball"]
    let genderOptions = ["Female", "Male", "Mixed", "Other"]
    let ageGroupOptions = ["U3", "U4", "U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15", "U16", "U17", "U18", "18+", "Senior", "None"]
    
    // State properties to manage team attributes
    @State private var logoIsPresented = false
    @State private var selectedSportLabel = "Soccer"
    @State private var selectedGenderLabel = "Mixed"
    @State private var selectedAgeGroupLabel = "None"
    
    var body: some View {
        NavigationView {
            VStack {
                // Main form for creating a team
                Form {
                    Section (footer: Text("Team nickname cannot exceed 10 characters.")) {
                        
                        // Section for basic team details (name and nickname)
                        TextField("Team Name", text: $viewModel.name).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        
                        // Nickname field with truncation logic if the length exceeds 10 characters
                        TextField("Nickname", text: $viewModel.nickname).foregroundStyle(.secondary).multilineTextAlignment(.leading).onChange(of: viewModel.nickname) { nickname in
                            if nickname.count > 10 {
                                viewModel.nickname = String(nickname.prefix(10)) // Truncate nickname to 10 characters
                            }
                        }
                    }
                    
                    // Section for additional team details, such as sport, gender, and age group
                    Section (header: Text("Additional Details")) {
                        // Custom pickers for selecting sport, gender, and age group
                        CustomPicker(
                            title: "Sport",
                            options: sportOptions,
                            displayText: { $0 },
                            selectedOption: $selectedSportLabel
                        )
                        
                        CustomPicker(
                            title: "Gender",
                            options: genderOptions,
                            displayText: { $0 },
                            selectedOption: $selectedGenderLabel
                        )
                        
                        CustomPicker(
                            title: "Age group",
                            options: ageGroupOptions,
                            displayText: { $0 },
                            selectedOption: $selectedAgeGroupLabel
                        )
                    }
                    
                    // Section for optional details like team logo and color
                    Section(header: Text("Optional Details")) {
                        HStack {
                            Text("Logo")
                            Spacer()
                            
                            // ColorPicker for selecting the team color
                            ColorPicker("Team Colour", selection: Binding(
                                get: { viewModel.colour },
                                set: { newColor in
                                    DispatchQueue.main.async {
                                        viewModel.updateColour(from: newColor) // Update the team's color
                                    }
                                }
                            ))
                            .labelsHidden() // Hides the labels for the color picker
                        }
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) { // Done button to submit the form
                    Button(action: {
                        // Assign selected values to the view model
                        viewModel.sport = selectedSportLabel
                        viewModel.gender = selectedGenderLabel
                        viewModel.ageGrp = selectedAgeGroupLabel
                        
                        // Create team by calling the viewModel method
                        Task{
                            do {
                                let canWeDismiss = try await viewModel.createTeam()
                                if (canWeDismiss) {
                                    dismiss() // Dismiss the form after successful team creation
                                }
                            } catch {
                                // Show an error message if team creation fails
                                viewModel.alertMessage = "Error: \(error.localizedDescription)"
                                viewModel.showAlert = true
                            }
                        }
                    }) {
                        Text("Create")
                    }.disabled(viewModel.name == "" || viewModel.nickname == "" )
                }
            }
            // Alert for error messages
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Message"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle(Text("Creating a New Team"))
            .navigationBarTitleDisplayMode(.inline)
        }
        // Disables the back button when this view is presented as a sheet
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CoachCreateTeamView()
}

