import SwiftUI

struct PlayerCreateAccountView: View {
    @State private var teamAccessCode: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var phone: String = ""
    @State private var country: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    @Binding var showSignInView: Bool
    
    let countries = ["United States", "Canada", "United Kingdom", "Australia"]
    
    var body: some View {
        NavigationView{
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
                    VStack(spacing: 10) {
                        // Team Access Code with Help Button
                        HStack {
                            TextField("Team Access Code", text: $teamAccessCode)
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
                        
                        customTextField("First Name", text: $firstName)
                        customTextField("Last Name", text: $lastName)
                        
                        // Date Picker Styled Like Other Fields
                        HStack {
                            Text("Date of Birth")
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                .labelsHidden()
                        }
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        
                        customTextField("Phone", text: $phone)
                        
                        // Country Picker Styled Like Other Fields
                        HStack {
                            Text("Country")
                                .foregroundColor(country.isEmpty ? .gray : .black)
                            Spacer()
                            Menu {
                                ForEach(countries, id: \.self) { countryOption in
                                    Button(action: { country = countryOption }) {
                                        Text(countryOption)
                                    }
                                }
                            } label: {
                                Text(country.isEmpty ? "Select" : country)
                                    .foregroundColor(country.isEmpty ? .gray : .black)
                            }
                        }
                        .frame(height: 45)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        
                        customTextField("Email", text: $email)
                        
                        // Password Field Styled Like Other Fields
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
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
                    Button(action: {
                        print("Create player account tapped")
                    }) {
                        HStack {
                            Text("Create Account")
                                .font(.body).bold()
                            //Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        
                    }
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
    PlayerCreateAccountView(showSignInView: .constant(false))
}
