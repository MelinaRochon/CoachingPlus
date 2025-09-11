//
//  RootView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import SwiftUI

/// Root view of the app. It manages the display of either the home page or the landing page based on the user's authentication status.
struct RootView: View {
    
    // MARK: - State Properties

    /// State variable to track if the user is signed in or not.
    /// If true, show the sign-in page (landing page). If false, show the home page.
    @State private var showSignInView: Bool = false
        
    // MARK: - View

    var body: some View {
        ZStack {
            if !showSignInView {
                    // Passing the binding to control the sign-in view display
                    UserTypeRootView(showSignInView: $showSignInView)
                .tint(.red)
            }
        }
        .onAppear {
            // Check if the user is authenticated when the view appears
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            // Set the sign-in view state based on user authentication status
            self.showSignInView = authUser == nil
//            
//            Task {
//                do {
//                    try await endRecording()
//                    
//                } catch {
//                    print("\(error)")
//                }
//            }
        }
        // Show full-screen cover for landing page if the user is not authenticated
        .fullScreenCover(isPresented: $showSignInView) {
            // The landing page view that allows the user to sign in or sign up
            NavigationStack {
                LandingPageView(showSignInView: $showSignInView)
            }.tint(.red)
        }
    }
    
//    private func endRecording() async throws {
////        let audioURL = URL(fileURLWithPath: "/Users/melina_rochon/Library/Developer/CoreSimulator/Devices/FA1F232C-56E4-4236-B408-CDDF90C3F447/data/Containers/Data/Application/55697331-1F14-4225-82C3-7A2F203DDB43/Documents/\("test29").m4a")
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        let audioFilename = "test29.m4a"
//
//        // Construct the full local file URL
//        let localURL = documentsPath.appendingPathComponent(audioFilename)
//
//        uploadAudioFile(localFile: localURL, fileName: "coach_feedback_test.m4a") { result in
//            switch result {
//            case .success(let url):
//                print("Audio uploaded! File available at: \(url)")
//            case .failure(let error):
//                print("Upload failed: \(error.localizedDescription)")
//            }
//        }
//
//    }
//    
//    func uploadAudioFile(localFile: URL, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        // 1. Create a reference to the location in Firebase Storage
////        let storageRef = Storage.storage().reference().child("audio/\(fileName)")
//        
//        let fileName = "\(UUID().uuidString).m4a"
//        let path = "audio/\(teamId)/\(gameId/)/\(keyMomentId)/\(fileName)"
//        let audioRef = StorageManager.shared.storage.child(path)
//
////        let bucket = "gs://gameframe-4ea7d.firebasestorage.app"
////        let storagePath = "\(bucket)/audio/\(fileName)"
//        
//        // 2. Upload the file
//        let uploadTask = audioRef.putFile(from: localFile, metadata: nil) { metadata, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            // 3. Once uploaded, get the download URL
//            audioRef.downloadURL { url, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                if let downloadURL = url {
//                    completion(.success(downloadURL))
//                }
//            }
//        }
//    }
}

#Preview {
    RootView()
}
