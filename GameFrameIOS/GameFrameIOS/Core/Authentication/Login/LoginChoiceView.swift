//
//  LoginChoiceView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

/// A view that allows the user to choose between logging in as a "Coach" or "Player".
/// This view provides two options, each leading to a different login screen depending on the user type selected.
///
/// - `showSignInView`: A binding boolean value that controls whether the sign-in view is displayed. It is passed to the child views to manage the state of the sign-in process.
struct LoginChoiceView: View {
    
    /// A binding to control the visibility of the sign-in view.
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    Spacer().frame(height: 50)
                    
                    // A section for call to action prompting the user to choose their role
                    VStack(spacing: 10) {
                        Text("Log in as a..") // Title prompting user to choose role
                            .font(.title3)
                            .fontWeight(.bold)
                            .accessibilityIdentifier("loginChoicePage.title")
                        
                        // Horizontal stack with buttons to choose "Coach" or "Player"
                        HStack(spacing: 10) {
                            // Navigation link for "Coach" selection
                            NavigationLink(destination: CoachLoginView(showSignInView: $showSignInView)) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .accessibilityIdentifier("loginChoicePage.login.coach.btn")
                            }
                            
                            // Navigation link for "Player" selection
                            NavigationLink(destination: PlayerLoginView(showSignInView: $showSignInView)) {
                                Text("Player")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .accessibilityIdentifier("loginChoicePage.login.player.btn")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoginChoiceView(showSignInView: .constant(false))
}
