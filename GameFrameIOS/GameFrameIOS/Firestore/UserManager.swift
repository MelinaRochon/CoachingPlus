//
//  UserManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
import FirebaseFirestore

struct DBUser {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let userType: String?
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    func createNewUser(auth: AuthDataResultModel, userType: String) async throws {
        var userData: [String:Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp(),
            "user_type": userType
        ]
        
        if let email = auth.email {
            userData["email"] = email
        }
        
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        // Create a new user, with the document id set as the user id
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        
        // Access the user document
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        // Get the user
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            // Can't get data from dictionary
            throw URLError(.badServerResponse) // TO DO - Create custom throw error
        }
        
        
        let email = data["email"] as? String
        let photoUrl = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        let userType = data["user_type"] as? String
        
        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated, userType: userType)
    }
}
