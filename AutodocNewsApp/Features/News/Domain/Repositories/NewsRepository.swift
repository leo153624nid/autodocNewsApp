//
//  NewsRepository.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

protocol NewsRepository {
    
    func fetchNews(page: Int,
                   perPage: Int) async throws -> NewsFeed
    
}
