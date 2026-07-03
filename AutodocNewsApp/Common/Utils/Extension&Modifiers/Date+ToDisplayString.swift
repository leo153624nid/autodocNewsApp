//
//  Date+ToDisplayString.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

extension Date {
    /// Date string for display (dd.MM.yyyy)
    func toDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    /// Date string for display (month name and day)
    func toMonthDayDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL d"
        return formatter.string(from: self)
    }
    
    /// Time string for display (hours:minutes AM/PM)
    func toTimeDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Date string for display (Month Day or Today or Yesterday)
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
