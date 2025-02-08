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
                
                HStack {
                    Button("Log in") {
                        // Login action here
                    }
                    .foregroundColor(.black)
                    
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
                        
            Spacer().frame(height: 30)

            // Welcome Message
            Spacer().frame(height: 20)
            VStack(spacing: 5) {
                Text("Glad to have you back Coach!")
                    .font(.title).bold()

                Button(action: {
                    print("Navigate to Create Account")
                }) {
                    Text("I don't have an account! ")
                        .foregroundColor(.gray) +
                    Text("Create one")
                        .foregroundColor(.blue)
                        .underline()
                }
                .font(.footnote)
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


            // "Get coached!" Button
            Button(action: {
                print("Login button tapped")
            }) {
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

            Spacer()
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
