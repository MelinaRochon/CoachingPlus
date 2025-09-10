//
//  FieldsData.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-29.
//

import Foundation

/** A structure containing reusable data that can be accessed and used accross the app. */
struct AppData {
    
    /// A list of supported countries used in forms and selection fields.
    static let countries = ["United States", "Canada", "United Kingdom", "Australia"]
    
    /// A list of available recording options
    static let recordingOptions = ["Video", "Audio Only"]

    /// An array of tuples representing the recording options available on the home page.
    /// Each tuple contains:
    /// - A `String` representing the recording type (e.g., "Video", "Audio Only").
    /// - A `String` representing the corresponding SF Symbol icon name.
    static var recordingHomePageOptions = [("Video", "video.fill"), ("Audio Only", "waveform")] // Dropdown choices with icons
    
    /// Predefined list of age groups for team classification.
    static var ageGroupOptions = [
        "U3", "U4", "U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12",
        "U13", "U14", "U15", "U16", "U17", "U18", "18+", "Senior", "None"
    ]
    
    /// Predefined list of gender options for team categorization.
    static var genderOptions = ["Female", "Male", "Mixed", "Other"]
}
