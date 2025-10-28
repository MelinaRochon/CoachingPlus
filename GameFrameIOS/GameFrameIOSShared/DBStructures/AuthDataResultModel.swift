//
//  AuthDataResultModel.swift
//  GameFrameIOSShared
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

/**
 A data model representing authentication details of a signed-in user.
 This structure helps store essential user data retrieved from Firebase.
 */
public struct AuthDataResultModel: Codable {
    public let uid: String
    public var email: String
    public let photoUrl: String?
    
    /// Initializes the model using a Firebase `User` object.
    /// - Parameter user: The authenticated Firebase user.
    public init(user: UserForDB) {
        self.uid = user.uid
        self.email = user.email ?? ""
        self.photoUrl = user.photoURL?.absoluteString
    }
}


public struct UserForDB {
    public let uid: String
    public var email: String?
    public let photoURL: URL?
    
    public init(uid: String, email: String?, photoURL: URL?) {
        self.uid = uid
        self.email = email
        self.photoURL = photoURL
    }
}


public struct AuthPwd: Codable {
    public let id: String
    public let authUserId: String
    public var password: String
    public var isSignedIn: Bool
}
