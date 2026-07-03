//
//  NewsFeed.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Domain model representing one page of news.
struct NewsFeed {
    /// News items on this page.
    let items: [NewsItem]
    /// Total number of articles available on the server.
    let totalCount: Int
}
