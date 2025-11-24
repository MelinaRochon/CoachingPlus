///
///  CoachCreateTeamView.swift
///  GameFrameIOS
///
///  Created by Mélina Rochon on 2025-02-05.
///

import SwiftUI
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
    @StateObject private var teamModel = TeamModel()

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
    @State private var gender = "Select"

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
    enum Field {
        case name
        case nickname
        case sport
        case age
        case gender
    }
        
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                CustomUIFields.customTitle("Creating Your Team", subTitle: "Enter your team's basic information to get started.")

                ScrollView {
                    VStack {
                        
                        VStack(alignment: .leading) {
                            CustomTextField(label: "Team Name", text: $name)
                            CustomTextField(label: "Nickname", text: $nickname, isRequired: false, disableAutocorrection: true)
                            
                            Text("Team nickname cannot exceed 10 characters.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            CustomUIFields.customDivider("Additional Details")
                                .padding(.top, 30)
                            
                            CustomMenuDropdown(
                                label: "Sport",
                                placeholder: "Select a sport",
                                onSelect: {
                                    hideKeyboard()
                                    
                                },
                                options: sportOptions,
                                selectedOption: $sport,
                                disabled: true
                            )
                            
                            CustomMenuDropdown(
                                label: "Gender",
                                placeholder: "Select a gender",
                                onSelect: {
                                    hideKeyboard()
                                    
                                },
                                options: AppData.teamGenderOptions,
                                selectedOption: $gender
                            )
                            
                            CustomMenuDropdown(
                                label: "Age group",
                                placeholder: "Select an age group",
                                onSelect: {
                                    hideKeyboard()
                                },
                                options: AppData.ageGroupOptions,
                                selectedOption: $ageGrp
                            )
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button
                    Button(action: {
                        dismiss() // Dismiss the full-screen cover
                    }) {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.gray) // Make text + icon white
//                            .frame(width: 40, height: 40) // Make it square
//                            .background(Circle().fill(Color(uiColor: .systemGray6)))
                        Text("Cancel")
                    }
                    .accessibilityIdentifier("page.coach.team.create.cancel")
                }
                
                ToolbarItem(placement: .bottomBar) { // Done button to submit the form
                    // "Create" button to submit the form and create a new team
                    Button(action: {
                        // Asynchronous task to handle team creation
                        Task{
                            do {
                                // Retrieve the authenticated coach's user information
                                let authUser = try await teamModel.getAuthUser()
                                
                                // Generate a unique access code for the team (if applicable)
                                let uniqueAccessCode = try await teamModel.generateAccessCode()
                                
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
                                let canWeDismiss = try await teamModel.createTeam(teamDTO: newTeam, coachId: authUser.uid)
                                
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
                        HStack {
                            Text("Create Team")
                                .font(.body).bold()
                            Image(systemName: "arrow.right")
                        }
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(addTeamIsValid ? Color.black : Color.secondary))
                    }
                    .disabled(!addTeamIsValid)
                    .accessibilityIdentifier("page.coach.team.create.btn")
                }
            }
            .toolbarBackground(.clear, for: .bottomBar)
            .scrollDismissesKeyboard(.immediately)
            // Alert for error messages
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
//            .navigationTitle(Text("Creating a New Team"))
//            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                teamModel.setDependencies(dependencies)
            }
            .accessibilityIdentifier("page.coach.team.create")
        }
        .accessibilityIdentifier("page.coach.team.create")
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
        && !gender.isEmpty && gender != "Select"
        && !ageGrp.isEmpty && ageGrp != "None"
        && !colourHex.isEmpty
    }
}


//#Preview {
//    CoachCreateTeamView()
//}


