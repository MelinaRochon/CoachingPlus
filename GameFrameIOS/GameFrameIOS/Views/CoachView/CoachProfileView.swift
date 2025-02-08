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
    
    init(profile: Binding<CoachProfile>) {
        self._profile = profile
        self.countryNames = countryCodes.compactMap { code in
            Locale.current.localizedString(forRegionCode: code)
        }.sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                // profile picture
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
                }
                //.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                    .background(Color.white) // Set background color to white for the List
            }
            .toolbar {
                EditButton(); // button to edit the profile page
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        profile.profilePicture = inputImage
    }
}


#Preview {
    CoachProfileView(profile: .constant(.init(name: "John Doe", dob: Date(), email: "example@example.com", phone: "613-555-5555", country: "Canada", timezone: "America/New_York")))
}
