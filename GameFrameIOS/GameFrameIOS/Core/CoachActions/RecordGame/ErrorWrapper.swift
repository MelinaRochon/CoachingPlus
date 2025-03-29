//
//  ErrorWrapper.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-28.
//

import Foundation

/** This structure is an error wrapper */
struct ErrorWrapper: Identifiable {
    let id: UUID
    let error: Error
    let guidance: String

    init(id: UUID = UUID(), error: Error, guidance: String) {
        self.id = id
        self.error = error
        self.guidance = guidance
    }
}
