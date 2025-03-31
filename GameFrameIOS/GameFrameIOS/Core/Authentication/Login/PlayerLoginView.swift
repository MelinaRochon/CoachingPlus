//
//  PlayerLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/** This view handles the login process for players.
 It allows players to enter their credentials, toggle password visibility, and navigate to the account creation screen.
 Uses `CustomUIFields` for UI components and `AuthenticationModel` for authentication logic.
*/
struct PlayerLoginView: View {
    // ViewModel for handling authentication logic
    @StateObject private var viewModel = AuthenticationModel()
    
    // Binding to determine if sign-in view should be shown
    @Binding var showSignInView: Bool
    
    // Local state for visibility toggle & alerts
    @State private var showPassword: Bool = false
    @State private var showErrorMessage: Bool = false

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
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        print("Create account tapped")
                        
                        Task {
                            do {
                                try await viewModel.signIn() // to sign up
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
                }
            }
            .alert("Invalid credentials. Please try again.", isPresented: $showErrorMessage) {
                Button(role: .cancel) {
                    // reset email and password
                    viewModel.email = ""
                    viewModel.password = ""
                } label: {
                    Text("OK")
                }
            }
        }
    }    
}

extension PlayerLoginView: AuthenticationLoginProtocol {
    // Computed property to validate login credentials
    var loginIsValid: Bool {
        return !viewModel.email.isEmpty // Ensure email is not empty
        && viewModel.email.contains("@") // Check for a basic email format
        && !viewModel.password.isEmpty // Ensure password is not empty
        && viewModel.password.count > 5 // Enforce a minimum password length
    }
}


#Preview {
    PlayerLoginView(showSignInView: .constant(false))
}
