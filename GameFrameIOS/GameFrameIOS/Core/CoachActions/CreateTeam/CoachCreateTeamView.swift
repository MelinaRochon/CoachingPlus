//
//  CoachCreateTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import SFSymbolsPicker
import SwiftData
import GameFrameIOSShared

/**
 `CoachCreateTeamView.swift` provides an interface for coaches to create a new team.

 ## Overview:
 This view presents a form where a coach can enter details for a new team, including:
 - **Team Name** and **Nickname** (nickname is limited to 10 characters)
 - **Sport**, **Gender**, and **Age Group** selection
 - **Optional customization**: Team logo and color selection

 ## Features:
 - Uses a `ViewModel` to handle team creation logic and Firebase interactions.
 - Custom pickers for selecting sport, gender, and age group.
 - Prevents invalid input (e.g., nickname length limit, required fields).
 - Displays alerts if an error occurs.
 - Automatically dismisses after successful team creation.

 ## User Flow:
 1. Coach enters the team details.
 2. The form validates input and attempts to create a new team.
 3. If successful, the view dismisses; otherwise, an error message appears.

 ## Dependencies:
 - `TeamModel` for handling team-related data operations.
 - `CustomPicker` for dropdown selections.
 - `SFSymbolsPicker` for selecting an optional team logo (future enhancement).

 */
struct CoachCreateTeamView: View {
    
    // MARK: - State Properties

    /// Allows dismissing the view to return to the previous screen.
    @Environment(\.dismiss) var dismiss
    
    /// ViewModel to manage team creation and interactions with the database.
    @StateObject private var viewModel = TeamModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Predefined list of sports available for selection.
    let sportOptions = ["Soccer", "Hockey", "Basketball"]

    // MARK: - User Input States for Team Details

    /// The name of the team entered by the user.
    @State private var name = ""

    /// The team's nickname, limited to 10 characters.
    @State private var nickname = ""

    // The selected sport for the team (default is "Soccer").
    @State private var sport = "Soccer"

    /// URL string for the team’s logo (if provided).
    @State private var logoURL = ""

    /// The team's selected color in HEX format (default is blue: "#0000FF").
    @State private var colourHex: String = "#0000FF"

    /// The selected gender classification for the team (default is "Mixed").
    @State private var gender = "Mixed"

    /// The selected age group for the team (default is "None").
    @State private var ageGrp = "None"

    /// Stores error or informational messages to display in an alert.
    @State private var alertMessage = ""

    /// Controls whether an alert message is shown to the user.
    @State private var showAlert = false

    /// Converts the stored hex color into a SwiftUI `Color` object.
    private var colour: Color {
        return Color(hex: colourHex) ?? .blue
    }
    
    // MARK: - View

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
                            options: AppData.genderOptions,
                            displayText: { $0 },
                            selectedOption: $gender
                        )
                        
                        CustomPicker(
                            title: "Age group",
                            options: AppData.ageGroupOptions,
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
                        Text("Create").foregroundStyle(addTeamIsValid ? .red : .gray)
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
            .onAppear {
                viewModel.setDependencies(dependencies)
            }
        }
        // Disables the back button when this view is presented as a sheet
        .navigationBarBackButtonHidden(true)
    }
    
    
    // MARK: - Functions

    /// Updates the team's color by converting the selected SwiftUI `Color` to a HEX string.
    /// If the conversion fails, it defaults to black ("#000000").
    /// - Parameter color: The `Color` selected by the user from the color picker.
    func updateColour(from color: Color) {
        colourHex = color.toHex() ?? "#000000"
    }
}


// MARK: - Create team validation

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

