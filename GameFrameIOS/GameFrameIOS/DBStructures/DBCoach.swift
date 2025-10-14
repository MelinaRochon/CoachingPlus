//
//  DBCoach.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-13.
//

import Foundation

/// Data Transfer Object (DTO) for representing a coach in the database.
/// This struct models the data for a coach, including their unique identifier, coach ID, and the list of teams they are coaching.
/// It conforms to the `Codable` protocol to allow easy encoding and decoding from and to Firestore documents.
struct DBCoach: Codable {
    let id: String
    let coachId: String
    var teamsCoaching: [String]?
    
    // Initializer to create a DBCoach with optional teamsCoaching
    init(id: String, coachId: String, teamsCoaching: [String]? = nil) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = teamsCoaching
    }

    // Initializer for creating a DBCoach with no teamsCoaching
    init(id: String, coachId: String) {
        self.id = id
        self.coachId = coachId
        self.teamsCoaching = []
    }

    // Initializer to create a DBCoach using a `CoachDTO`
    init(id: String, coachDTO: CoachDTO) {
        self.id = id
        self.coachId = coachDTO.coachId
        self.teamsCoaching = coachDTO.teamsCoaching
    }
    
    // Custom initializer to decode DBCoach from Firestore document
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.coachId = try container.decode(String.self, forKey: .coachId)
        self.teamsCoaching = try container.decodeIfPresent([String].self, forKey: .teamsCoaching)
    }
    
    // Enum for the Firestore keys used to encode and decode DBCoach
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case coachId = "coach_id"
        case teamsCoaching = "teams_coaching"
    }
    
    // Custom method to encode DBCoach into Firestore document
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.coachId, forKey: .coachId)
        try container.encodeIfPresent(self.teamsCoaching, forKey: .teamsCoaching)
    }
}
