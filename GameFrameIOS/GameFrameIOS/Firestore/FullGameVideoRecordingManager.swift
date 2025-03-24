//
//  FullGameVideoRecordingManager.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation
import FirebaseFirestore

struct DBFullGameVideoRecording: Codable {
    let id: String
    let fullGameVideoRecordingId: String
    let gameId: String
    let uploadedBy: String
    let fileURL: String?
    let startTime: Date
    let endTime: Date?
    let teamId: String
    
    init(id: String,
         fullGameVideoRecordingId: String,
         gameId: String,
         uploadedBy: String,
         fileURL: String?,
         startTime: Date,
         endTime: Date?,
         teamId: String
    ) {
        self.id = id
        self.fullGameVideoRecordingId = fullGameVideoRecordingId
        self.gameId = gameId
        self.uploadedBy = uploadedBy
        self.fileURL = fileURL
        self.startTime = startTime
        self.endTime = endTime
        self.teamId = teamId
    }
    
    init(id: String, fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) {
        self.id = id
        self.fullGameVideoRecordingId = id // fullGameVideoRecordingDTO.fullGameVideoRecordingId
        self.gameId = fullGameVideoRecordingDTO.gameId
        self.uploadedBy = fullGameVideoRecordingDTO.uploadedBy
        self.fileURL = fullGameVideoRecordingDTO.fileURL
        self.startTime = fullGameVideoRecordingDTO.startTime
        self.endTime = fullGameVideoRecordingDTO.endTime
        self.teamId = fullGameVideoRecordingDTO.teamId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullGameVideoRecordingId = "fg_video_recording_id"
        case gameId = "game_id"
        case uploadedBy = "uploaded_by"
        case fileURL = "file_URL"
        case startTime = "start_time"
        case endTime = "end_time"
        case teamId = "team_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.fullGameVideoRecordingId = try container.decode(String.self, forKey: .fullGameVideoRecordingId)
        self.gameId = try container.decode(String.self, forKey: .gameId)
        self.uploadedBy = try container.decode(String.self, forKey: .uploadedBy)
        self.fileURL = try container.decodeIfPresent(String.self, forKey: .fileURL)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        self.teamId = try container.decode(String.self, forKey: .teamId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.fullGameVideoRecordingId, forKey: .fullGameVideoRecordingId)
        try container.encode(self.gameId, forKey: .gameId)
        try container.encode(self.uploadedBy, forKey: .uploadedBy)
        try container.encode(self.fileURL, forKey: .fileURL)
        try container.encode(self.startTime, forKey: .startTime)
        try container.encode(self.endTime, forKey: .endTime)
        try container.encode(self.teamId, forKey: .teamId)
    }
}

final class FullGameVideoRecordingManager {
    static let shared = FullGameVideoRecordingManager()
    private init() {}
    
    /** Returns a specific full game video recording document */
    func fullGameVideoRecordingDocument(teamDocId: String, fgDocId: String) -> DocumentReference {
        return fullGameVideoRecordingCollection(teamDocId: teamDocId).document(fgDocId)
    }
    
    /** Returns the full game video recording collection */
    func fullGameVideoRecordingCollection(teamDocId: String) -> CollectionReference {
        return TeamManager.shared.teamCollection.document(teamDocId).collection("fg_video_recording")
    }
    
    /** Add a full game video recording to the database */
    func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws {
        //Create new full game video recording
        do {
            print("Sending new full game recording to Firestore: \(fullGameVideoRecordingDTO)")
            
            guard let teamDocId = try await TeamManager.shared.getTeam(teamId: fullGameVideoRecordingDTO.teamId)?.id else {
                print("Could not find team id. Aborting")
                return
            }

            let fgvRecordingDocument = fullGameVideoRecordingCollection(teamDocId: teamDocId).document()
            let documentId = fgvRecordingDocument.documentID // get the document id

            // create a new full game video recording object
            let fgvRecording = DBFullGameVideoRecording(id: documentId, fullGameVideoRecordingDTO: fullGameVideoRecordingDTO)
            
            // create a new full game video recording
            try fgvRecordingDocument.setData(from: fgvRecording, merge: false)
            
            print("Full game video recording created!")
        } catch let error as NSError {
            print("Error creating full game video recording: \(error.localizedDescription)")
            throw error
        }
    }
}
