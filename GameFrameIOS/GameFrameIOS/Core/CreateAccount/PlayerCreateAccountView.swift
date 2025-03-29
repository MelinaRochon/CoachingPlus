import SwiftUI

struct PlayerCreateAccountView: View {
    //@State private var teamAccessCode: String = ""
    //    @State private var firstName: String = ""
    //    @State private var lastName: String = ""
    //    @State private var dateOfBirth: Date = Date()
    //    @State private var phone: String = ""
    //    @State private var country: String = ""
    //    @State private var email: String = ""
    //    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = authenticationViewModel()
    @State private var navigateToSignUp = false
    @State private var navigateToCreateAccount = false
    let countries = ["United States", "Canada", "United Kingdom", "Australia"]
    
    var body: some View {
        //NavigationView{
        VStack(spacing: 20) {
            
            ScrollView {
                Spacer().frame(height: 20)
                
                // Title
                VStack(spacing: 5) {
                    Text("Hey Champ!")
                        .font(.title3).bold()
                    HStack {
                        Text("I already have an account!")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        NavigationLink(destination: PlayerLoginView(showSignInView: $showSignInView)) {
                            Text("Log in")
                                .foregroundColor(.blue)
                                .font(.footnote)
                                .underline()
                        }
                    }
                }
                
                // Form Fields with Uniform Style
                
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
                        
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard
                        
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button {
                        print("Create player account tapped")
                        
                        // create account is called!
                        Task {
                            do {
                                print("Verifying access code")
                                await viewModel.validateTeamAccessCode()
                                if viewModel.showInvalidCodeAlert {
                                    return
                                }
                                
                                let accountExists = try await viewModel.checkIfPlayerAccountExists()
                                if (accountExists == nil) {
                                    // There's a problem with the user's input.
                                    // Show alert to let them know
                                } else {
                                    //if (accountExists == true) {
                                    // Account exists inside the invite collection.
                                    // Load the next page to complete registration.
                                    // Make sure the user id is not set yet, otherwise can't sign up with this email
                                    let userIdExists = try await viewModel.checkIfUserIdExists()
                                    if (userIdExists == true) {
                                        // user id exists. Can't sign up with this email
                                    } else {
                                        // user id was not found.
                                        navigateToSignUp = true;
                                    }
                                }
                                
                                //                                    } else if (accountExists == false) {
                                //                                        // Account doesn't exist. Proceed as normal.
                                //
                                //                                        //NavigationLink(destination: PlayerSignUpView(email: viewModel.email, teamId: viewModel.teamId, showSignInView: $showSignInView))
                                //                                        //                                    try await viewModel.signUp(userType: "Player") // to sign up
                                //                                        //                                    showSignInView = false
                                //
                                //                                    }
                                
                                return
                            } catch {
                                print(error)
                            }
                        }
                        
                    } label: {
                        // Use the custom styled "Create Account" button
                        CustomUIFields.createAccountButton("Continue")
                        
                    }.alert("Invalid Access Code", isPresented: $viewModel.showInvalidCodeAlert) {
                        Button("OK", role: .cancel) { }
                    }
                    
                }
                
                if (navigateToSignUp) {
                    PlayerSignUpView(email: viewModel.email, teamId: viewModel.teamId, showSignInView: $showSignInView)
                }
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PlayerCreateAccountView(showSignInView: .constant(false))
}
