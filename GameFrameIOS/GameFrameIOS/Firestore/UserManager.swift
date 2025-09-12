//
//  UserManager.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import Foundation
import FirebaseFirestore

/// Represents a user in the Firebase database.
/// This structure conforms to the Codable protocol to allow encoding and decoding to/from JSON.
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
    
    // Initializes a user from Firebase authentication details.
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
    
    // Initializes a user from a UserDTO object.
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
    
    // Custom initialization with all fields.
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
    
    // Enum to match keys used in the Firebase database.
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

/// Represents a user's group membership.
struct GrpMembership {
    let id: String
    let paymentPlan: String
    let dateJoined: Date
}

/// Manages user-related operations such as retrieving, creating, and updating users.
final class UserManager {
    
    static let shared = UserManager()
    private init() { } // TODO: - Will need to use something else than singleton
    
    
    /// Reference to the users collection in Firestore.
    private let userCollection = Firestore.firestore().collection("users")
    
    /// Returns a reference to a specific user document by ID.
    /// - Parameter id: The unique identifier of the user.
    /// - Returns: A reference to the user's document in Firestore.
    private func userDocument(id: String) -> DocumentReference {
        userCollection.document(id)
    }
            
    
    /**
     GET - Retrieves the authenticated user's type from the database.
     - Throws: An error if the user is not authenticated or if retrieval fails.
     - Returns: The user type (e.g., "coach", "player").
    */
    func getUserType() async throws -> String {
        // returns the user type!
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        return try await getUser(userId: authUser.uid)!.userType
    }
    
    
    /**
     POST - Creates a new user in the database.
     - Parameter userDTO: The data transfer object containing user information to be saved.
     - Throws: An error if the user creation fails.
     - Returns: The document ID of the newly created user.
     */
    func createNewUser(userDTO: UserDTO) async throws -> String {
        let userDocument = userCollection.document()
        let documentId = userDocument.documentID // get the document id
        
        // create a user object
        let user = DBUser(id: documentId, userDTO: userDTO)
        try userDocument.setData(from: user, merge: false)
        
        return documentId
    }
        
    
    /**
     GET - Retrieves user information from the database by user ID.
     - Parameter userId: The unique user ID.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if the user is not found.
     */
    func getUser(userId: String) async throws -> DBUser? {
        let snapshot = try await userCollection.whereField("user_id", isEqualTo: userId).getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)

    }
    
    
    /**
     GET - Retrieves user information from the database using document ID.
     - Parameter id: The document ID of the user.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if not found.
     */
    func getUserWithDocId(id: String) async throws -> DBUser? {
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }

    
    /**
     GET - Retrieves user information by their email address.
     - Parameter email: The user's email address.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user information, or nil if the user is not found.
     */
    func getUserWithEmail(email: String) async throws -> DBUser? {
        let snapshot = try await userCollection.whereField("email", isEqualTo: email).getDocuments()
        
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: DBUser.self)
    }
    
    
    /**
     PUT - Updates the coach's profile in the user collection.
     - Parameter user: The DBUser object containing the updated user information.
     - Throws: An error if the update fails.
     */
    func updateCoachProfile(user: DBUser) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.phone.rawValue: user.phone,
            DBUser.CodingKeys.dateOfBirth.rawValue: user.dateOfBirth
        ]
        
        try await userDocument(id: user.id).updateData(data as [AnyHashable : Any])
    }
    
    
    /// Updates a coach's settings in the database with any provided non-nil values.
    /// - Parameters:
    ///   - id: The unique identifier of the coach's user document.
    ///   - phone: Optional updated phone number.
    ///   - dateOfBirth: Optional updated date of birth.
    ///   - firstName: Optional updated first name.
    ///   - lastName: Optional updated last name.
    ///   - membershipDetails: Optional updated membership details (currently unused).
    /// - Throws: Rethrows any errors that occur during the Firestore update operation.
    func updateCoachSettings(id: String, phone: String?, dateOfBirth: Date?, firstName: String?, lastName: String?, membershipDetails: String?) async throws {
        var data: [String: Any] = [:]
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
        
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update in updatePlayerInfo")
            return
        }
        
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }

    
    /**
     GET - Finds a user by document ID.
     - Parameter id: The unique document ID of the user.
     - Throws: An error if retrieval fails.
     - Returns: The DBUser object containing the user's information, or nil if not found.
     */
    func findUserWithId(id: String) async throws -> DBUser? {
        return try await userDocument(id: id).getDocument(as: DBUser.self)
    }
    
    
    /**
     PUT - Updates user details in the database.
     - Parameters:
        - id: The unique document ID of the user to update.
        - email: The new email address.
        - userTpe: The new user type (e.g., "coach", "player").
        - firstName: The new first name.
        - lastName: The new last name.
        - dob: The new date of birth.
        - phone: The new phone number (optional).
        - country: The new country (optional).
        - userId: The Firebase user ID.
     - Throws: An error if the update fails.
     */
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
    
    func updateUserDOB(id: String, dob: Date) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.dateOfBirth.rawValue: dob,
        ]
        
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
    
    
    func updateUserSettings(id: String, dateOfBirth: Date?, firstName: String?, lastName: String?, phone: String?) async throws {
        var data: [String: Any] = [:]
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
        // Only update if data is not empty
        guard !data.isEmpty else {
            print("No changes to update")
            return
        }
        
        try await userDocument(id: id).updateData(data as [AnyHashable : Any])
    }
}
