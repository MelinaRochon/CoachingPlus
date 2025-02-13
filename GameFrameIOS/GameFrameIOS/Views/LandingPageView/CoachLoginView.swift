//
//  CoachLoginView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                // HEADER
                HStack {
                    VStack(alignment: .leading) {
                        Text("GameFrame")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("leveling up your game")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: CreateAccountChoiceView()){
                        HStack {
                            Text("Create account").foregroundColor(.gray)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 28, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                ScrollView{
                    Spacer().frame(height: 30)
                    
                    // Welcome Message
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Glad to have you back Coach!")
                            .font(.title).bold()
                        
                        NavigationLink(destination: CoachCreateAccountView()) {
                            Text("I don't have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            Text("Create one.")
                                .foregroundColor(.blue)
                                .font(.footnote)
                                .underline()
                        }
                    }
                    
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        customTextField("Email", text: $email)
                        
                        // Password Field with Eye Toggle
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    
                    // "Let's go!" Button
                    Button(action: {
                        print("Create account tapped")
                    }) {
                        NavigationLink(destination: CoachMainTabView()){
                            HStack {
                                Text("Let's go!")
                                    .font(.body).bold()
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
        }
    }

    // Custom TextField for Uniform Style
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 50)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
}

#Preview {
    CoachLoginView()
}
