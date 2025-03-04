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
                        customTextField("First Name", text: $viewModel.firstName)
                        customTextField("Last Name", text: $viewModel.lastName)
                        
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
                        
                        customTextField("Phone", text: $viewModel.phone)
                        
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
                        
                        //customTextField("Email", text: $viewModel.email)
                        TextField("Email", text: $viewModel.email)
                            .frame(height: 45)
                            .padding(.horizontal)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .foregroundColor(.black).autocapitalization(.none)
                        
                        // Password Field Styled Like Other Fields
                        HStack {
                            if showPassword {
                                TextField("Password", text: $viewModel.password).autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $viewModel.password).autocapitalization(.none)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(
                                    systemName: showPassword ? "eye.slash" : "eye"
                                )
                                .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
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
                        //NavigationLink(destination: CoachMainTabView(showLandingPageView: $showSignInView)){
                        HStack {
                            Text("Create Account")
                                .font(.body).bold()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        //}
                        .padding(.horizontal)
                    }
                    Spacer()
                }
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
    CoachCreateAccountView(showSignInView: .constant(false))
}
