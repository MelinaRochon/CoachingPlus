//
//  RootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import SwiftUI

/// Root view of the app. It manages the display of either the home page or the landing page based on the user's authentication status.
struct RootView: View {
    
    // MARK: - State Properties

    /// State variable to track if the user is signed in or not.
    /// If true, show the sign-in page (landing page). If false, show the home page.
    @State private var showSignInView: Bool = false
        
    // MARK: - View

    var body: some View {
        ZStack {
            if !showSignInView {
                    // Passing the binding to control the sign-in view display
                    UserTypeRootView(showSignInView: $showSignInView)
                .tint(.red)
            }
        }
        .onAppear {
            // Check if the user is authenticated when the view appears
            if CommandLine.arguments.contains("RESET_DATA") {
                // For UI testing, always start with reset_data
                self.showSignInView = true
            } else {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                // Set the sign-in view state based on user authentication status
                self.showSignInView = authUser == nil
            }
        }
        // Show full-screen cover for landing page if the user is not authenticated
        .fullScreenCover(isPresented: $showSignInView) {
            // The landing page view that allows the user to sign in or sign up
            NavigationStack {
                LandingPageView(showSignInView: $showSignInView)
            }.tint(.red)
        }
    }
}

#Preview {
    RootView()
}
