//
//  AddNewFGVideoRecordingModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import SwiftUI

@MainActor
final class AddNewFGVideoRecordingModel: ObservableObject {    
    @Published var fileURL = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var gameId: String = ""
    
    func createFGRecording(teamId: String?) async throws -> Bool {
        do {
            //get coach id
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let coachId = authUser.uid

            guard teamId != nil else {
                print("no team id. aborting..")
                return false
            }
                        
            let newFGVideoRecording = FullGameVideoRecordingDTO(
                gameId: gameId,
                uploadedBy: coachId,
                fileURL: fileURL,
                startTime: Date(),
                endTime: nil, // TO DO - we don't know yet the end time of the video recording
                teamId: teamId!
            )

            //create new recording
            try await FullGameVideoRecordingManager.shared.addFullGameVideoRecording(fullGameVideoRecordingDTO: newFGVideoRecording)
            return true
        } catch {
            print("Failed to create team: \(error.localizedDescription)")
            return false
        }
    }
    
    func test() {
        print("fileURL: \(fileURL), startTime: \(startTime), endTime: \(endTime)")
    }
}
