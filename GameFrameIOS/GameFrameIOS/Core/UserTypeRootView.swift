//
//  UserTypeRootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import SwiftUI
import GameFrameIOSShared

/// View that serves as the root screen after sign-in, directing users to either the coach or player main screen based on their user type.
struct UserTypeRootView: View {
    
    // MARK: - State Properties

    /// Binding to manage the visibility of the sign-in page. Passed from the parent view.
    @Binding var showSignInView: Bool
    
    /// State variable that stores the user type (e.g., "Coach" or "Player").
    @State private var userType: UserType = .unknown // = ""
    @EnvironmentObject var dependencies: DependencyContainer
    @StateObject private var userManager: UserManager

    /// Currently signed-in Firebase user id (UID). Needed by CoachMainTabView.
    @State private var uidAuthUser: String?

    init(showSignInView: Binding<Bool>, container: DependencyContainer) {
        self._showSignInView = showSignInView
        self._userManager = StateObject(wrappedValue: UserManager(repo: container.userRepository))
    }

    // MARK: - View

    var body: some View {
        ZStack {
            // Conditional rendering based on the user type.
            // If user is a Coach, show CoachMainTabView. If user is a Player, show PlayerMainTabView.
            // If userType is empty or loading, no screen is shown.
            if userType == .coach {
                // Display the main tab view for the Coach if the user is identified as a Coach.
                if let uid = uidAuthUser {
                    CoachMainTabView(showLandingPageView: $showSignInView, coachId: uid)
                } else {
                    CustomUIFields.loadingSpinner("Loading coach…")
                        .accessibilityIdentifier("userTypeRoot.loadingCoach.spinner")
                }
            } else if (userType == .player) {
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
                    let authUser = try dependencies.authenticationManager.getAuthenticatedUser()
                    if authUser.uid == "" {
                        self.userType = .unknown
                        // TODO: Show error
                        return
                    }
                    self.uidAuthUser = authUser.uid
                    guard let type = try await dependencies.userManager.getUser(userId: authUser.uid) else {
                        self.userType = .unknown
                        // TODO: Show error
                        return
                    } // get user type
                    
                    // Update the userType state with the fetched type (either "Coach" or "Player").
                    self.userType = type.userType
                } catch {
                    // Handle any error that may occur when fetching the user type.
                    print(error)
                }
            }
        }
    }
}
