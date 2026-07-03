//
//  NewsItem.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Domain model representing a single news article.
struct NewsItem: Hashable, Sendable {
    /// Unique identifier.
    let id: Int64
    /// Article headline.
    let title: String
    /// URL of the article's cover image.
    let titleImageUrl: String?
    /// URL of the full article web page.
    let fullUrl: String?
    /// Publication date.
    let publishedDate: Date?
}
