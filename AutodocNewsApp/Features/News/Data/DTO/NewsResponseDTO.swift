//
//  NewsResponseDTO.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

struct NewsResponseDTO: Decodable {
    let news: [NewsItemDTO]
    let totalCount: Int
    
    enum CodingKeys: CodingKey {
        case news
        case totalCount
    }
}

struct NewsItemDTO: Decodable {
    let id: Int
    let title: String
    let titleImageUrl: String?
    let fullUrl: String?
    let publishedDate: String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case titleImageUrl
        case fullUrl
        case publishedDate
    }

    func toDomain() -> NewsItem { // TODO: maybe use mapper?
        NewsItem(id: id,
                 title: title,
                 titleImageUrl: titleImageUrl,
                 fullUrl: fullUrl,
                 publishedDate: publishedDate?.isoStringToDate())
    }
}
