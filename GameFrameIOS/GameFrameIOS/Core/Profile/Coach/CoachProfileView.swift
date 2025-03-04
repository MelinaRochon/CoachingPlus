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
    @Binding var profile: CoachProfile;
    
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var selectedImage: UIImage?
    
    @StateObject private var viewModel = CoachProfileViewModel()
    @Binding var showLandingPageView: Bool
    //@StateObject private var viewModel = ProfileViewModel()

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
    
    var body: some View {
        //NavigationStack {
            ScrollView {
                VStack {
                    if let user = viewModel.user {
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
                            
                            Text("\(user.firstName) \(user.lastName)").font(.title)
                            
                            //if let userType = user.userType {
                            Text(user.userType).font(.subheadline)
                            //}
                            
                            if let email = user.email {
                                Text(email).font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom)
                            }
                            
                        }
                        .frame(maxWidth: .infinity) // Ensures full width for better alignment
                        
                        // Profile information
                        List {
                            Section {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    
                                    //TextField("Name", text: $profile.name)
                                    Text("\(user.firstName) \(user.lastName)")
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }.disabled(true)
                                
                                if let dateOfBirth = user.dateOfBirth {
                                    HStack {
                                        Text("Date of birth")
                                        Spacer()
                                        
                                        //TextField("Name", text: $profile.name)
                                        Text("\(dateOfBirth.formatted(.dateTime.year().month(.twoDigits).day()))")
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }.disabled(true)
//                                DatePicker(selection: $profile.dob, in: dateRange, displayedComponents: .date) {
//                                    DatePicker(selection: dateOfBirth, in: dateRange, displayedComponents: .date) {
//
//                                        Text("Date of birth")
//                                    }.disabled(true)
                                }
                                
                                
                                
                                
                                HStack {
                                    Text("Email")
                                    Spacer()
                                    if let email = user.email {
                                        Text(email).foregroundStyle(.secondary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    //TextField("Email", text: $profile.email)
//                                        .foregroundStyle(.secondary)
//                                        .multilineTextAlignment(.trailing)
                                }.disabled(true)
                                
                                HStack {
                                    Text("Phone")
                                    Spacer()
                                    //TextField("Phone", text: $profile.phone)
                                    Text(user.phone)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }.disabled(true)
                            }
                            
                            Section {
                                HStack {
                                    Text("Country or region")
                                    Spacer()
                                    //TextField("Phone", text: $profile.phone)
                                    Text(user.country)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }.disabled(true)
                                
                                HStack {
                                    Text("Time Zone")
                                    Spacer()
                                    //TextField("Phone", text: $profile.phone)
                                    Text(user.timeZone)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }.disabled(true)
                                /*Picker("Country or region", selection: $profile.country) {
                                    ForEach(countryNames, id: \.self) { c in
                                        Text(c).tag(c)
                                    }
                                }
                                
                                 HStack {
                                     Text("Phone")
                                     Spacer()
                                     //TextField("Phone", text: $profile.phone)
                                     Text(user.phone)
                                         .foregroundStyle(.secondary)
                                         .multilineTextAlignment(.trailing)
                                 }.disabled(true)
                                Picker("Time Zone", selection: $profile.timezone) {
                                    ForEach(timeZones, id: \.self) { timezone in
                                        Text(timezone).tag(timezone)
                                    }
                                }*/
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
                                
                                //if let user = viewModel.user {
                                Text("UserId: \(user.userId)")
                                
                                
                                
                                //}
                            }
                            
                        }
                        .frame(minHeight: 700) // Ensure the list has enough height
                    }
                }.task {
                    print("Loading current user...")
                    try? await viewModel.loadCurrentUser()
                }
                
            }
            .toolbar {
                EditButton()
            }
       // }
    }

    
    
    
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        profile.profilePicture = inputImage
    }
}


#Preview {
    CoachProfileView(profile: .constant(.init(name: "John Doe", dob: Date(), email: "example@example.com", phone: "613-555-5555", country: "Canada", timezone: "America/New_York")), showLandingPageView: .constant(false))
}
