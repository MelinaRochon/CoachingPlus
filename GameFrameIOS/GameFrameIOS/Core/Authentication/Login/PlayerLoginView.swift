//
//  PlayerLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/**
 This view manages the login process for players.
 It allows users to enter their credentials, toggle password visibility, and navigate to the account creation screen if needed.

 The view utilizes:
 - `CustomUIFields` for UI components.
 - `AuthenticationModel` for handling authentication logic.

 Additionally, it provides error handling and conditional navigation based on authentication results.
 */
struct PlayerLoginView: View {
    
    // MARK: - State Properties

    /// ViewModel responsible for handling authentication logic.
    @StateObject private var authModel = AuthenticationModel()
    
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Binding to track whether the sign-in view should be displayed.
    @Binding var showSignInView: Bool

    /// Controls the visibility of the entered password.
    @State private var showPassword: Bool = false

    /// Indicates whether an error message should be displayed to the user.
    @State private var showErrorMessage: Bool = false

    /// Determines if the error alert should be shown.
    @State private var showErrorAlert: Bool = false

    /// Controls whether the user should be redirected to the sign-up screen due to login failure.
    @State private var errorGoToSignUp: Bool = false
    
    // MARK: - View

    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                ScrollView{
                    // Welcome Message
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Welcome back Champ!")
                            .font(.title3).bold()
                        
                        // Navigation link to account creation
                        HStack {
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            NavigationLink(destination: PlayerCreateAccountView(showSignInView: $showSignInView, viewModel: AuthenticationModel())) {
                                CustomUIFields.linkButton("Create one")
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack(spacing: 10) {
                        // Email Input Field
                        CustomUIFields.customTextField("Email", text: $authModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard
                            .accessibilityIdentifier("page.player.login.emailField")

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $authModel.password, showPassword: $showPassword)
                            .accessibilityIdentifier("page.player.login.passwordField")
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            do {
                                guard try await authModel.verifyEmailAddress() != nil else {
                                    showErrorAlert.toggle()
                                    return
                                }

                                try await authModel.signIn() // to sign up
                                showSignInView = false
                                return
                            } catch {
                                showErrorMessage = true
                            }
                        }
                    } label: {
                        // Custom Styled Login Button
                        CustomUIFields.signInAccountButton("Get coached!")
                    }
                    .disabled(!loginIsValid)
                    .opacity(loginIsValid ? 1.0 : 0.5)
                    .accessibilityIdentifier("page.player.login.signInBtn")
                }
            }
            .alert("Invalid credentials. Please try again.", isPresented: $showErrorMessage) {
                Button(role: .cancel) {
                    // reset email and password
                    authModel.email = ""
                    authModel.password = ""
                } label: {
                    Text("OK")
                }
            }
            .alert("Account Not Found", isPresented: $showErrorAlert) {
                Button(role: .cancel) {
                    authModel.email = ""
                    authModel.password = ""
                    errorGoToSignUp = true
                } label: {
                    Text("Sign Up")
                }
                Button("OK") {
                    authModel.email = ""
                    authModel.password = ""
                }
            } message: {
                Text("No account was found with this email. Please consider creating a new account.")
            }
            .navigationDestination(isPresented: $errorGoToSignUp) {
                PlayerCreateAccountView(showSignInView: $showSignInView, viewModel: authModel)
            }
            .onAppear {
                authModel.setDependencies(dependencies)
            }
        }
        .accessibilityIdentifier("page.player.login")
    }
}


// MARK: - File extension

extension PlayerLoginView: AuthenticationLoginProtocol {
    // Computed property to validate login credentials
    var loginIsValid: Bool {
        return !authModel.email.isEmpty && isValidEmail(authModel.email)    // Check for a basic email format
        && !authModel.password.isEmpty && authModel.password.count > 5      // Enforce a minimum password length
    }
}


#Preview {
    PlayerLoginView(showSignInView: .constant(false))
}
