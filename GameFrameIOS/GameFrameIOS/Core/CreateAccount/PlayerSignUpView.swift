//
//  PlayerCreateAccount2View.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//
import SwiftUI

struct PlayerSignUpView: View {
    @State private var teamAccessCode: String = ""
    var email: String // retreive the email address entered by the user in the previous view
    var teamId: String // retreive the team id from the team access code entered by the user in the previous view
    
    //    @State private var password: String = ""
    
    @State private var showPassword: Bool = false
    
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = authenticationViewModel()
    @State private var country = "Canada"
    let countries = ["United States", "Canada", "United Kingdom", "Australia"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                Spacer().frame(height: 20)
                
                
                // Form Fields with Uniform Style
                VStack(spacing: 10) {
                    customTextField("First Name", text: $viewModel.firstName)
                    customTextField("Last Name", text: $viewModel.lastName)
                    
                    // Date Picker Styled Like Other Fields
                    HStack {
                        Text("Date of Birth")
                            .foregroundColor(.gray)
                        Spacer()
                        DatePicker("", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .frame(height: 45)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    
                    customTextField("Phone", text: $viewModel.phone) // TO DO - Make the phone number for the player optional?? Demands on his age
                    
                    // Country Picker Styled Like Other Fields
                    HStack {
                        Text("Country or region")
                        Spacer()
                        Picker("Country", selection: $viewModel.country) {
                            ForEach(countries, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                    }
                    .frame(height: 45)
                    .pickerStyle(.automatic)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
        
                    
                    TextField("Email", text: $viewModel.email)
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .autocapitalization(.none).foregroundStyle(.secondary)
                        .autocapitalization(.none).disabled(true)
                    // Password Field Styled Like Other Fields
                    HStack {
                        if showPassword {
                            TextField("Password", text: $viewModel.password).autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $viewModel.password).autocapitalization(.none)
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
                    print("Create player account tapped")
                    
                    //create account is called!
                    Task {
                        do {
                            try await viewModel.playerSignUp() // to sign up
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }
                    }
                    
                } label: {
                    HStack {
                        Text("Create Account")
                            .font(.body).bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
                }
            }
        }.task {
            do {
                // load the player's information
                // If there there's more than one player with the same teamId and email --> Actually that can't happen because in the Authentication, we will have an issue. Can't have more than one email address that is the same for more than one account!!!
                try await viewModel.loadPlayerInfo(email: email, teamId: teamId)
                viewModel.email = email
                viewModel.teamId = teamId
                //country = viewModel.country
            } catch {
                print("error.. Abort.. \(error)")
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
    PlayerSignUpView(email: "", teamId: "", showSignInView: .constant(false))
}
