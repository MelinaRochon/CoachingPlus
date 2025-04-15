//
//  StorageManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import Foundation
import FirebaseStorage


final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    /// Root location of the storage in the database
    let storage = Storage.storage().reference()
    
    func saveAudio() async throws {
//        let meta = StorageMetadata()
//        meta.contentType = "audio/m4a"
        
        let path = "\(UUID().uuidString).m4a"
//        let fileName = UUID().uuidString + ".m4a"
        let audioRef = storage.child("audio/\(path)")
//        let uploadTask = storageRef.putFile(from: localURL, metadata: nil) { metadata, error in
//            if let error = error {
//                print("Upload failed: \(error)")
//                return
//            }
//            
//            storageRef.downloadURL { url, error in
//                if let url = url {
//                    print("File available at: \(url)")
//                }
//            }
//        }
    }
    
    
    func getAudioURL(path: String) -> StorageReference {
        return Storage.storage().reference(withPath: path)
    }
}
