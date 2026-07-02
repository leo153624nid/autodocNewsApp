//
//  String+ISOstringToDate.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

extension String {
    
    /// ISO string convert to Date
    /// - Returns: date (optional)
    func isoStringToDate() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
            
        // С таймзоной + дробные секунды
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: self) { return date }
        
        // С таймзоной без дробных секунд
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: self) { return date }
        
        // Без таймзоны — через DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: self) { return date }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: self) { return date }
        
        return nil
    }
}
