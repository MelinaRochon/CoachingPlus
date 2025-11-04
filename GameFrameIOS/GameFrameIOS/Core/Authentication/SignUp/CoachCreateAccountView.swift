import SwiftUI
import GameFrameIOSShared

/// A view for creating a new Coach account.
///
/// This view presents a form for users to create a new Coach account. It includes various fields such as First Name, Last Name, Date of Birth,
/// Phone, Country, Email, and Password. The view validates the input and allows the user to create an account by signing up. If an account
/// already exists with the provided email, an error alert is shown.
///
/// The form uses custom UI fields, styled consistently across different inputs, and provides a toggle for the password field to show or hide
/// the password. Once the user fills in all the fields, they can press the "Create Account" button to initiate the account creation process.
struct CoachCreateAccountView: View {
    
    // MARK: - State Properties
    /// A boolean to track whether the password is shown or hidden.
    @State private var showPassword: Bool = false
    
    /// View model for handling user authentication and account creation.
    @StateObject private var viewModel = AuthenticationModel()

    @EnvironmentObject private var dependencies: DependencyContainer

    /// A binding boolean to control whether to show the sign-in view.
    @Binding var showSignInView: Bool
    
    /// A boolean to control whether the error alert is shown.
    @State private var showErrorAlert: Bool = false
    
    /// A boolean to control whether the user is redirected to Login.
    @State private var errorGoToLogin: Bool = false
    
    // Detect if the app is running in UI test mode
    private let isUITest = ProcessInfo.processInfo.arguments.contains("UI_TEST_MODE")
        
    // MARK: - View

    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                ScrollView {
                    Spacer().frame(height: 20)
                    VStack(spacing: 5) {
                        Text("Hey Coach!")
                            .font(.title3).bold()
                            .accessibilityIdentifier("page.signup.coach.title")
                        
                        // Text link to navigate to the login screen
                        HStack {
                            Text("I already have an account!")
                                .foregroundColor(.gray)
                                .font(.footnote)
                            
                            NavigationLink(destination: CoachLoginView(showSignInView: $showSignInView)) {
                                CustomUIFields.linkButton("Log in")
                            }
                        }
                    }
                    
                    // Form Fields with Uniform Style
                    VStack (spacing: 10) {
                        // First Name Text Field
                        CustomUIFields.customTextField("First Name", text: $viewModel.firstName)
                            .autocorrectionDisabled(true)
                            .accessibilityIdentifier("page.signup.coach.firstName")

                        // Last Name Text Field
                        CustomUIFields.customTextField("Last Name", text: $viewModel.lastName)
                            .autocorrectionDisabled(true)
                            .accessibilityIdentifier("page.signup.coach.lastName")

                        // Date Picker Styled Like Other Fields
                        HStack {
                            Text("Date of Birth")
//                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker(
                                "",
                                selection: $viewModel.dateOfBirth,
                                in: ...Date(),
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
                        
                        // Phone Number Field
                        CustomUIFields.customTextField("Phone", text: $viewModel.phone)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(.phonePad) // Shows phone-specific keyboard
                            .onChange(of: viewModel.phone) { newVal in
                                // Formats the phone number when it changes
                                viewModel.phone = formatPhoneNumber(newVal)
                            }
                            .accessibilityIdentifier("page.signup.coach.phone")
                        
                        // Country Picker
                        HStack {
                            Text("Country or region")
                                .padding(.horizontal)
                            Spacer()
                            Picker("", selection: $viewModel.country) {
                                ForEach(AppData.countries, id: \.self) { c in
                                    Text(c).tag(c)
                                }
                            }
                            .labelsHidden()
                            .accessibilityIdentifier("page.signup.coach.country")
                        }
                        .frame(height: 45)
                        .pickerStyle(.automatic)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
                        // Email Field
                        CustomUIFields.customTextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .keyboardType(isUITest ? .default : .emailAddress) // Shows email-specific keyboard
                            .accessibilityIdentifier("page.signup.coach.email")
                            .textContentType(isUITest ? .none : .emailAddress)

                        // Password Field with Eye Toggle
                        Group {
                            if isUITest {
                                CustomUIFields.customTextField("Password", text: $viewModel.password)
                                    .accessibilityIdentifier("page.signup.coach.password")
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                            } else {
                                CustomUIFields.customPasswordField("Password", text: $viewModel.password, showPassword: $showPassword)
                                    .accessibilityIdentifier("page.signup.coach.password")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // "Let's go!" Button
                    Button{
                        // Call sign-up method when button is tapped
                        Task {
                            do {
                                // Check if the email already exists
                                guard try await viewModel.verifyEmailAddress() == nil else {
                                    showErrorAlert = true
                                    return
                                }
                                
                                // Attempt to sign up the coach
                                try await viewModel.signUp(userType: .coach)
                                
                                // After successful signup, close the sign-in view
                                showSignInView = false
                                return
                            } catch {
                                print(error) // Handle any errors
                                showErrorAlert = true
                            }
                        }
                    } label: {
                        // Use the custom styled "Create Account" button
                        CustomUIFields.createAccountButton("Create Account")
                    }
                    .disabled(!signUpIsValid)
                    .opacity(signUpIsValid ? 1.0 : 0.5)
                    .accessibilityIdentifier("page.signup.coach.createAccountBtn")
                    
                    Spacer()
                }.alert("Account exists", isPresented: $showErrorAlert){
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
                    CoachLoginView(showSignInView: $showSignInView)
                }
            }
            .onAppear {
                viewModel.setDependencies(dependencies)
            }
        }
    }    
}

// MARK: - SignUp Validation

/// Conformance to AuthenticationSignUpProtocol for validation of sign-up fields.
extension CoachCreateAccountView: AuthenticationSignUpProtocol {
    var signUpWithAccessCodeValid: Bool {
        return true // Access code validation is not required for this view.
    }
    
    var signUpIsValid: Bool {
        // Validation for required fields: Email, Password, First Name, Last Name
        return !viewModel.email.isEmpty && isValidEmail(viewModel.email) // Check for a basic email format
        && viewModel.country != "Select"
        && isValidPhoneNumber(viewModel.phone)
        && !viewModel.password.isEmpty && viewModel.password.count > 5
        && !viewModel.firstName.isEmpty && isValidName(viewModel.firstName)
        && !viewModel.lastName.isEmpty && isValidName(viewModel.lastName)
    }
}

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    CoachCreateAccountView(showSignInView: .constant(false))
}
