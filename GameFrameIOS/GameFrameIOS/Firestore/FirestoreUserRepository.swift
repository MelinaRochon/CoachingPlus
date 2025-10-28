//
//  FirestoreUserRepository.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation
import FirebaseFirestore
import GameFrameIOSShared

public final class FirestoreUserRepository: UserRepository {
    
    /// Reference to the users collection in Firestore.
    private let userCollection = Firestore.firestore().collection("users")
    
    /// Returns a reference to a specific user document by ID.
    private func userDocument(id: String) -> DocumentReference {
        userCollection.document(id)
    }
    
    public func createNewUser(userDTO: UserDTO) async throws -> String {
        // Create a new Firestore document with a generated ID
        let userDocument = userCollection.document()
        let documentId = userDocument.documentID
        
        // Build DBUser object from DTO
        let user = DBUser(id: documentId, userDTO: userDTO)
        
        // Save to Firestore
        try userDocument.setData(from: user, merge: false)
        
        return documentId
    }
        
    public func getUser(userId: String) async throws -> DBUser? {
        // Query Firestore for the user with a specific `user_id` field
        let snapshot = try await userCollection.whereField("user_id", isEqualTo: userId).getDocuments()
        
        // Return the first document if available
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)
    }
    
    public func getUserWithDocId(id: String) async throws -> DBUser? {
        // Directly fetch a user document by its document ID
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }

    public func getUserWithEmail(email: String) async throws -> DBUser? {
        // Query Firestore for a user with the given email
        let snapshot = try await userCollection.whereField("email", isEqualTo: email).getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)
    }
    
    public func updateCoachProfile(user: DBUser) async throws {
        // Prepare the fields we want to update
        let data: [String: Any] = [
            DBUser.CodingKeys.phone.rawValue: user.phone,
            DBUser.CodingKeys.dateOfBirth.rawValue: user.dateOfBirth
        ]
        
        // Update Firestore document
        try await userDocument(id: user.id).updateData(data as [AnyHashable : Any])
    }
    
    public func updateCoachSettings(id: String, phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) async throws {
        var data: [String: Any] = [:]
        
        // Add only the non-nil values to the update dictionary
        if let phone = phone {
            data[DBUser.CodingKeys.phone.rawValue] = phone
        }
        if let dateOfBirth = dateOfBirth {
            data[DBUser.CodingKeys.dateOfBirth.rawValue] = dateOfBirth
        }
        if let firstName = firstName {
            data[DBUser.CodingKeys.firstName.rawValue] = firstName
        }
        if let lastName = lastName {
            data[DBUser.CodingKeys.lastName.rawValue] = lastName
        }
        
        print("data is \(data)")
        
        // Skip update if no values were provided
        guard !data.isEmpty else {
            print("No changes to update in updatePlayerInfo")
            return
        }
        
        // Push updates to Firestore
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    public func findUserWithId(id: String) async throws -> DBUser? {
        // Fetch user document by document ID
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }
    
    public func updateUserDTO(id: String, email: String, userTpe: UserType, firstName: String, lastName: String, dob: Date, phone: String?, country: String?, userId: String) async throws {
        // Build dictionary with all new values
        let data: [String: Any] = [
            DBUser.CodingKeys.userId.rawValue: userId,
            DBUser.CodingKeys.email.rawValue: email,
            DBUser.CodingKeys.userType.rawValue: userTpe,
            DBUser.CodingKeys.firstName.rawValue: firstName,
            DBUser.CodingKeys.lastName.rawValue: lastName,
            DBUser.CodingKeys.dateOfBirth.rawValue: dob,
            DBUser.CodingKeys.phone.rawValue: phone ?? "",
            DBUser.CodingKeys.country.rawValue: country ?? ""
        ]
        
        // Push update to Firestore
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    public func updateUserDOB(id: String, dob: Date) async throws {
        // Update only the date of birth field
        let data: [String: Any] = [
            DBUser.CodingKeys.dateOfBirth.rawValue: dob,
        ]
        
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    public func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        var data: [String: Any] = [:]
        
        // Add only provided fields to update
        if let dateOfBirth = dateOfBirth {
            data[DBUser.CodingKeys.dateOfBirth.rawValue] = dateOfBirth
        }
        if let firstName = firstName {
            data[DBUser.CodingKeys.firstName.rawValue] = firstName
        }
        if let lastName = lastName {
            data[DBUser.CodingKeys.lastName.rawValue] = lastName
        }
        if let phone = phone {
            data[DBUser.CodingKeys.phone.rawValue] = phone
        }
        
        print("data is \(data) in updateUserSettings")
        
        // Skip update if dictionary is empty
        guard !data.isEmpty else {
            print("No changes to update")
            return
        }
        
        // Push changes to Firestore
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
}
