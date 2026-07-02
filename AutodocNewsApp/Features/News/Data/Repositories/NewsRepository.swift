//
//  NewsRepository.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

final class NewsRepository: NewsRepositoryProtocol {
    
    private let service: NewsAPIService

    init(service: NewsAPIService = .shared) {
        self.service = service
    }

    func fetchNews(page: Int,
                   perPage: Int) async throws -> NewsFeed {
        let dto = try await service.fetch(page: page,
                                          perPage: perPage)
        
        return NewsFeed(items: dto.news.map { $0.toDomain() },
                        totalCount: dto.totalCount)
    }
    
}
