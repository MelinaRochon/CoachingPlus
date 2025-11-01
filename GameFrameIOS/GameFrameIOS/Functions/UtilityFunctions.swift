//
//  UtilityFunctions.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-29.
//
//  This file contains helper functions used throughout the app
//  to improve code reuse and maintainability.
//

import Foundation
import AVFoundation
import GameFrameIOSShared

/// Converts a time interval (in seconds) into a formatted string (HH:MM:SS).
/// - Parameter duration: The time interval in seconds.
/// - Returns: A formatted string in "HH:MM:SS" format.
///
func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}


/// Converts a time duration from seconds into hours and minutes.
/// - Parameter seconds: The total time in seconds.
/// - Returns: A tuple containing the equivalent hours (int) and minutes
///
func convertSecondsToHoursMinutes(seconds: Int) -> (hours: Int, minutes: Int) {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    return (hours, minutes)
}


/// Utility function to filter an array of games based on a search text.
/// The function searches for the `searchText` in the game title, team name, or team nickname.
/// - Parameter games: An array of `HomeGameDTO` objects to be filtered.
/// - Parameter searchText: The text used for filtering the games. The function checks for matches in
///                         the game title, team name, or team nickname.
/// - Returns: A filtered array of `HomeGameDTO` objects that match the search criteria.
///           If the `searchText` is empty, the original `games` array is returned without filtering.
func filterGames(_ games: [HomeGameDTO], with searchText: String) -> [HomeGameDTO] {
    if searchText.isEmpty {
        // If search text is empty, return the original list of games
        return games
    } else {
        // Filter games based on the search text matching the title, team name, or team nickname
        return games.filter { game in
            game.game.title.lowercased().contains(searchText.lowercased()) ||
            game.team.name.lowercased().contains(searchText.lowercased()) ||
            game.team.teamNickname.lowercased().contains(searchText.lowercased())
        }
    }
}


/// Utility function to filter an array of transcripts based on a search text.
/// The function searches for the `searchText` in the transcript title, time (duration), or player name.
/// - Parameter transcripts: An array of `keyMomentTranscript` objects to be filtered.
/// - Parameter game: A `DBGame` object to be used for filterering the duration.
/// - Parameter searchText: The text used for filtering the games. The function checks for matches in
///                         the game title, team name, or team nickname.
/// - Returns: A filtered array of `keyMomentTranscript` objects that match the search criteria.
///           If the `searchText` is empty, the original `transcripts` array is returned without filtering.
func filterTranscripts(_ transcripts: [keyMomentTranscript], _ game: DBGame, with searchText: String) -> [keyMomentTranscript] {
    if searchText.isEmpty {
        // If search text is empty, return the original list of games
        return transcripts
    } else {
        // Filter games based on the search text matching the title, team name, or team nickname
        if let gameStartTime = game.startTime {
            return transcripts.filter { transcript in
                let durationInSeconds = transcript.frameStart.timeIntervalSince(gameStartTime)
                let duration = formatDuration(durationInSeconds)
                
                return transcript.transcript.lowercased().contains(searchText.lowercased()) ||
                duration.contains(searchText)
            }
        }
        
        return transcripts.filter { transcript in
            transcript.transcript.lowercased().contains(searchText.lowercased())
        }
    }
}


/// Format the entered phone number to (XXX)-XXX-XXXX
/// Formats the given phone number string into a standard phone number format: (XXX)-XXX-XXXX.
///
/// This function takes an unformatted string containing digits and formats it into a phone number format
/// that matches the pattern (XXX)-XXX-XXXX, where 'X' represents a digit. Any non-numeric characters
/// in the input string will be ignored, and only numeric digits will be used.
///
/// If there are more than 10 digits in the input string, only the first 10 digits are used for formatting.
/// If there are fewer than 10 digits, the function will format whatever digits are available and leave
/// the remaining positions empty in the result.
///
/// - Parameter number: A string representing the phone number, which may contain non-numeric characters.
/// - Returns: A string formatted as a phone number in the form of (XXX)-XXX-XXXX.
///
/// Examples:
/// ```
///    Input: "1234567890"
///    Output: "(123)-456-7890"
///
///    Input: "1-234-567-890"
///    Output: "(123)-456-7890"
/// ```
func formatPhoneNumber(_ number: String) -> String {
    // Keep only digits
    let digits = number.filter { $0.isNumber }
    
    var result = ""
    let mask = "(XXX)-XXX-XXXX"
    var index = digits.startIndex

    for ch in mask where index < digits.endIndex {
        if ch == "X" {
            result.append(digits[index])
            index = digits.index(after: index)
        } else {
            result.append(ch)
        }
    }
    return result
}

func isValidPhoneNumber(_ number: String) -> Bool {
    if number.isEmpty {
        return true
    }
    let pattern = #"^\(\d{3}\)-\d{3}-\d{4}$"#
    return number.range(of: pattern, options: .regularExpression) != nil
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}

/// A helper function to format the provided start time into a readable string.
/// If the `startTime` is nil, it uses the current date and time as the default value.
///
/// - Parameter startTime: The optional `Date` to be formatted. If nil, the current date and time are used.
/// - Returns: A string representing the formatted date and time, in the format "YYYY-MM-DD HH:mm".
func formatStartTime(_ startTime: Date?) -> String {
    let format = startTime?.formatted(.dateTime.year().month().day().hour().minute()) ??
                Date().formatted(.dateTime.year().month().day().hour().minute())
    return format
}


/// Calculates the aspect ratio of a video from a given URL.
/// - Parameter url: The URL of the video file.
/// - Returns: The aspect ratio as a `CGFloat` (width / height). Defaults to 16:9 if the video track cannot be accessed.
func videoAspectRatio(for url: URL) -> CGFloat {
    let asset = AVAsset(url: url)
    if let track = asset.tracks(withMediaType: .video).first {
        let size = track.naturalSize.applying(track.preferredTransform)
        return abs(size.width / size.height)
    }
    return 16/9 // fallback
}
