//
//  PlayerLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct PlayerLoginView: View {
    
    @StateObject private var viewModel = playerAuthenticationViewModel()
    
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
                        customTextField("Email", text: $viewModel.email)
                        
                        // Password Field with Eye Toggle
                        HStack {
                            if showPassword {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    
                    // "Get coached!" Button
                    Button {
                        print("Create account tapped")
                        
                        Task {
                            do {
                                try await viewModel.signUpPlayer() // to sign up
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                            
                            do {
                                try await viewModel.signInPlayer() // to sign in
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                        
                    } label: {
                        HStack {
                            Text("Get coached!")
                                .font(.body).bold()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Custom TextField for Uniform Style
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 45)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
}

#Preview {
    PlayerLoginView(showSignInView: .constant(false))
}
