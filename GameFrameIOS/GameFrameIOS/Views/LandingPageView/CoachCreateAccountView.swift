import SwiftUI

struct CoachCreateAccountView: View {
    @State private var showPassword: Bool = false
    @StateObject private var viewModel = authenticationViewModel()
    @Binding var showSignInView: Bool
    
    let countries = ["United States", "Canada", "United Kingdom", "Australia"]
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                
                ScrollView {
                    Spacer().frame(height: 20)
                    
                    // Title
                    VStack(spacing: 5) {
                        Text("Hey Coach!")
                            .font(.title3).bold()
                        HStack {
                            Text("I already have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            NavigationLink(destination: CoachAuthenticationView(showSignInView: $showSignInView)) {
                                
                                Text("Log in.")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                    .underline()
                            }
                        }
                    }
                    
                    // Form Fields with Uniform Style
                    VStack (spacing: 10) {
                        CustomUIFields.customTextField("First Name", text: $viewModel.firstName)
                            .autocorrectionDisabled(true)

                        CustomUIFields.customTextField("Last Name", text: $viewModel.lastName)
                            .autocorrectionDisabled(true)

                        // Date Picker Styled Like Other Fields
                        HStack {
                            Text("Date of Birth")
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker(
                                "",
                                selection: $viewModel.dateOfBirth,
                                displayedComponents: .date
                            )
                            .labelsHidden().frame(height: 40)
                        }
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
                        CustomUIFields.customTextField("Phone", text: $viewModel.phone)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.phonePad) // Shows phone-specific keyboard

                        // Country Picker Styled Like Other Fields
                        HStack {
                            Picker(selection: $viewModel.country) {
                                ForEach(countries, id: \.self) { country in
                                    Text(country).tag(country)
                                }
                            } label: {
                                Text("Country or region")
                                    .foregroundColor(.primary) // Ensures black text
                            }
                        }.pickerStyle(.navigationLink)
                            .frame(height: 45)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        //.pickerStyle(.navigationLink)
                        
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress) // Shows email-specific keyboard

                        // Password Field with Eye Toggle
                        CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                    }
                    .padding(.horizontal)
                    
                    // "Let's go!" Button
                    Button{
                        print("Create account tapped")
                        
                        // create account is called!
                        Task {
                            do {
                                try await viewModel.signUp(userType: "Coach") // to sign up
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
                    Spacer()
                }
            }
        }
    }    
}

#Preview {
    CoachCreateAccountView(showSignInView: .constant(false))
}
