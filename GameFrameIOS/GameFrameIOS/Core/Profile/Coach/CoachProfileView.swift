//
//  CoachProfileView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI


/***
 * This structure represents the coach's profile page.
 * It allows the coach to view and edit their profile information, including their name, email, phone number,
 * country, and other personal details. It also includes options for the coach to log out, reset their password,
 * and upload or modify their profile picture.
 *
 * ## Key Features:
 * - **Profile Picture**: Displays the coach's profile picture, which can be edited by tapping on it.
 *   If no picture is selected, a default system icon is shown.
 * - **Profile Information**: Displays the coach's name, email, phone number, country, and membership details.
 *   If the coach is in editing mode, these fields become editable.
 * - **Edit Mode**: The coach can toggle between viewing and editing mode. In editing mode, they can update
 *   their phone number and other details.
 * - **Buttons**: There are buttons to log out, reset the password, and save changes to the profile.
 *
 * ## View Structure:
 * - **Navigation View**: The root container for navigation in this profile page.
 * - **Profile Picture & Details**: Displays the coach's profile picture (or default icon) and their name, email, and user type.
 *   This section becomes editable when `isEditing` is true.
 * - **Profile Information List**: Displays the coach's personal details like date of birth, phone number, country, and membership details.
 *   The fields are displayed in a `List` where the values can be edited in `isEditing` mode.
 * - **Reset Password and Log Out**: If the coach is not editing their profile, buttons for resetting the password and logging out are shown.
 *
 * ## Fetching and Updating Data:
 * - The `viewModel.loadCurrentUser()` function is called when the view appears to load the current coach's data.
 * - If changes are made in the profile (e.g., phone number), the `viewModel.updateCoachInformation()` function is used to save the updates to the database.
 *
 * ## Usage:
 * - This view is used as the coach's profile page within the app, allowing them to manage their personal information and account settings.
 */struct CoachProfileView: View {
     
     /// Controls whether the image picker is displayed.
     /// This property is set to true when the user taps on the profile picture to change it,
     /// triggering the display of the image picker sheet.
     @State private var showImagePicker: Bool = false
     
     /// Holds the image that the user selects from the image picker.
     /// This image will be used to update the coach's profile picture. It is optional, as the user may choose not to select an image.
     @State private var inputImage: UIImage?
     
     /// Stores the image that is currently displayed on the profile.
     /// Initially, this could be nil or a default profile image, but will be updated once the user selects an image to display.
     @State private var selectedImage: UIImage?
     
     /// An instance of the `CoachProfileViewModel` that is used to manage data fetching and updating for the coach's profile.
     /// This view model will handle tasks like loading user data, updating the user's information, and logging out.
     @StateObject private var viewModel = CoachProfileViewModel()
     @EnvironmentObject private var dependencies: DependencyContainer

     /// A binding to a parent view's state that controls whether the landing page should be shown.
     /// When the coach logs out or other relevant events occur, this binding is set to `true` to navigate the user to the landing page view.
     @Binding var showLandingPageView: Bool
     
     /// A boolean flag that determines whether the profile is in editing mode.
     /// When true, fields such as the phone number become editable, allowing the user to modify their profile information.
     /// When false, the profile is displayed in a non-editable format.
     @State private var isEditing = false
     
     /// Holds the phone number entered by the coach.
     /// This value is updated when the coach enters or modifies their phone number in the profile edit mode.
     @State private var phone: String = ""
     
     /// Country and region-related variables
     let countryCodes = Locale.isoRegionCodes
     
     /// An array of localized country names derived from the ISO region codes.
     let countryNames: [String]
     
     /// Time zone-related variable
     let timeZones: [String] = TimeZone.knownTimeZoneIdentifiers.sorted()
     
     @State private var dob: Date = Date()
     @State private var firstName: String = ""
     @State private var lastName: String = ""

     
     /// State for selecting a country
     @State private var selectedCountry = "Canada"
     
     init(showLandingPageView: Binding<Bool>) {
         self.countryNames = countryCodes.compactMap { code in
             Locale.current.localizedString(forRegionCode: code)
         }.sorted()
         
         self._showLandingPageView = showLandingPageView
     }
     
     var defaultProfilePicture: Image {
         return Image(systemName: "person.crop.circle"); // Default Apple icon
     }
     
     var body: some View {
         NavigationView {
             ScrollView {
                 VStack {
                     if let user = viewModel.user {
                         VStack { // Profile Picture & Details
                             
                             if let selectedImage = inputImage {
                                 Image(uiImage: selectedImage).profileImageStyle()
                             } else {
                                 defaultProfilePicture
                                     .profileImageStyle()
                                     .onTapGesture {
                                         showImagePicker = true
                                     }
                                     .sheet(isPresented: $showImagePicker) {
                                         ImagePicker(image: $inputImage)
                                     }
                             }
                             
                             if !isEditing {
                                 Text("\(user.firstName) \(user.lastName)").font(.title)
                                 Text(user.userType.displayName).font(.subheadline)
                                 Text(user.email).font(.subheadline)
                                     .foregroundStyle(.secondary)
                                     .padding(.bottom)
                             }
                         }
                         .frame(maxWidth: .infinity) // Ensures full width for better alignment
                         
                         // Profile information
                         List {
                             Section {
                                 
                                 if isEditing {
                                     HStack {
                                         Text("First Name")
                                         TextField("First Name", text: $firstName).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                                     }
                                     HStack {
                                         Text("Last Name").foregroundStyle(.primary)
                                         Spacer()
                                         TextField("Last Name", text: $lastName).multilineTextAlignment(.trailing).foregroundStyle(.primary)
                                     }
                                     
                                     HStack {
                                         Text("Email").foregroundStyle(.secondary)
                                         Spacer()
                                         Text(user.email).foregroundStyle(.secondary)
                                             .multilineTextAlignment(.trailing)
                                     }
                                 }
                                 
                                 HStack {
                                     Text("Date of birth").foregroundStyle(isEditing ? .primary : .secondary)
                                     Spacer()
                                     if !isEditing {
                                         if let dateOfBirth = user.dateOfBirth {
                                             Text("\(dateOfBirth.formatted(.dateTime.year().month(.twoDigits).day()))")
                                                 .foregroundStyle(.secondary)
                                                 .multilineTextAlignment(.trailing)
                                         } else {
                                             Text("N/A").foregroundStyle(.secondary)
                                                 .multilineTextAlignment(.trailing)
                                         }
                                     } else {
                                         DatePicker(
                                             "",
                                             selection: $dob,
                                             in: ...Date(),
                                             displayedComponents: .date
                                         )
                                         .labelsHidden().frame(height: 20)
                                     }
                                 }
                                 
                                 HStack {
                                     Text("Phone").foregroundStyle(isEditing ? .primary : .secondary)
                                     Spacer()
                                     TextField("(XXX)-XXX-XXXX", text: $phone).disabled(!isEditing)
                                         .foregroundStyle(isEditing ? .primary : .secondary)
                                         .multilineTextAlignment(.trailing)
                                         .autocapitalization(.none)
                                         .autocorrectionDisabled(true)
                                         .keyboardType(.phonePad)
                                         .onChange(of: phone) { newVal in
                                             phone = formatPhoneNumber(newVal)
                                         }
                                 }
                             }
                             
                             Section {
                                 if let country = user.country {
                                     HStack {
                                         Text("Country or region").foregroundStyle(.secondary)
                                         Spacer()
                                         Text(country)
                                             .foregroundStyle(.secondary)
                                             .multilineTextAlignment(.trailing)
                                     }
                                 }
                             }
                             
                             Section(header: Text("Membership Details")) {
                                 HStack {
                                     Text("Payment plan").foregroundStyle(.secondary)
                                     Spacer()
                                     Text("Free").foregroundStyle(.secondary) // TODO: - Will need to modify this!
                                 }
                             }
                             
                             if !isEditing {
                                 Section {
                                     Button("Reset password") {
                                         Task {
                                             do {
                                                 try await viewModel.resetPassword()
                                                 print("Password reset")
                                             } catch {
                                                 print(error)
                                             }
                                         }
                                     }
                                     
                                     Button("Log out") {
                                         Task {
                                             do {
                                                 try await viewModel.logOut()
                                                 showLandingPageView = true
                                             } catch {
                                                 print("Error when logging out... \(error)")
                                             }
                                         }
                                     }
                                 }
                             }
                             
                         }
                         .frame(minHeight: 700) // Ensure the list has enough height
                     }
                 }
                 .task {
                     print("Loading current user...")
                     // Load the user information on the page
                     try? await viewModel.loadCurrentUser()
                     
                     // Set the data to the one in the database
                     if let user = viewModel.user {
                         if let userPhone = user.phone {
                             phone = userPhone
                         }
                         firstName = user.firstName
                         lastName = user.lastName
                         dob = user.dateOfBirth ?? Date()
                     }
                 }
                 .onAppear {
                     viewModel.setDependencies(dependencies)
                 }
                 
             }
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     if !isEditing {
                         Button(action: editInfo) {
                             Text("Edit")
                         }
                         
                     } else {
                         Button(action: saveInfo) {
                             Text("Save")
                         }
                     }
                 }
                 
                 if isEditing {
                     ToolbarItem(placement: .navigationBarLeading) {
                         Button(action: cancelInfo) {
                             Text("Cancel")
                         }
                     }
                 }
             }
         }
         .accessibilityIdentifier("page.coach.profile")
     }
     
     
     /// Placeholder function for loading the selected image
     func loadImage() {
         guard let inputImage = inputImage else {return}
     }
     
     /// Toggles the editing mode on and off
     private func editInfo() {
         withAnimation {
             isEditing.toggle()
         }
     }
     
     /// Toggles the editing mode on and off and removes all unsaved data
     private func cancelInfo() {
         withAnimation {
             isEditing.toggle()
         }
         
         // Remove unsaved data
         if let user = viewModel.user {
             if let userPhone = user.phone {
                 phone = userPhone
             }
             dob = user.dateOfBirth ?? Date()
             firstName = user.firstName
             lastName = user.lastName
         }
     }
     
     /// Saves the updated profile information when in editing mode
     private func saveInfo() {
         savingPlayerInformation()
         withAnimation {
             isEditing.toggle()
         }
     }
     
     private func savingPlayerInformation() {
         Task {
             if let user = viewModel.user {
                 var userFirstName: String? = firstName
                 var userLastName: String? = lastName
                 var userDateOfBirth: Date? = dob
                 var userphone: String? = phone
                 
                 if firstName == user.firstName {
                     userFirstName = nil
                 }
                 
                 if lastName == user.lastName {
                     userLastName = nil
                 }
                 
                 if dob == user.dateOfBirth {
                     userDateOfBirth = nil
                 }
                 
                 if phone == user.phone {
                     userphone = nil
                 }
                 
                 viewModel.updateCoachSettings(phone: userphone, dateOfBirth: userDateOfBirth, firstName: userFirstName, lastName: userLastName, membershipDetails: "Free")
             }
         }
     }
 }


#Preview {
    CoachProfileView(showLandingPageView: .constant(false))
}
