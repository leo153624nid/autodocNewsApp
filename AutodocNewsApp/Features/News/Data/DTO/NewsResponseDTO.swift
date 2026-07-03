//
//  NewsResponseDTO.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Raw API response containing one page of news.
struct NewsResponseDTO: Decodable {
    /// News items on this page.
    let news: [NewsItemDTO]
    /// Total number of articles available on the server.
    let totalCount: Int
    
    enum CodingKeys: CodingKey {
        case news
        case totalCount
    }
}

/// Raw representation of a single news article from the API.
struct NewsItemDTO: Decodable {
    /// Unique identifier.
    let id: Int64
    /// Article headline.
    let title: String
    /// URL of the article's cover image.
    let titleImageUrl: String?
    /// URL of the full article web page.
    let fullUrl: String?
    /// Publication date as ISO 8601 string.
    let publishedDate: String?
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case titleImageUrl
        case fullUrl
        case publishedDate
    }

}
