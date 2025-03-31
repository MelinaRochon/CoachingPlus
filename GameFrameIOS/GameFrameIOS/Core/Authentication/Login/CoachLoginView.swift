//
//  AuthenticationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import SwiftUI

/** This view handles the authentication process for coaches.
 It allows users to enter their email and password, toggle password visibility,  and navigate to the account creation screen.
 Uses `CustomUIFields` for UI components and `AuthenticationModel` for authentication logic.
*/
struct CoachLoginView: View {
    @StateObject private var viewModel = AuthenticationModel() // ViewModel for handling authentication logic
    @State private var showPassword: Bool = false // Controls password visibility
    
    // Binding to determine if sign-in view should be shown
    @Binding var showSignInView: Bool
    // Local state for alert visibility
    @State private var showErrorMessage: Bool = false
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView{
                    // Welcome Message
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Glad to have you back Coach!")
                            .font(.title3).bold()
                        
                        // Navigation link to the account creation view
                        HStack {
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            NavigationLink(destination: CoachCreateAccountView(showSignInView: $showSignInView)) {
                                CustomUIFields.linkButton("Create one")
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack {
                        // Email Input Field
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                    }
                    .padding(.horizontal)
                    
                    // "Let's go!" Button
                    Button {
                        Task {
                            do {
                                try await viewModel.signIn() // to sign in
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
                    
                    Spacer()
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

extension CoachLoginView: AuthenticationLoginProtocol {
    // Computed property to validate login credentials
    var loginIsValid: Bool {
        return !viewModel.email.isEmpty // Ensure email is not empty
        && viewModel.email.contains("@") // Check for a basic email format
        && !viewModel.password.isEmpty // Ensure password is not empty
        && viewModel.password.count > 5 // Enforce a minimum password length
    }
}


#Preview {
    CoachLoginView(showSignInView: .constant(false))
}
