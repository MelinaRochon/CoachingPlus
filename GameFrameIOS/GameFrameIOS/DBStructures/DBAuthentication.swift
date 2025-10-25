//
//  DBAuthentication.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation

struct DBAuthentication: Codable {
    let id: String
    var email: String
    var password: String
    var isSignedIn: Bool
    
    init(id: String, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
        self.isSignedIn = false
    }
    
    init(id: String, authDTO: AuthenticationDTO) {
        self.id = id
        self.email = authDTO.email
        self.password = authDTO.password
        self.isSignedIn = false
    }
}
