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
    
    init(id: String,
         fullGameVideoRecordingId: String,
         gameId: String,
         uploadedBy: String,
         fileURL: String?,
         startTime: Date,
         endTime: Date?
    ) {
        self.id = id
        self.fullGameVideoRecordingId = fullGameVideoRecordingId
        self.gameId = gameId
        self.uploadedBy = uploadedBy
        self.fileURL = fileURL
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(id: String, fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) {
        self.id = id
        self.fullGameVideoRecordingId = fullGameVideoRecordingDTO.fullGameVideoRecordingId
        self.gameId = fullGameVideoRecordingDTO.gameId
        self.uploadedBy = fullGameVideoRecordingDTO.uploadedBy
        self.fileURL = fullGameVideoRecordingDTO.fileURL
        self.startTime = fullGameVideoRecordingDTO.startTime
        self.endTime = fullGameVideoRecordingDTO.endTime
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullGameVideoRecordingId = "fg_video_recording_id"
        case gameId = "game_id"
        case uploadedBy = "uploaded_by"
        case fileURL = "file_URL"
        case startTime = "start_time"
        case endTime = "end_time"
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
    }
}

final class FullGameVideoRecordingManager {
    static let shared = FullGameVideoRecordingManager()
    private init() {}
    
    let fullGameVideoRecordingCollection = Firestore.firestore().collection("fg_video_recording")
    
    /** Returns a specific full game video recording document */
    private func fullGameVideoRecordingDocument(id: String) -> DocumentReference {
        fullGameVideoRecordingCollection.document(id)
    }
    
    /** Add a new full game video recording in the database */
    func addFullGameVideoRecording(fullGameVideoRecording: DBFullGameVideoRecording) async throws {
        //Create new full game video recording
        try fullGameVideoRecordingDocument(id: fullGameVideoRecording.fullGameVideoRecordingId).setData(from: fullGameVideoRecording, merge: false)
    }
}
