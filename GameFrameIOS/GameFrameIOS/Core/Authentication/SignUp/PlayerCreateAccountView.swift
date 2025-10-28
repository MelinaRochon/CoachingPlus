import SwiftUI
import GameFrameIOSShared

/**
 This view handles the player's account creation process. It is the first screen shown when a new player wants to sign up.

 The view is composed of the following sections:
 
 1. **Title & Navigation to Login**:
    - A welcome message and a link that takes the user to the login screen if they already have an account.

 2. **Form Fields Section**:
    - **Team Access Code**: The player enters a team access code which is validated by the view model.
    - **Email**: The player provides their email address, which is validated to ensure it is correctly formatted.
    
 3. **Continue Button**:
    - When the user taps this button, the app validates the access code and checks whether the user exists in the system. If the email already exists, an error alert is displayed. If the access code is invalid, a separate alert is shown.

 4. **Navigation to Sign-Up Page**:
    - If the initial checks pass, the user is navigated to the actual sign-up page where they provide more details (like name and password).

  **State Variables**:
 - `showSignInView`: A binding that controls whether the sign-in view should be shown.
 - `viewModel`: A `@StateObject` responsible for handling the authentication logic, such as validating the team access code and verifying user details.
 - `navigateToSignUp`: A state variable to control navigation to the sign-up page.
 - `navigateToCreateAccount`: Tracks whether the user is navigating to the account creation page.
 - `errorUserExists`: A state to track whether an alert should be shown if the user's email already exists in the system.
 - `errorAccessCodeInvalid`: A state to open an alert if the team access code is invalid.

 The view is designed to guide the user through a multi-step sign-up process, including entering a team access code, verifying the email, and handling errors gracefully with appropriate alerts.

 The view utilizes custom UI components like `CustomUIFields` to create text fields, buttons, and other interactive elements with consistent styling.
*/
struct PlayerCreateAccountView: View {
    
    // MARK: - State Properties

    /// Controls whether the sign-in view should be shown.
    @Binding var showSignInView: Bool
    
    /// ViewModel handling authentication logic.
    @StateObject var viewModel: AuthenticationModel
    
    @EnvironmentObject var dependencies: DependencyContainer
    
    /// State to track whether the user should navigate to the sign-up page.
    @State private var navigateToSignUp = false
    
    /// State to track whether the user should navigate to account creation.
    @State private var navigateToCreateAccount = false
    
    /// State to open an alert if the user account already exists.
    @State private var errorUserExists: Bool = false
    
    /// State to open an alert if the team access code is invalid.
    @State private var errorAccessCodeInvalid: Bool = false

    /// A boolean to control whether the user is redirected to login.
    @State private var errorGoToLogin: Bool = false

    // MARK: - View

    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                Spacer().frame(height: 20)
                
                // Title & Navigation to Login
                VStack(spacing: 5) {
                    Text("Hey Champ!")
                        .font(.title3).bold()
                        .accessibilityIdentifier("page.signup.player.title")
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
                                .accessibilityIdentifier("page.signup.player.teamAccessCode")
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
                            .accessibilityIdentifier("page.signup.player.email")
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button {
                        // create account is called!
                        Task {
                            do {
                                print("Verifying access code")
                                let team = try await viewModel.validateTeamAccessCode()
                                do {
                                    try await viewModel.verifyUserIdDoesNotExist()
                                    navigateToSignUp.toggle()
                                    return
                                } catch {
                                    errorUserExists = true
                                    print("Error when verifying if the user id exists. \(error)")
                                }
                            } catch {
                                print("Errorrr: \(error.localizedDescription)")
                                errorAccessCodeInvalid = true
                            }
                        }
                    } label: {
                        // Uses the custom-styled "Continue" button
                        CustomUIFields.createAccountButton("Continue")
                    }
                    .disabled(!signUpWithAccessCodeValid)
                    .opacity(signUpWithAccessCodeValid ? 1.0 : 0.5)
                    .accessibilityIdentifier("page.signup.player.continueBtn")
                    
                    .alert("Invalid Access Code", isPresented: $errorAccessCodeInvalid) {
                        Button(role: .cancel) {
                            viewModel.teamAccessCode = ""
                            viewModel.email = ""
                        } label: {
                            Text("OK")
                        }
                    }
                    .alert("Account exists", isPresented: $errorUserExists){
                        Button(role: .cancel) {
                            viewModel.resetAccountFields()
                            errorGoToLogin = true
                        } label: {
                            Text("Login")
                        }
                        Button("OK") {
                            viewModel.resetAccountFields()
                        }
                    } message: {
                        Text("An account with that email address already exists. Please sign in.")
                    }
                    .navigationDestination(isPresented: $errorGoToLogin) {
                        PlayerLoginView(showSignInView: $showSignInView)
                    }
                }
                
                // Navigation to Sign-Up Page
                if (navigateToSignUp) {
                    // Pass the viewModel as a Binding to PlayerSignUpView
                    PlayerSignUpView(viewModel: viewModel, showSignInView: $showSignInView)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.setDependencies(dependencies)
        }
    }
}


// MARK: - Create Account validation

/// Extension that conforms the PlayerCreateAccountView to the AuthenticationSignUpProtocol, which defines validation logic.
extension PlayerCreateAccountView: AuthenticationSignUpProtocol {
    /// Placeholder computed property for validating access code (not implemented in this case)
    var signUpWithAccessCodeValid: Bool {
        return !viewModel.email.isEmpty
        && viewModel.email.contains("@")
        && !viewModel.teamAccessCode.isEmpty
        
    }
    
    /// Computed property that checks if the sign-up form is valid (all fields must be filled correctly)
    var signUpIsValid: Bool {
        return !viewModel.email.isEmpty
        && viewModel.email.contains("@")
        && !viewModel.password.isEmpty
        && viewModel.password.count > 5
        && !viewModel.firstName.isEmpty
        && !viewModel.lastName.isEmpty
    }
}


#Preview {
    PlayerCreateAccountView(showSignInView: .constant(false), viewModel: AuthenticationModel())
}
