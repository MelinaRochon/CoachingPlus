//
//  Untitled.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-07.
//

import Foundation
import SwiftUI

struct Player {
    var name: String
    var dob: Date
    var jersey: Int
    var gender: Int
    var email: String
    var profilePicture: UIImage?
    
    var defaultProfilePicture: Image {
        if let profilePicture = profilePicture {
            return Image(uiImage: profilePicture)
        } else {
            return Image(systemName: "person.crop.circle"); // Default Apple icon
        }
    }
    
    /* Guardian information */
    // Will be enable if player is less than 16, otherwise disabled
    var guardianName: String
    var guardianEmail: String
    var guardianPhone: String
    
}
