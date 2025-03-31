//
//  InviteModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

@MainActor
final class InviteModel: ObservableObject {
    
    func addInvite(inviteDTO: InviteDTO) async throws -> String {
        return try await InviteManager.shared.createNewInvite(inviteDTO: inviteDTO)
    }
}
