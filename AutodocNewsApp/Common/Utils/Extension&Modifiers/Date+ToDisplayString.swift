//
//  Date+ToDisplayString.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

extension Date {
    /// Formats the date as `dd.MM.yyyy`.
    /// - Returns: Formatted date string.
    func toDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    /// Formats the date as full month name and day.
    /// - Returns: Formatted date string.
    func toMonthDayDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL d"
        return formatter.string(from: self)
    }
    
    /// Formats the time as `h:mm a`.
    /// - Returns: Formatted time string.
    func toTimeDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Returns "Today", "Yesterday", or a `dd.MM.yyyy` string for older dates.
    /// - Returns: Localized section header string.
    func toSectionHeaderString() -> String {
        return if Calendar.current.isDateInToday(self) {
            "date.today".localized
        } else if Calendar.current.isDateInYesterday(self) {
            "date.yesterday".localized
        } else {
            toDisplayString()
        }
    }
    
}
