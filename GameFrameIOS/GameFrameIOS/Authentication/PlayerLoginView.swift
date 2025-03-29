//
//  PlayerLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/** This view handles the login process for players.
 It allows players to enter their credentials, toggle password visibility, and navigate to the account creation screen.
 Uses `CustomUIFields` for UI components and `authenticationViewModel` for authentication logic.
*/
struct PlayerLoginView: View {
    // ViewModel for handling authentication logic
    @StateObject private var viewModel = authenticationViewModel()
    
    // Binding to determine if sign-in view should be shown
    @Binding var showSignInView: Bool
    
    // Local state for visibility toggle
    @State private var showPassword: Bool = false
    
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
                            NavigationLink(destination: PlayerCreateAccountView(showSignInView: $showSignInView)) {
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
                                try await viewModel.signIn(userType: "Player") // to sign up
                                showSignInView = false
                                return
                            } catch {
                                print(error) // TODO: Handle error (consider showing an alert)
                            }
                        }
                    } label: {
                        // Custom Styled Login Button
                        CustomUIFields.signInAccountButton("Get coached!")
                    }
                }
            }
        }
    }    
}

#Preview {
    PlayerLoginView(showSignInView: .constant(false))
}
