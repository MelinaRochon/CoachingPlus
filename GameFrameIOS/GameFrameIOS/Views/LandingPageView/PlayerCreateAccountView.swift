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

    let countries = ["United States", "Canada", "United Kingdom", "Australia"]

    var body: some View {
        VStack(spacing: 20) {
            // HEADER
            HStack {
                VStack(alignment: .leading) {
                    Text("GameFrame")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("leveling up your game")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack {
                    Button("Log in") {
                        // Login action here
                    }
                    .foregroundColor(.black)
                    
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 10)

            // Title
            VStack(spacing: 5) {
                Text("Hey Champ!")
                    .font(.title).bold()
                Button(action: {
                    print("Navigate to Log In")
                }) {
                    Text("I already have an account! Log in")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .underline()
                }
            }

//            Spacer().frame(height: 10)

            // Form Fields with Uniform Style
            VStack(spacing: 15) {
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
                .frame(height: 50)
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
                .frame(height: 50)
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
                .frame(height: 50)
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
                .frame(height: 50)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            }
            .padding(.horizontal)

//            Spacer().frame(height: 20)

            // "Get coached!" Button
            Button(action: {
                print("Create account tapped")
            }) {
                HStack {
                    Text("Get coached!")
                        .font(.body).bold()
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    // Custom TextField for Uniform Style
    private func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 50)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
}

#Preview {
    PlayerCreateAccountView()
}
