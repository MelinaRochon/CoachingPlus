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
                            HStack {
                                Text("Continue")
                                    .font(.body).bold()
                                //Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            
                        }.alert("Invalid Access Code", isPresented: $viewModel.showInvalidCodeAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        
                    }
                    
                    if (navigateToSignUp) {
                        PlayerSignUpView(email: viewModel.email, teamId: viewModel.teamId, showSignInView: $showSignInView)
                    }
                    //                    NavigationLink(destination: PlayerSignUpView(email: viewModel.email, teamId: viewModel.teamId, showSignInView: $showSignInView), isActive: $navigateToSignUp) {
                    //
                    //                    }
                    
                    // "Get coached!" Button
                    
                }
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    //}
    
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
    PlayerCreateAccountView(showSignInView: .constant(false))
}
