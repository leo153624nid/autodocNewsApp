//
//  NewsRepositoryImpl.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

final class NewsRepositoryImpl: NewsRepository {
    
    private let service: NewsAPI
    private let mapper = NewsMapper()

    init(service: NewsAPI) {
        self.service = service
    }

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
