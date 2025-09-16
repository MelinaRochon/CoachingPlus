//
//  StorageManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-15.
//

import Foundation
import FirebaseStorage


/// A singleton class responsible for managing Firebase Storage operations
/// related to audio files. Provides methods to save, fetch, and delete
/// audio files within Firebase Storage.
///
/// - Note: This class uses a shared instance for convenience: `StorageManager.shared`.
///         All Firebase Storage paths are relative to the root storage reference.
final class StorageManager {
    
    /// Shared singleton instance for global access
    static let shared = StorageManager()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Root reference of Firebase Storage
    let storage = Storage.storage().reference()
       
    
    /// Uploads a local audio file to Firebase Storage at the specified path and returns the download URL.
    ///
    /// - Parameters:
    ///   - localFile: The `URL` of the local audio file to upload.
    ///   - path: The storage path where the audio file should be uploaded
    ///           (e.g., "audio/{gameId}/{playerId}.m4a").
    ///   - completion: A closure called when the upload finishes. Returns a `Result` containing:
    ///       - `.success(URL)` with the download URL if the upload succeeds.
    ///       - `.failure(Error)` if the upload fails at any point.
    /// - Note: The function first uploads the file using `putFile(from:metadata:)` and
    ///         then fetches the download URL with `downloadURL`.
    func uploadAudioFile(localFile: URL, path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Create a reference to the location in Firebase Storage
        let audioRef = StorageManager.shared.storage.child(path)

        // Upload the file to the storage
        let uploadTask = audioRef.putFile(from: localFile, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Once uploaded, get the download URL
            audioRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let downloadURL = url {
                    completion(.success(downloadURL))
                }
            }
        }
    }
    
    
    /// Returns a Firebase Storage reference to an audio file at the specified path.
    ///
    /// - Parameter path: The full storage path of the audio file (e.g., "audio/{gameId}/{playerId}.m4a").
    /// - Returns: A `StorageReference` pointing to the specified audio file in Firebase Storage.
    /// - Note: This function does not fetch the file itself; it only returns a reference.
    func getAudioURL(path: String) -> StorageReference {
        return Storage.storage().reference(withPath: path)
    }
    
    
    /// Deletes an audio file from Firebase Storage at the specified path.
    ///
    /// - Parameters:
    ///   - path: The full storage path of the audio file to delete (e.g., "audio/{gameId}/{playerId}.m4a").
    ///   - completion: A closure called when the deletion completes. Returns an optional `Error`
    ///                 if the deletion failed, or `nil` if it succeeded.
    /// - Note: This function performs the deletion asynchronously and calls the completion handler
    ///         on the main thread once the operation is finished.
    func deleteAudio(path: String, completion: @escaping (Error?) -> Void) {
        let ref = Storage.storage().reference(withPath: path)
        ref.delete { error in
            completion(error)
        }
    }

    
    /// Recursively deletes all audio files under a specific folder path in Firebase Storage.
    ///
    /// - Parameters:
    ///   - folderPath: The path to the folder whose contents should be deleted.
    ///   - completion: A closure called when the deletion completes. Returns an optional `Error`
    ///                 if any deletion failed, or `nil` if all deletions succeeded.
    ///
    /// - Note: This method will delete all files and subfolders recursively. If any single
    ///         deletion fails, the last encountered error is returned in the completion handler.
    func deleteAllAudioUnderPath(in folderPath: String, completion: @escaping (Error?) -> Void) {
        let folderRef = Storage.storage().reference(withPath: folderPath)

        folderRef.listAll { (result, error) in
            if let error = error {
                completion(error)
                return
            }

            guard let result = result else {
                completion(nil) // nothing to delete
                return
            }

            let group = DispatchGroup()
            var lastError: Error?

            for item in result.items {
                group.enter()
                item.delete { error in
                    if let error = error {
                        lastError = error
                    }
                    group.leave()
                }
            }

            for prefix in result.prefixes {
                group.enter()
                self.deleteAllAudioUnderPath(in: prefix.fullPath) { error in
                    if let error = error {
                        lastError = error
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(lastError) // nil if all successful
            }
        }
    }
}
