//
//  UserModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

@MainActor
final class UserModel: ObservableObject {
    
    
    func addUser(userDTO: UserDTO) async throws -> String {
        return try await UserManager.shared.createNewUser(userDTO: userDTO)
    }
    
}
