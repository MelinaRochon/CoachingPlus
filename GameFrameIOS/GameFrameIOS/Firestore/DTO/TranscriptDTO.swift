//
//  TranscriptDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import Foundation


/// Data Transfer Object (DTO) representing a transcript associated with a key moment in a game. This struct encapsulates the details about a transcription,
/// including the language, the confidence of the transcription, and the game it belongs to.
///
/// The `TranscriptDTO` is used to store and transfer data related to a game's key moment transcription. It provides the transcription text, metadata such as
/// language and confidence, and information about the game and key moment to which it is linked.
///
/// ### Properties:
/// - `keyMomentId`: The unique identifier for the key moment the transcription is associated with. This is a required field to link the transcript to a specific
///   moment in the game.
/// - `transcript`: The actual text of the transcription. This field is required and contains the transcribed dialogue or commentary related to the key moment.
/// - `language`: The language of the transcription. This field is currently limited to "English," but can be expanded in the future to support other languages.
/// - `generatedBy`: The identifier or name of the entity (e.g., system, user) who generated the transcription. This is a required field.
/// - `confidence`: A measure of how confident the system is in the accuracy of the transcription. It is typically a percentage (e.g., 90 for 90% confidence).
/// - `gameId`: The unique identifier for the game the transcript is associated with. This is a required field to link the transcript to a specific game.
struct TranscriptDTO {
    
    /// The unique identifier for the key moment this transcription is associated with. This field is required and helps link the transcript to a specific moment.
    let keyMomentId: String
    
    /// The actual transcription text for the key moment. This field is required and contains the transcribed dialogue or commentary.
    let transcript: String
    
    /// The language in which the transcript was generated. This field is currently set to "English" for the supported language, but future implementations could
    /// support other languages.
    let language: String
    
    /// The identifier or name of the entity (such as the system or a user) that generated the transcript. This field is required.
    let generatedBy: String
    
    /// The confidence level of the transcription, usually a percentage indicating how sure the system is about the transcription's accuracy.
    /// This field is required and helps evaluate the reliability of the transcription.
    let confidence: Int
    
    /// The unique identifier for the game associated with this transcript. This field is required to link the transcript to the specific game.
    let gameId: String
}
