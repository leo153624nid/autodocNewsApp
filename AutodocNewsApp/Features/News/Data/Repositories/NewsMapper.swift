//
//  NewsMapper.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// News objects mapper
struct NewsMapper {
    /// Convert news item dto to domain
    /// - Parameter dto: news item dto
    /// - Returns: news item domain
    func toDomain(_ dto: NewsItemDTO) -> NewsItem {
        return NewsItem(id: dto.id,
                        title: dto.title,
                        titleImageUrl: dto.titleImageUrl,
                        fullUrl: dto.fullUrl,
                        publishedDate: dto.publishedDate?.isoStringToDate())
    }
    
    /// Convert array of news dto to domain
    /// - Parameter dto: array news dto
    /// - Returns: array news domain
    func toDomain(_ dtos: [NewsItemDTO]) -> [NewsItem] {
        dtos.map(toDomain(_:))
    }
    
}
