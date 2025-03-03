//
//  RootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import SwiftUI

struct RootView: View {
    // If the user has an account and is logged in, then show home page, otherwise, show landing page
    @State private var showSignInView: Bool = false
    
    // Home Screen will be based according to the user type
    //@State private var userType: String = "Coach" // TO DO - Add Enum for Coach and Player
    
    var body: some View {
        ZStack {
            NavigationStack {
                //if (userType == "Coach") {
                    //CoachProfileView(profile: .constant(.init(name: "Testing", dob: Date(), email: "example@example.com", phone: "613-555-5555", country: "Canada", timezone: "America/New_York")), showLandingPageView: $showSignInView)
                //} else if (userType == "Player") {
                    PlayerMainTabView(showLandingPageView: $showSignInView)
                //}
            }
        }.onAppear(){
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                LandingPageView(showSignInView: $showSignInView) // show the landing page
                //CoachAuthenticationView(showSignInView: $showSignInView) // show the landing page
            }
        }
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RootView()
}
