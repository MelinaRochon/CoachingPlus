//
//  AuthenticationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-02.
//

import SwiftUI

@MainActor
/** Observable object to be called when the coach wants to authenticate by performing one of the
 following action: signIn, signUp. */
final class coachAuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signInCoach() async throws {
        print("Coach - SignIn Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func signUpCoach() async throws {
        print("Coach - SignUp Test!")
        // validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            // TO DO!
            // Need to add some guards and better validation for the user to see
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}

struct CoachAuthenticationView: View {
    
    @StateObject private var viewModel = coachAuthenticationViewModel()
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
                                
                                Text("Create one.")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                    .underline()
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack {
                        TextField("Email", text: $viewModel.email).frame(height: 40).padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        
                        // Password Field with Eye Toggle
                        HStack {
                            //TextField("Password", text: $viewModel.password)
                            if (showPassword == true) {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 45).padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    // "Let's go!" Button
                    Button {
                        print("Create account tapped")
                        Task {
                            do {
                                try await viewModel.signUpCoach() // to sign up
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                            
                            do {
                                try await viewModel.signInCoach() // to sign in
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
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
                    }.padding(.horizontal)
                    Spacer()
                    
                }
            }
        }
    }
}

#Preview {
    CoachAuthenticationView(showSignInView: .constant(false))
}
