//
//  CoachProfileView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

@MainActor
/** Observable object to be called when the coach wants to perform one of the following action: logOut, reset password. */
final class CoachProfileViewModel: ObservableObject {
    
    /** To log out the user */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    /** To reset the user's password **/
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // TO DO - Create error
        }
        
        // Make sure the DISPLAY_NAME of the app on firebase to the public is set properly
        try await AuthenticationManager.shared.resetPassword(email: email) // NEED TO VERIFY USER GETS EMAIL
    }
}

/***
 * This structure will show the coach's profile.
 */
struct CoachProfileView: View {
    @Binding var profile: CoachProfile;
    
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel = CoachProfileViewModel()
    @Binding var showLandingPageView: Bool
    
    // Country and region
    let countryCodes = Locale.isoRegionCodes
    let countryNames: [String]
    
    // Timezone
    let timeZones: [String] = TimeZone.knownTimeZoneIdentifiers.sorted() // Get sorted time zones

    @State private var selectedCountry = "Canada" // Default selection
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: profile.dob)!
        let max = Calendar.current.date(byAdding: .year, value: 1, to: profile.dob)!
            return min...max
        }
    
    init(profile: Binding<CoachProfile>, showLandingPageView: Binding<Bool>) {
        self._profile = profile
        self.countryNames = countryCodes.compactMap { code in
            Locale.current.localizedString(forRegionCode: code)
        }.sorted()
        
        self._showLandingPageView = showLandingPageView
    }
    
    /*var body: some View {
        NavigationStack {
            VStack{
                VStack {// profile picture
                    if let selectedImage = inputImage {
                        Image(uiImage: selectedImage).profileImageStyle()
                    } else {
                        profile.defaultProfilePicture
                            .profileImageStyle()
                            .onTapGesture {
                                showImagePicker = true
                            }
                        //.onChange(of: inputImage) {_ in loadImage()}
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(image: $inputImage)
                            }
                    }
                    
                    Text(profile.name).font(.title)
                    Text("Coach").font(.subheadline)
                    Text(profile.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                    
                }
                
                // Profile information
                List {
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Name", text: $profile.name).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }.disabled(true)
                        
                        DatePicker(selection: $profile.dob, in: dateRange, displayedComponents: .date) {
                            Text("Date of birth")
                        }.disabled(true)
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            TextField("Email", text: $profile.email).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }.disabled(true)
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            TextField("Phone", text: $profile.phone).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                        }.disabled(true)
                    }
                    
                    Section {
                        Picker("Country or region", selection: $profile.country) {
                            ForEach(countryNames, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        
                        // Time Zone Picker
                        Picker("Time Zone", selection: $profile.timezone) {
                            ForEach(timeZones, id: \.self) { timezone in
                                Text(timezone).tag(timezone)
                            }
                        }
                    }
                    
                    Section(header: Text("Membership Details")) {
                        HStack {
                            Text("Group Memberships")
                        }
                    }
                    
                    Section {
                        
                        // Reset password button
                        HStack {
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
                        }
                        
                        // Logout button
                        HStack {
                            Button("Log out") {
                                Task {
                                    do {
                                        try viewModel.logOut()
                                        showLandingPageView = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                        
                    }
                    //Spacer().padding(.bottom, 130).listStyle(PlainListStyle())
                }.safeAreaInset(edge: .bottom) { // Pushes list content above the tab bar
                    Color.clear.frame(height: 130) // Adjust height based on your tab bar size
                }
                
                //.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                    //.background(Color.white) // Set background color to white for the List
            }
            .toolbar {
                EditButton(); // button to edit the profile page
            }
        } }*/
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack { // Profile Picture & Details
                        if let selectedImage = inputImage {
                            Image(uiImage: selectedImage).profileImageStyle()
                        } else {
                            profile.defaultProfilePicture
                                .profileImageStyle()
                                .onTapGesture {
                                    showImagePicker = true
                                }
                                .sheet(isPresented: $showImagePicker) {
                                    ImagePicker(image: $inputImage)
                                }
                        }

                        Text(profile.name).font(.title)
                        Text("Coach").font(.subheadline)
                        Text(profile.email).font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity) // Ensures full width for better alignment
                    
                    // Profile information
                    List {
                        Section {
                            HStack {
                                Text("Name")
                                Spacer()
                                TextField("Name", text: $profile.name)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }.disabled(true)

                            DatePicker(selection: $profile.dob, in: dateRange, displayedComponents: .date) {
                                Text("Date of birth")
                            }.disabled(true)

                            HStack {
                                Text("Email")
                                Spacer()
                                TextField("Email", text: $profile.email)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }.disabled(true)

                            HStack {
                                Text("Phone")
                                Spacer()
                                TextField("Phone", text: $profile.phone)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }.disabled(true)
                        }

                        Section {
                            Picker("Country or region", selection: $profile.country) {
                                ForEach(countryNames, id: \.self) { c in
                                    Text(c).tag(c)
                                }
                            }

                            Picker("Time Zone", selection: $profile.timezone) {
                                ForEach(timeZones, id: \.self) { timezone in
                                    Text(timezone).tag(timezone)
                                }
                            }
                        }

                        Section(header: Text("Membership Details")) {
                            HStack {
                                Text("Group Memberships")
                            }
                        }

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
                                        try viewModel.logOut()
                                        showLandingPageView = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minHeight: 700) // Ensure the list has enough height
                }
            }
            .toolbar {
                EditButton()
            }
        }
    }

    
    
    
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        profile.profilePicture = inputImage
    }
}


#Preview {
    CoachProfileView(profile: .constant(.init(name: "John Doe", dob: Date(), email: "example@example.com", phone: "613-555-5555", country: "Canada", timezone: "America/New_York")), showLandingPageView: .constant(false))
}
