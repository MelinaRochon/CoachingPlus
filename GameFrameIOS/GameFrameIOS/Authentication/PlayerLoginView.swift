//
//  PlayerLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct PlayerLoginView: View {
    
    @StateObject private var viewModel = authenticationViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
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
                        
                        HStack {
                            
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            NavigationLink(destination: PlayerCreateAccountView(showSignInView: $showSignInView)) {
                                Text("Create one.")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                    .underline()
                            }
                        }
                    }
                    
                    
                    // Form Fields
                    VStack(spacing: 10) {
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                    }
                    .padding(.horizontal)
                    
                    
                    // "Get coached!" Button
                    Button {
                        print("Create account tapped")
                        
                        Task {
                            do {
                                try await viewModel.signIn(userType: "Player") // to sign up
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                            
                        }
                        
                    } label: {
                        // Use the custom styled "Create Account" button
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
