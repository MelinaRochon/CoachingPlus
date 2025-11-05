//
//  DBUser.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-02.
//

import Foundation

/// Represents a user in the Firebase database.
/// This structure conforms to the Codable protocol to allow encoding and decoding to/from JSON.
public struct DBUser: Codable {
    public let id: String
    public var userId: String?
    public var email: String
    public var photoUrl: String?
    public let dateCreated: Date
    public var userType: UserType
    public var firstName: String
    public var lastName: String
    public var dateOfBirth: Date?
    public var phone: String?
    public var country: String?
    
    // Initializes a user from Firebase authentication details.
    public init(auth: AuthDataResultModel, userType: UserType) {
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
    
    // Initializes a user from a UserDTO object.
    public init(id: String, userDTO: UserDTO) {
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
    
    // Custom initialization with all fields.
    public init(
        id: String,
        userId: String? = nil,
        email: String,
        photoUrl: String? = nil,
        dateCreated: Date,
        userType: UserType,
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
    
    // Enum to match keys used in the Firebase database.
    public enum CodingKeys: String, CodingKey {
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
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.userType = try container.decode(UserType.self, forKey: .userType)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
    }
    
    public func encode(to encoder: any Encoder) throws {
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

/// Represents a user's group membership.
public struct GrpMembership {
    public let id: String
    public let paymentPlan: String
    public let dateJoined: Date
}
