//
//  PlayerCreateAccountStep1.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-12.
//

import SwiftUI

struct PlayerCreateAccountStep1: View {
    @StateObject private var viewModel = authenticationViewModel()

    var body: some View {
        // Form Fields with Uniform Style
        VStack(spacing: 10) {
            // Team Access Code with Help Button
            HStack {
                TextField("Team Access Code", text: $viewModel.teamAccessCode)
                Button(action: {
                    print("Show help for Team Access Code")
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 45)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            
            //customTextField("First Name", text: $viewModel.firstName)
            //customTextField("Last Name", text: $viewModel.lastName)
            
            // Date Picker Styled Like Other Fields
//                        HStack {
//                            Text("Date of Birth")
//                                .foregroundColor(.gray)
//                            Spacer()
//                            DatePicker("", selection: $viewModel.dateOfBirth, displayedComponents: .date)
//                                .labelsHidden()
//                        }
//                        .frame(height: 45)
//                        .padding(.horizontal)
//                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
//
//                        customTextField("Phone", text: $viewModel.phone) // TO DO - Make the phone number for the player optional?? Demands on his age
            
            // Country Picker Styled Like Other Fields
            // Country Picker Styled Like Other Fields
//                        HStack {
//                            Picker(selection: $viewModel.country) {
//                                ForEach(countries, id: \.self) { country in
//                                    Text(country).tag(country)
//                                }
//                            } label: {
//                                Text("Country or region")
//                                    .foregroundColor(.primary) // Ensures black text
//                            }
//                        }.pickerStyle(.navigationLink)
//                            .frame(height: 45)
//                            .padding(.horizontal)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray, lineWidth: 1)
//                            )
//
            TextField("Email", text: $viewModel.email)
                .frame(height: 45)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .foregroundColor(.black).autocapitalization(.none)
                .autocapitalization(.none)
            // Password Field Styled Like Other Fields
//                        HStack {
//                            if showPassword {
//                                TextField("Password", text: $viewModel.password).autocapitalization(.none)
//                            } else {
//                                SecureField("Password", text: $viewModel.password).autocapitalization(.none)
//                            }
//                            Button(action: { showPassword.toggle() }) {
//                                Image(systemName: showPassword ? "eye.slash" : "eye")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .frame(height: 45)
//                        .padding(.horizontal)
//                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
        }
        .padding(.horizontal)
    }
}

#Preview {
    PlayerCreateAccountStep1()
}
