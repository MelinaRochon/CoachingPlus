//
//  PlayerCreateAccount2View.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//
import SwiftUI

/// This struct defines the view for player sign-up, where the user provides their information to create an account.
/// The `PlayerSignUpView` struct is a SwiftUI view responsible for displaying the player's sign-up form.
struct PlayerSignUpView: View {
    
    // MARK: - State Properties

    /// The view model (AuthenticationModel) is observed and passed from the parent view to manage the player's authentication data.
    @ObservedObject var viewModel: AuthenticationModel

    /// Local state to toggle password visibility in the password field.
    @State private var showPassword: Bool = false
    
    /// Binding to control the visibility of the sign-in view in the parent view.
    @Binding var showSignInView: Bool
    
    // Detect if the app is running in UI test mode
    private let isUITest = ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE")

    // MARK: - View

    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                Spacer().frame(height: 20)

                // Form Fields with Uniform Style
                VStack(spacing: 10) {
                    // Custom text field for the player's first name
                    CustomUIFields.customTextField("First Name", text: $viewModel.firstName)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("page.signup.player.firstName")
                    
                    // Custom text field for the player's last name
                    CustomUIFields.customTextField("Last Name", text: $viewModel.lastName)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("page.signup.player.lastName")

                    // Custom date picker for selecting the player's date of birth
                    HStack {
                        Text("Date of Birth")
                            .foregroundColor(.gray)
                        Spacer()
                        DatePicker("", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .frame(height: 45)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                        
                    // TODO: Make the phone number for the player optional?? Demands on his age
                    // Custom text field for the player's phone number with phone-specific keyboard
                    CustomUIFields.customTextField("Phone", text: $viewModel.phone)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .keyboardType(.phonePad) // Shows phone-specific keyboard
                        .onChange(of: viewModel.phone) { newVal in
                            // Formats the phone number when it changes
                            viewModel.phone = formatPhoneNumber(newVal)
                        }
                        .accessibilityIdentifier("page.signup.player.phone")
                    
                    // Country picker with a list of countries
                    HStack {
                        Text("Country or region")
                        Spacer()
                        Picker("Country", selection: $viewModel.country) {
                            ForEach(AppData.countries, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .accessibilityIdentifier("page.signup.player.country")
                    }
                    .frame(height: 45)
                    .pickerStyle(.automatic)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
        
                    // Disabled text field for displaying the email (cannot be edited)
                    CustomUIFields.disabledCustomTextField("Email", text: $viewModel.email)

                    // Custom password field for the user to set their password
                    // Password Field with Eye Toggle
                    Group {
                        if isUITest {
                            CustomUIFields.customTextField("Password", text: $viewModel.password)
                                .accessibilityIdentifier("page.signup.player.password")
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        } else {
                            CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                                .accessibilityIdentifier("page.signup.player.password")
                        }
                    }

                }
                .padding(.horizontal)
                
                // Submit button for creating the player account
                Button {
                    // Task to handle the sign-up process asynchronously
                    Task {
                        do {
                            // Attempt to create the account with the provided data
                            try await viewModel.signUp(userType: .player)
                            // If successful, hide the sign-in view
                            showSignInView = false
                            return
                        } catch {
                            // Print error if the sign-up fails
                            print(error)
                        }
                    }
                    
                } label: {
                    // Custom button styled for creating the account
                    CustomUIFields.createAccountButton("Create Account")
                }
                .disabled(!signUpIsValid)
                .opacity(signUpIsValid ? 1.0 : 0.5)
                .accessibilityIdentifier("page.signup.player.signUpBtn")
            }
        }
    }
}


// MARK: - Signup validation

/// Extension that conforms the PlayerSignUpView to the AuthenticationSignUpProtocol, which defines validation logic.
extension PlayerSignUpView: AuthenticationSignUpProtocol {
    /// Computed property that checks if the sign-up form is valid (all fields must be filled correctly)
    var signUpIsValid: Bool {
        return !viewModel.email.isEmpty
        && viewModel.email.contains("@") // Email should be non-empty and contain "@"
        && !viewModel.password.isEmpty
        && viewModel.password.count > 5 // Password should be at least 6 characters long
        && !viewModel.firstName.isEmpty
        && !viewModel.lastName.isEmpty // First and Last names should be non-empty
    }
    
    /// Placeholder computed property for validating access code (not implemented in this case)
    var signUpWithAccessCodeValid: Bool {
        return true
    }
}

