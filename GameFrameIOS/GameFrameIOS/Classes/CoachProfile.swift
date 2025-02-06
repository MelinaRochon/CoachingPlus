//
//  CoachProfile.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-06.
//

import Foundation
import SwiftUI

struct CoachProfile {
    //var id: Int
    var name: String
    var dob: Date
    var email: String
    var phone: String
    var country: String
    var timezone: String
    //var hasProfilePicture: Bool
    var profilePicture: UIImage?
    
    var defaultProfilePicture: Image {
        if let profilePicture = profilePicture {
            return Image(uiImage: profilePicture)
        } else {
            return Image(systemName: "person.crop.circle"); // Default Apple icon
        }
    }    
}
