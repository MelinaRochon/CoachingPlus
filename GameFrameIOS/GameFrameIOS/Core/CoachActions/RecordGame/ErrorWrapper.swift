//
//  ErrorWrapper.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-28.
//

/**This file defines a structure called `ErrorWrapper`, which is used to wrap an error along
  with additional guidance to provide context or instructions related to the error.
  It is useful in handling errors with meaningful explanations or steps for resolution.

  ## Purpose:
  The `ErrorWrapper` structure is designed to be used when an error needs to be reported
  alongside contextual guidance that helps users or developers understand how to address the
  issue. It can be useful for UI alerts or logging, where providing actionable feedback
  to the user is important.

  ## Key Features:
  - Wraps an `Error` with an `id` for unique identification.
  - Includes a `guidance` string that provides instructions or suggestions related to the error.
*/

import Foundation

/**
  The `ErrorWrapper` structure encapsulates an error and provides additional guidance to help
  the user or developer understand the error context and steps to resolve or handle it.
  
  - `id`: A unique identifier for the error instance.
  - `error`: The actual error that occurred.
  - `guidance`: A string providing contextual guidance or instructions to address the error.
*/
struct ErrorWrapper: Identifiable {
    
    /// A unique identifier for each error instance.
    let id: UUID
    
    /// The actual error that was encountered.
    let error: Error
    
    /// Guidance or instructions on how to resolve or handle the error.
    let guidance: String

    /// Initializes a new instance of the `ErrorWrapper` structure.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the error instance (default is a new UUID).
    ///   - error: The error to be wrapped.
    ///   - guidance: The guidance text to help resolve or understand the error.
    init(id: UUID = UUID(), error: Error, guidance: String) {
        self.id = id
        self.error = error
        self.guidance = guidance
    }
}
