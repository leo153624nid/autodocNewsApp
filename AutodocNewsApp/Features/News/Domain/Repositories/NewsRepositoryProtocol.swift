//
//  NewsRepositoryProtocol.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

protocol NewsRepositoryProtocol {
    func fetchNews(page: Int, perPage: Int) async throws -> NewsFeed
}
