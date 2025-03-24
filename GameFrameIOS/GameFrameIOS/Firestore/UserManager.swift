//
//  UserManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
import FirebaseFirestore

// Codable: Allows to convert and deconvert the structure
struct DBUser: Codable {
    let id: String
    let userId: String?
    let email: String
    var photoUrl: String?
    let dateCreated: Date
    let userType: String
    var firstName: String
    var lastName: String
    var dateOfBirth: Date?
    var phone: String?
    var country: String?
    
    init(auth: AuthDataResultModel, userType: String) {
        self.id = ""
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.userType = userType
        self.firstName = ""
        self.lastName = ""
        self.dateOfBirth = Date()
        self.country = nil
        self.phone = nil
    }
    
    init(id: String, userDTO: UserDTO) {
        self.id = id
        self.userId = userDTO.userId
        self.email = userDTO.email
        self.photoUrl = userDTO.photoUrl
        self.dateCreated = Date()
        self.userType = userDTO.userType
        self.firstName = userDTO.firstName
        self.lastName = userDTO.lastName
        self.dateOfBirth = userDTO.dateOfBirth
        self.country = userDTO.country
        self.phone = userDTO.phone
    }
    
    init(
        id: String,
        userId: String? = nil,
        email: String,
        photoUrl: String? = nil,
        dateCreated: Date,
        userType: String,
        firstName: String,
        lastName: String,
        dateOfBirth: Date? = nil,
        phone: String? = nil,
        country: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.userType = userType
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.country = country
        self.phone = phone
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case userType = "user_type"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case phone = "phone"
        case country = "country"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.userType = try container.decode(String.self, forKey: .userType)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encode(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encode(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.userType, forKey: .userType)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.phone, forKey: .phone)
        try container.encodeIfPresent(self.country, forKey: .country)
    }
    
}

struct GrpMembership {
    let id: String
    let paymentPlan: String
    let dateJoined: Date
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    /** Returns the user collection */
    private let userCollection = Firestore.firestore().collection("users") // user collection
    
    /** Returns the user document */
    private func userDocument(id: String) -> DocumentReference {
        userCollection.document(id)
    }
            
    /** GET - Get user type */
    func getUserType() async throws -> String {
        // returns the user type!
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        return try await getUser(userId: authUser.uid)!.userType
    }
    
    /** POST - Creates a new user in the database */
    func createNewUser(userDTO: UserDTO) async throws -> String {
        let userDocument = userCollection.document()
        let documentId = userDocument.documentID // get the document id
        
        // create a user object
        let user = DBUser(id: documentId, userDTO: userDTO)
        try userDocument.setData(from: user, merge: false)
        
        return documentId
    }
        
    /** GET - Gets the user information from the database */
    func getUser(userId: String) async throws -> DBUser? {
        let snapshot = try await userCollection.whereField("user_id", isEqualTo: userId).getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)

    }
    
    /** GET - Gets the user information from the database */
    func getUserWithDocId(id: String) async throws -> DBUser? {
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }

    /** GET - Returns the user information from the user's email address */
    func getUserWithEmail(email: String) async throws -> DBUser? {
        let snapshot = try await userCollection.whereField("email", isEqualTo: email).getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)
    }
    
    /** PUT - Update the coach profile on the user collection from the database */
    func updateCoachProfile(user: DBUser) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.phone.rawValue: user.phone
        ]
        
        // TO DO - Update this function!!!! Currently not working....
        
//        try await userDocument().updateData(data as [AnyHashable : Any])

//        try await userDocument(userId: user.userId).updateData(data as [AnyHashable : Any])
    }
    
    /** GET - Get the user information from its user doc id */
    func findUserWithId(id: String) async throws -> DBUser? {
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }
    
    /** PUT - Update the user DTO in the database */
    func updateUserDTO(id: String, email: String, userTpe: String, firstName: String, lastName: String, dob: Date, phone: String?, country: String?, userId: String) async throws {
        
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
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
}
