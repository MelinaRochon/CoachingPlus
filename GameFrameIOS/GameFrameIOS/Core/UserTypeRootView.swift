//
//  UserTypeRootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import SwiftUI

/// View that serves as the root screen after sign-in, directing users to either the coach or player main screen based on their user type.
struct UserTypeRootView: View {
    
    // MARK: - State Properties

    /// Binding to manage the visibility of the sign-in page. Passed from the parent view.
    @Binding var showSignInView: Bool
    
    /// State variable that stores the user type (e.g., "Coach" or "Player").
    @State private var userType: String = ""
    
    // MARK: - View

    var body: some View {
        ZStack {
            // Conditional rendering based on the user type.
            // If user is a Coach, show CoachMainTabView. If user is a Player, show PlayerMainTabView.
            // If userType is empty or loading, no screen is shown.
            if userType == "Coach" {
                // Display the main tab view for the Coach if the user is identified as a Coach.
                CoachMainTabView(showLandingPageView: $showSignInView)
            } else if (userType == "Player") {
                // Display the main tab view for the Player if the user is identified as a Player.
                PlayerMainTabView(showLandingPageView: $showSignInView)
            } else {
                // Empty view during the loading state or if the user type isn't determined yet.
                // Could also be used to show a loading spinner or message if needed.
                CustomUIFields.loadingSpinner("Starting app...")
            }
        }
        .onAppear {
            // This block runs when the view appears on screen.
            // It makes an asynchronous call to fetch the user type from the UserManager.
            Task {
                do {
                    // Attempt to fetch the user type asynchronously using UserManager.
                    let type = try await UserManager.shared.getUserType() // get user type
                    
                    // Update the userType state with the fetched type (either "Coach" or "Player").
                    self.userType = type
                } catch {
                    // Handle any error that may occur when fetching the user type.
                    print(error)
                }
            }
        }
    }
}

#Preview {
    UserTypeRootView(showSignInView: .constant(false))
}
