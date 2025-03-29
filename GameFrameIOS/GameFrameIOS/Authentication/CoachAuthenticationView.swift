//
//  AuthenticationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import SwiftUI



struct CoachAuthenticationView: View {
    
    @StateObject private var viewModel = authenticationViewModel()
    @State private var showPassword: Bool = false
    //@Binding var userType: String
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView{
                    // Welcome Message
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Glad to have you back Coach!")
                            .font(.title3).bold()
                        
                        HStack {
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            NavigationLink(destination: CoachCreateAccountView(showSignInView: $showSignInView)) {
                                
                                Text("Create one")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                    .underline()
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack {
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
                        print("Sign In account tapped")
                        Task {
                            /*do {
                                try await viewModel.signUpCoach() // to sign up
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }*/
                            
                            do {
                                try await viewModel.signIn(userType: "Coach") // to sign in
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                    } label: {

                        // Use the custom styled "Create Account" button
                        CustomUIFields.signInAccountButton("Let's go! bb")
                    }
                    Spacer()
                    
                }
            }
        }
    }
}

#Preview {
    CoachAuthenticationView(showSignInView: .constant(false))
}
