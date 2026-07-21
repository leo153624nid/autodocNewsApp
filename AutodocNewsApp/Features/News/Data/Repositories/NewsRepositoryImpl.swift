//
//  NewsRepositoryImpl.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation
import NetworkKit

/// Default NewsRepository that maps DTOs to domain models.
final class NewsRepositoryImpl: NewsRepository {
    
    private let service: NewsAPI
    private let mapper = NewsMapper()

    /// Creates the repository.
    /// - Parameter service: News API data source.
    init(service: NewsAPI) {
        self.service = service
    }

    /// Fetches a page of news and maps the response to domain models.
    /// - Parameter page: 1-based page number.
    /// - Returns: Feed with items and total count, or a network error.
    func fetchNews(page: Int) async -> Result<NewsFeed, NetworkError> {
        let result = await service.fetch(page: page)
        
        switch result {
        case .success(let dto):
            let items: [NewsItem] = mapper.toDomain(dto.news)
            return .success(NewsFeed(items: items,
                                     totalCount: dto.totalCount))
        case .failure(let error):
            return .failure(error)
        }
    }
    
}
