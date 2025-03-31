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

/** Converts a time interval (in seconds) into a formatted string (HH:MM:SS).
 - Parameter duration: The time interval in seconds.
 - Returns: A formatted string in "HH:MM:SS" format.
 */
func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

/** Converts a time duration from seconds into hours and minutes.
 - Parameter seconds: The total time in seconds.
 - Returns: A tuple containing the equivalent hours (int) and minutes
 */
func convertSecondsToHoursMinutes(seconds: Int) -> (hours: Int, minutes: Int) {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    return (hours, minutes)
}


/***Format the entered phone number to (XXX)-XXX-XXXX
 Formats the given phone number string into a standard phone number format: (XXX)-XXX-XXXX.

 This function takes an unformatted string containing digits and formats it into a phone number format
 that matches the pattern (XXX)-XXX-XXXX, where 'X' represents a digit. Any non-numeric characters
 in the input string will be ignored, and only numeric digits will be used.

 If there are more than 10 digits in the input string, only the first 10 digits are used for formatting.
 If there are fewer than 10 digits, the function will format whatever digits are available and leave
 the remaining positions empty in the result.
 
 - Parameter number: A string representing the phone number, which may contain non-numeric characters.

 - Returns: A string formatted as a phone number in the form of (XXX)-XXX-XXXX.
 
 Examples:
 
    Input: "1234567890"
    Output: "(123)-456-7890"

    Input: "1-234-567-890"
    Output: "(123)-456-7890"
**/
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
