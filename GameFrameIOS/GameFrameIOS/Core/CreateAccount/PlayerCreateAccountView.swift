import SwiftUI

/** View for creating a player account, guiding the user through the sign-up process. */
struct PlayerCreateAccountView: View {
    
    // Controls whether the sign-in view should be shown.
    @Binding var showSignInView: Bool
    
    // ViewModel handling authentication logic.
    @StateObject private var viewModel = authenticationViewModel()
    
    // State to track whether the user should navigate to the sign-up page.
    @State private var navigateToSignUp = false
    
    // State to track whether the user should navigate to account creation.
    @State private var navigateToCreateAccount = false
    
    // State to open an alert if the user account already exists.
    @State private var errorUserExists: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Spacer().frame(height: 20)
                
                // Title & Navigation to Login
                VStack(spacing: 5) {
                    Text("Hey Champ!")
                        .font(.title3).bold()
                    HStack {
                        Text("I already have an account!")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        NavigationLink(destination: PlayerLoginView(showSignInView: $showSignInView)) {
                            CustomUIFields.linkButton("Log in")
                        }
                    }
                }
                
                // Form Fields Section
                if (!navigateToSignUp && !navigateToCreateAccount) {
                    VStack(spacing: 10) {
                        // Team Access Code with Help Button
                        HStack {
                            TextField("Team Access Code", text: $viewModel.teamAccessCode)
                                .autocapitalization(.none)
                                .autocorrectionDisabled(true)
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
                        
                        // Email Input Field
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button {
                        // create account is called!
                        Task {
                            do {
                                print("Verifying access code")
                                await viewModel.validateTeamAccessCode()
                                if viewModel.showInvalidCodeAlert {
                                    return
                                }
                                
                                // Check if account exists
                                let doesUserIdExits = try await viewModel.checkIfUserIdAlreadyExists()
                                if let userIdExists = doesUserIdExits {
                                    if userIdExists {
                                        // TODO: Show error as user id exists. Can't sign up with this email
                                        errorUserExists.toggle() // true
                                    } else {
                                        print("Account does not exist")
                                        // Proceed with the sign up
                                        navigateToSignUp.toggle()
                                    }
                                }
                                
                                return
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        // Uses the custom-styled "Continue" button
                        CustomUIFields.createAccountButton("Continue")
                    }
                    .alert("Invalid Access Code", isPresented: $viewModel.showInvalidCodeAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    .alert("That account already exists. Please sign in.", isPresented: $errorUserExists){
                        Button("OK", role: .cancel) {}
                    }
                }
                
                // Navigation to Sign-Up Page
                if (navigateToSignUp) {
                    PlayerSignUpView(email: viewModel.email, teamId: viewModel.teamId, showSignInView: $showSignInView)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayerCreateAccountView(showSignInView: .constant(false))
}
