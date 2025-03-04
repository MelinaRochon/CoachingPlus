//
//  UserTypeRootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-04.
//

import SwiftUI

struct UserTypeRootView: View {
    @Binding var showSignInView: Bool
    
    // Home Screen will be based according to the user type
    @State private var userType: String = "Coach"
    
    var body: some View {
        ZStack {
            if userType == "Coach" {
                CoachMainTabView(showLandingPageView: $showSignInView)
            } else {
                PlayerMainTabView(showLandingPageView: $showSignInView)
            }
        }
        .onAppear {
            Task {
                do {
                    let type = try await UserManager.shared.getUserType() // get user type
                    print("Change page according to user type.!! \(type)")
                    self.userType = type // set the user type accordingly
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    UserTypeRootView(showSignInView: .constant(false))
}
