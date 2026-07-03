//
//  Date+ISOstring.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

extension Date {
    /// ISO 8601 date string using the device's local time zone.
    /// - Returns: Formatted date string (e.g. `2026-07-03T12:00:00+03:00`).
    func isoString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"

        return formatter.string(from: self)
    }
    
    /// ISO 8601 date string in UTC.
    /// - Returns: Formatted date string (e.g. `2026-07-03T09:00:00Z`).
    func isoStringUTC() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        return formatter.string(from: self)
    }
}
