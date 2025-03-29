//
//  PlayerCreateAccount2View.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//
import SwiftUI

struct PlayerSignUpView: View {
    var email: String // retreive the email address entered by the user in the previous view
    var teamId: String // retreive the team id from the team access code entered by the user in the previous view
        
    @State private var showPassword: Bool = false
    
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = authenticationViewModel()
//    @State private var country = "Canada"
    
    var body: some View {
        VStack(spacing: 20) {
            
            ScrollView {
                Spacer().frame(height: 20)

                // Form Fields with Uniform Style
                VStack(spacing: 10) {
                    
                    CustomUIFields.customTextField("First Name", text: $viewModel.firstName)
                        .autocorrectionDisabled(true)

                    CustomUIFields.customTextField("Last Name", text: $viewModel.lastName)
                        .autocorrectionDisabled(true)

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
                                        
                    // TODO: Make the phone number for the player optional?? Demands on his age
                    CustomUIFields.customTextField("Phone", text: $viewModel.phone)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .keyboardType(.phonePad) // Shows phone-specific keyboard
                    
                    // Country Picker Styled Like Other Fields
                    HStack {
                        Text("Country or region")
                        Spacer()
                        Picker("Country", selection: $viewModel.country) {
                            ForEach(AppData.countries, id: \.self) { c in
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
        
                    CustomUIFields.disabledCustomTextField("Email", text: $viewModel.email)

                    // Password Field Styled Like Other Fields
                    CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                    
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
                    // Use the custom styled "Create Account" button
                    CustomUIFields.createAccountButton("Create Account")
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
}

#Preview {
    PlayerSignUpView(email: "", teamId: "", showSignInView: .constant(false))
}
