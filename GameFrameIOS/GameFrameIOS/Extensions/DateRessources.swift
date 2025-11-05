//
//  DateExtension.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import Foundation

/// Extension on `Date` to assist with week-based calculations,
/// such as determining the start and end of a week and calculating the number of weeks between dates.
extension Date {
    
    /// Returns the date corresponding to the **start of the week** (typically Monday) for the current date.
    ///
    /// - Parameter calendar: The calendar to use for the calculation. Defaults to `.current`.
    /// - Returns: A `Date` representing the start of the week.
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    
    /// Returns the date corresponding to the **end of the week** (typically Sunday) for the current date.
    ///
    /// - Parameter calendar: The calendar to use for the calculation. Defaults to `.current`.
    /// - Returns: A `Date` representing the end of the week (6 days after the start of the week).
    func endOfWeek(using calendar: Calendar = .current) -> Date {
        let start = self.startOfWeek(using: calendar)
        return calendar.date(byAdding: .day, value: 6, to: start)!
    }
    
    
    /// Calculates the number of weeks between the current date and another reference date.
    ///
    /// - Parameter date: The reference date to compare to.
    /// - Returns: The number of whole weeks between the current date and the reference date.
    ///   A return value of `0` means the date is in the same week as the reference,
    ///   `1` means it is one week before, and so on.
    func weeksAgo(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelfWeek = self.startOfWeek()
        let startOfReferenceWeek = date.startOfWeek()
        return calendar.dateComponents([.weekOfYear], from: startOfSelfWeek, to: startOfReferenceWeek).weekOfYear ?? 0
    }
}
