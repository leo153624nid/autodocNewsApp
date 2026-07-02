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
}

struct NewsItemDTO: Decodable {
    let id: Int
    let title: String
    let titleImageUrl: String?
    let fullUrl: String?

    func toDomain() -> NewsItem {
        NewsItem(id: id, title: title, titleImageUrl: titleImageUrl, fullUrl: fullUrl)
    }
}
