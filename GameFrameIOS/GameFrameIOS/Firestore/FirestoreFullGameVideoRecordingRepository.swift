//
//  FirestoreFullGameVideoRecordingRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreFullGameVideoRecordingRepository: FullGameVideoRecordingRepository {
    
    /**
     * Returns a reference to a specific full game video recording document in Firestore.
     * - Parameters:
     *   - teamDocId: The document ID of the team to which the video recording belongs.
     *   - fgDocId: The document ID of the full game video recording.
     * - Returns: A `DocumentReference` pointing to the specified full game video recording document in Firestore.
     */
    public func fullGameVideoRecordingDocument(teamDocId: String, fgDocId: String) -> DocumentReference {
        return fullGameVideoRecordingCollection(teamDocId: teamDocId).document(fgDocId)
    }
    
    
    /**
     * Returns a reference to the full game video recording collection for a specific team.
     * - Parameters:
     *   - teamDocId: The document ID of the team to which the video recordings belong.
     * - Returns: A `CollectionReference` to the team's full game video recording collection in Firestore.
     */
    public func fullGameVideoRecordingCollection(teamDocId: String) -> CollectionReference {
        let teamRepo = FirestoreTeamRepository() // direct repo
        return teamRepo.teamCollection().document(teamDocId).collection("fg_video_recording")
    }
    
    
    /// Fetches a full game video recording document by its ID
    public func getFullGameVideo(teamDocId: String, fullGameId: String) async throws -> DBFullGameVideoRecording? {
        // Retrieve the document from Firestore and decode it into DBFullGameVideoRecording
        return try await fullGameVideoRecordingDocument(teamDocId: teamDocId, fgDocId: fullGameId).getDocument(as: DBFullGameVideoRecording.self)
    }
    
    
    // MARK: - Public Methods
    
    /// Creates and saves a new full game video recording in Firestore
    public func addFullGameVideoRecording(fullGameVideoRecordingDTO: FullGameVideoRecordingDTO) async throws -> String? {
        do {
            // Log the recording we are about to send
            print("Sending new full game recording to Firestore: \(fullGameVideoRecordingDTO)")
            
            // Fetch the team document ID from TeamManager using the teamId
            guard let teamDocId = try await FirestoreTeamRepository().getTeam(teamId: fullGameVideoRecordingDTO.teamId)?.id else {
                print("Could not find team id. Aborting")
                return nil
            }
            
            // Create a new Firestore document reference in the collection
            let fgvRecordingDocument = fullGameVideoRecordingCollection(teamDocId: teamDocId).document()
            let documentId = fgvRecordingDocument.documentID // Extract Firestore-generated ID
            
            // Build the DB object from the DTO
            let fgvRecording = DBFullGameVideoRecording(id: documentId, fullGameVideoRecordingDTO: fullGameVideoRecordingDTO)
            
            // Save the object in Firestore
            try fgvRecordingDocument.setData(from: fgvRecording, merge: false)
            
            print("Full game video recording created!")
            return documentId
        } catch let error as NSError {
            // Catch Firestore or encoding errors
            print("Error creating full game video recording: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    /// Updates an existing full game video recording with new data
    public func updateFullGameVideoRecording(fullGameId: String, teamDocId: String, endTime: Date, path: String) async throws {
        // Ensure the full game video recording exists before updating
        guard let fullGame = try await getFullGameVideo(teamDocId: teamDocId, fullGameId: fullGameId) else {
            print("Could not find full game video recording document. Aborting")
            return
        }
        
        // Build dictionary of fields to update (end time + file URL)
        let data: [String:Any] = [
            DBFullGameVideoRecording.CodingKeys.endTime.rawValue: endTime,
            DBFullGameVideoRecording.CodingKeys.fileURL.rawValue: path
        ]
        
        // Push the update to Firestore
        try await fullGameVideoRecordingDocument(teamDocId: teamDocId, fgDocId: fullGameId).updateData(data as [AnyHashable: Any])
    }
    
    
    /// Fetches a full game video recording using the game ID instead of the recording ID
    public func getFullGameVideoWithGameId(teamDocId: String, gameId: String) async throws -> DBFullGameVideoRecording? {
        // Query the collection for documents matching the game_id field
        let query = try await fullGameVideoRecordingCollection(teamDocId: teamDocId).whereField("game_id", isEqualTo: gameId).getDocuments()
        
        // Return the first matching document (if any), decoded into DBFullGameVideoRecording
        guard let doc = query.documents.first else { return nil }
        return try doc.data(as: DBFullGameVideoRecording.self)
    }
    
    public func doesFullGameVideoExistsWithGameId(teamDocId: String, gameId: String, teamId: String) async throws -> Bool {
        let fileUrl = "full_game/\(teamId)/\(gameId).mov"
        // Query the collection for documents matching the game_id field
        let query = try await fullGameVideoRecordingCollection(teamDocId: teamDocId).whereField("game_id", isEqualTo: gameId).whereField("file_url", isEqualTo: fileUrl).getDocuments()
        
        return !query.documents.isEmpty
    }
}
