//
//  NewsRepository.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation
import NetworkKit

/// Contract for accessing paginated news data.
protocol NewsRepository {
    
    /// Fetches a page of news articles.
    /// - Parameter page: 1-based page number.
    /// - Returns: Feed with items and total count, or a network error.
    func fetchNews(page: Int) async -> Result<NewsFeed, NetworkError>
    
}
