//
//  DBAuthentication.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

public struct DBAuthentication: Codable {
    public let id: String
    public var email: String
    public var password: String
    public var isSignedIn: Bool
    
    public init(id: String, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
        self.isSignedIn = false
    }
    
    public init(id: String, authDTO: AuthenticationDTO) {
        self.id = id
        self.email = authDTO.email
        self.password = authDTO.password
        self.isSignedIn = false
    }
}
