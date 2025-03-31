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

}
