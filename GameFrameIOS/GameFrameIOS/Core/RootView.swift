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
        
    var body: some View {
        ZStack {
            
            if !showSignInView {
                NavigationStack {
                    UserTypeRootView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            // Check if the user is authenticated or not
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                LandingPageView(showSignInView: $showSignInView) // show the landing page
            }
        }
    }
}

#Preview {
    RootView()
}
