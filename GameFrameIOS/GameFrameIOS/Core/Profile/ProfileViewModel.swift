//
//  ProfileViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser() // get user profile
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
