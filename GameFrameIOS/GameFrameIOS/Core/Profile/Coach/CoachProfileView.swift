//
//  CoachProfileView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***
 * This structure will show the coach's profile.
 */
struct CoachProfileView: View {
    
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel = CoachProfileViewModel()
    @Binding var showLandingPageView: Bool
    
    @State private var isEditing = false // Edit the profile
    
    @State private var phone: String = ""
    
    // Country and region
    let countryCodes = Locale.isoRegionCodes
    let countryNames: [String]
    
    // Timezone
    let timeZones: [String] = TimeZone.knownTimeZoneIdentifiers.sorted() // Get sorted time zones
    
    @State private var selectedCountry = "Canada" // Default selection
//    var dateRange: ClosedRange<Date> {
//        let min = Calendar.current.date(byAdding: .year, value: -1, to: profile.dob)!
//        let max = Calendar.current.date(byAdding: .year, value: 1, to: profile.dob)!
//        return min...max
//    }
    
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
                                
                                Text(user.userType).font(.subheadline)
                                
                                if let email = user.email {
                                    Text(email).font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom)
                                }
                            }
                            
                        }
                        .frame(maxWidth: .infinity) // Ensures full width for better alignment
                        
                        // Profile information
                        List {
                            Section {
                                
                                if isEditing {
                                    HStack {
                                        Text("Name").foregroundStyle(.secondary)
                                        Spacer()
                                        
                                        //TextField("Name", text: $profile.name)
                                        Text("\(user.firstName) \(user.lastName)")
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    
                                    HStack {
                                        Text("Email").foregroundStyle(.secondary)
                                        Spacer()
                                        if let email = user.email {
                                            Text(email).foregroundStyle(.secondary)
                                                .multilineTextAlignment(.trailing)
                                        }
                                    }
                                }
                                
                                if let dateOfBirth = user.dateOfBirth {
                                    HStack {
                                        Text("Date of birth").foregroundStyle(.secondary)
                                        Spacer()
                                        
                                        Text("\(dateOfBirth.formatted(.dateTime.year().month(.twoDigits).day()))")
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                                
                                HStack {
                                    Text("Phone").foregroundStyle(isEditing ? .primary : .secondary)
                                    Spacer()
                                    TextField("Phone", text: $phone).disabled(!isEditing)
                                        .foregroundStyle(isEditing ? .primary : .secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            
                            Section {
                                HStack {
                                    Text("Country or region").foregroundStyle(.secondary)
                                    Spacer()
                                    Text(user.country)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                                
                                HStack {
                                    Text("Time Zone").foregroundStyle(.secondary)
                                    Spacer()
                                    Text(user.timeZone)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                                 
                            }
                            
                            Section(header: Text("Membership Details")) {
                                HStack {
                                    Text("Payment plan").foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Free").foregroundStyle(.secondary) // TO DO - Will need to modify this!
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
                                                try viewModel.logOut()
                                                showLandingPageView = true
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        .frame(minHeight: 700) // Ensure the list has enough height
                    }
                }.task {
                    print("Loading current user...")
                    // Load the user information on the page
                    try? await viewModel.loadCurrentUser()
                    
                    // Set the data to the one in the database
                    if let user = viewModel.user {
                        phone = user.phone
                    }
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
                        Button(action: editInfo) {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        
    }
    
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
//        if let user = viewModel.user{
//            user.photoUrl = inputImage
//        }
        //profile.profilePicture = inputImage
    }
    
    private func editInfo() {
        withAnimation {
            isEditing.toggle()
        }
    }
    
    private func saveInfo() {
        withAnimation {
            isEditing.toggle()
            viewModel.updateCoachInformation(phone: phone, membershipDetails: "Free")
        }
    }
}


#Preview {
    CoachProfileView(showLandingPageView: .constant(false))
}
