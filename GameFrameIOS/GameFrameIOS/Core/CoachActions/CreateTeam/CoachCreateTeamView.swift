//
//  CoachCreateTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import SFSymbolsPicker
import SwiftData

/**
 `CoachCreateTeamView.swift` defines the interface for coaches to create a new team.

 ## Overview:
 This view provides a form where a coach can input the details of a new team, including:
 - **Team Name** and **Nickname** (nickname limited to 10 characters)
 - **Sport**, **Gender**, and **Age Group** selection
 - **Optional Team Logo and Color Selection**

 ## Features:
 - Uses a `ViewModel` to manage team creation logic and Firebase interactions.
 - Custom pickers for selecting team attributes.
 - Prevents invalid input (e.g., nickname length limit, required fields).
 - Displays alerts when an error occurs.
 - Handles form dismissal after successful team creation.

 ## User Flow:
 1. Coach enters team details.
 2. Upon submission, the form validates input and attempts to create a new team.
 3. If successful, the view dismisses; otherwise, an error message appears.

 ## Dependencies:
 - `TeamModel` for managing data.
 - `CustomPicker` for selection inputs.
 - `SFSymbolsPicker` for symbol selection (future enhancement).

 */
struct CoachCreateTeamView: View {
    // Dismiss environment variable for going back to the Teams page
    @Environment(\.dismiss) var dismiss
    
    // ViewModel to manage team creation and related state
    @StateObject private var viewModel = TeamModel()
    
    // Options for sport, gender, and age group selection
    let sportOptions = ["Soccer", "Hockey", "Basketball"]
    let genderOptions = ["Female", "Male", "Mixed", "Other"]
    let ageGroupOptions = ["U3", "U4", "U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15", "U16", "U17", "U18", "18+", "Senior", "None"]
        
    @State private var name = ""
    @State private var nickname = "" // 10 characters
    @State private var sport = "Soccer"
    @State private var logoURL = ""
    @State private var colourHex: String = "#0000FF" // Default to blue
    @State private var gender = "Mixed"
    @State private var ageGrp = "None"
    @State private var alertMessage = ""
    @State private var showAlert = false

    private var colour: Color {
        return Color(hex: colourHex) ?? .blue
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Main form for creating a team
                Form {
                    Section (footer: Text("Team nickname cannot exceed 10 characters.")) {
                        
                        // Section for basic team details (name and nickname)
                        TextField("Team Name", text: $name).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                        
                        // Nickname field with truncation logic if the length exceeds 10 characters
                        TextField("Nickname", text: $nickname).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                            .onChange(of: nickname) { name in
                            if name.count > 10 {
                                nickname = String(name.prefix(10)) // Truncate nickname to 10 characters
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
                            selectedOption: $sport
                        ).disabled(true) // TODO: Make it multisport
                        
                        CustomPicker(
                            title: "Gender",
                            options: genderOptions,
                            displayText: { $0 },
                            selectedOption: $gender
                        )
                        
                        CustomPicker(
                            title: "Age group",
                            options: ageGroupOptions,
                            displayText: { $0 },
                            selectedOption: $ageGrp
                        )
                    }
                    
                    // Section for optional details like team logo and color
                    Section(header: Text("Optional Details")) {
                        HStack {
                            Text("Logo")
                            Spacer()
                            
                            // ColorPicker for selecting the team color
                            ColorPicker("Team Colour", selection: Binding(
                                get: { colour },
                                set: { newColor in
                                    DispatchQueue.main.async {
                                        updateColour(from: newColor) // Update the team's color
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
                    // "Create" button to submit the form and create a new team
                    Button(action: {
                        // Asynchronous task to handle team creation
                        Task{
                            do {
                                // Retrieve the authenticated coach's user information
                                let authUser = try await viewModel.getAuthUser()
                                
                                // Generate a unique access code for the team (if applicable)
                                let uniqueAccessCode = try await viewModel.generateAccessCode()
                                
                                // Create a new team object with the provided details
                                let newTeam = TeamDTO(
                                    teamId: UUID().uuidString,
                                    name: name,
                                    teamNickname: nickname,
                                    sport: sport,
                                    logoUrl: logoURL.isEmpty ? "" : logoURL,
                                    colour: colourHex,
                                    gender: gender,
                                    ageGrp: ageGrp,
                                    accessCode: uniqueAccessCode,  // Optional access code for joining the team
                                    coaches: [authUser.uid],  // The coach creating the team
                                    players: [],
                                    invites: []
                                )
                                
                                // Attempt to create the team in the database
                                let canWeDismiss = try await viewModel.createTeam(teamDTO: newTeam, coachId: authUser.uid)
                                
                                // If successful, dismiss the form and return to the previous screen
                                if (canWeDismiss) {
                                    dismiss() // Dismiss the form after successful team creation
                                }
                            } catch {
                                // Show an error message if team creation fails
                                alertMessage = "Error: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }) {
                        Text("Create")
                    }
                    .disabled(!addTeamIsValid)
                }
            }
            // Alert for error messages
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle(Text("Creating a New Team"))
            .navigationBarTitleDisplayMode(.inline)
        }
        // Disables the back button when this view is presented as a sheet
        .navigationBarBackButtonHidden(true)
    }
    
    
    /// Updates the team's color by converting the selected SwiftUI `Color` to a HEX string.
    /// If the conversion fails, it defaults to black ("#000000").
    /// - Parameter color: The `Color` selected by the user from the color picker.
    func updateColour(from color: Color) {
        colourHex = color.toHex() ?? "#000000"
    }
}


/// Extension to conform `CoachCreateTeamView` to `TeamProtocol`,
/// adding validation logic for team creation.
extension CoachCreateTeamView: TeamProtocol {
    /// Checks whether the form inputs are valid for creating a team.
    var addTeamIsValid: Bool {
        return !name.isEmpty
        && !nickname.isEmpty && nickname.count < 11 // cannot exceed 10 characters
        && !sport.isEmpty
        && !gender.isEmpty
        && !ageGrp.isEmpty
        && !colourHex.isEmpty
    }
}


#Preview {
    CoachCreateTeamView()
}

