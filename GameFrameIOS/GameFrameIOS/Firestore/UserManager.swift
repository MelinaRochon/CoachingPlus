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
    let userId: String
    let email: String?
    var photoUrl: String?
    let dateCreated: Date?
    let userType: String
    var firstName: String
    var lastName: String
    var dateOfBirth: Date?
    var phone: String
    var country: String
    var timeZone: String
    
    init(auth: AuthDataResultModel, userType: String) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.userType = userType
        self.firstName = ""
        self.lastName = ""
        self.dateOfBirth = Date()
        self.country = ""
        self.phone = ""
        self.timeZone = ""
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        userType: String,
        firstName: String,
        lastName: String,
        dateOfBirth: Date? = nil,
        phone: String,
        country: String,
        timeZone: String
    ) {
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
        self.timeZone = timeZone
    }
    
    enum CodingKeys: String, CodingKey {
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
        case timeZone = "time_zone"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.userType = try container.decode(String.self, forKey: .userType)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.country = try container.decode(String.self, forKey: .country)
        self.timeZone = try container.decode(String.self, forKey: .timeZone)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.userType, forKey: .userType)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encode(self.phone, forKey: .phone)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.timeZone, forKey: .timeZone)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { } // TO DO - Will need to use something else than singleton
    
    
    private let userCollection = Firestore.firestore().collection("users") // user collection
    
    /** Returns the user document */
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    /** Create an encoder to send data to the database, using the snake case convertion (ex. user_id) */
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
    
    /** Create a decoder to fetch data from Database, using the snake case convertion */
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    /** Get user type */
    func getUserType() async throws -> String {
        // returns the user type!
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        return try await getUser(userId: authUser.uid).userType
    }
    
    /** Creates a new user in the database */
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    /** Gets the user information from the database */
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }

}
