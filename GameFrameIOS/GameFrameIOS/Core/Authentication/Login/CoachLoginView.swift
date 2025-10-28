//
//  AuthenticationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import SwiftUI

/**
 This view manages the authentication process for coaches.
 It allows users to log in using their email and password, toggle password visibility, and navigate to the account creation screen if needed.

 The view utilizes:
 - `CustomUIFields` for UI components.
 - `AuthenticationModel` for handling authentication logic.

 Additionally, it provides error handling and conditional navigation based on authentication results.
 */
struct CoachLoginView: View {
    
    // MARK: - State Properties

    /// ViewModel responsible for handling authentication logic.
    @StateObject private var authModel = AuthenticationModel()

    @EnvironmentObject private var dependencies: DependencyContainer

    /// Controls the visibility of the entered password.
    @State private var showPassword: Bool = false

    /// Binding to track whether the sign-in view should be displayed.
    @Binding var showSignInView: Bool

    /// Indicates whether an error message should be displayed to the user.
    @State private var showErrorMessage: Bool = false

    /// Determines if the error alert should be shown.
    @State private var showErrorAlert: Bool = false

    /// Controls whether the user should be redirected to the sign-up screen due to login failure.
    @State private var errorGoToSignUp: Bool = false

    // MARK: - View

    var body: some View {
        NavigationView{
            VStack {
                ScrollView{
                    // Welcome Message
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Glad to have you back Coach!")
                            .font(.title3).bold()
                            .accessibilityIdentifier("coachLoginPage.title")
                        
                        // Navigation link to the account creation view
                        HStack {
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            NavigationLink(destination: CoachCreateAccountView(showSignInView: $showSignInView)) {
                                CustomUIFields.linkButton("Create one")
                            }
                            .accessibilityIdentifier("coachLoginPage.createAccountLink")
                        }
                    }
                    
                    // Form Fields
                    VStack {
                        // Email Input Field
                        CustomUIFields.customTextField("Email", text: $authModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .accessibilityIdentifier("coachLoginPage.emailField")

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $authModel.password, showPassword: $showPassword)
                            .accessibilityIdentifier("coachLoginPage.passwordField")
                    }
                    .padding(.horizontal)
                    
                    // "Let's go!" Button
                    Button {
                        Task {
                            do {
                                guard try await authModel.verifyEmailAddress() != nil else {
                                    showErrorAlert.toggle()
                                    return
                                }

                                try await authModel.signIn() // to sign in
                                showSignInView = false
                                return
                            } catch {
                                showErrorMessage = true
                            }
                        }
                    } label: {
                        // Custom Sign-In Button
                        CustomUIFields.signInAccountButton("Let's go!")
                    }
                    .disabled(!loginIsValid)
                    .opacity(loginIsValid ? 1.0 : 0.5)
                    .accessibilityIdentifier("coachLoginPage.signInButton")
                    
                    Spacer()
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
            .navigationDestination(isPresented: $errorGoToSignUp) { CoachCreateAccountView(showSignInView: $showSignInView)
            }
            .onAppear {
                authModel.setDependencies(dependencies)
            }
        }
    }
}


// MARK: - Login validation

extension CoachLoginView: AuthenticationLoginProtocol {
    // Computed property to validate login credentials
    var loginIsValid: Bool {
        return !authModel.email.isEmpty // Ensure email is not empty
        && authModel.email.contains("@") // Check for a basic email format
        && !authModel.password.isEmpty // Ensure password is not empty
        && authModel.password.count > 5 // Enforce a minimum password length
    }
}
