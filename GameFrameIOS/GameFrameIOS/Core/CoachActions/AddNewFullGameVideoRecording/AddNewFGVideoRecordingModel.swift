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
    @Published var fullGameVideoRecording: DBFullGameVideoRecording? = nil
    
    @Published var fileURL = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    
    //@Published var
    func createFGRecording(gameId: String) async throws -> Bool{
        do{
            //get game id from parameter
            
            //get coach id
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            print(authUser)
            let coachId = authUser.uid
            print(coachId)
            
//            guard !startTime.isEmpty else {
//                print("Not all fields are filled. Cannot proceed,")
//                return false
//            }
            
            //dto
            let newFGVideoRecording = FullGameVideoRecordingDTO(
                fullGameVideoRecordingId: UUID().uuidString,
                gameId: gameId,
                uploadedBy: coachId,
                fileURL: fileURL,
                startTime: startTime,
                endTime: endTime
            )
            
            //create new recording
            try await FullGameVideoRecordingManager.shared.addFullGameVideoRecording(coachId: coachId, gameId: gameId, fullGameVideoRecordingDTO: newFGVideoRecording)
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
