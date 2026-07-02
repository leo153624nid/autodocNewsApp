//
//  NewsAPIService.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

final class NewsAPIService {
    
    static let shared = NewsAPIService()

    private let baseURL = "https://webapi.autodoc.ru/api/news"

    private init() {}

    func fetch(page: Int,
               perPage: Int) async throws -> NewsResponseDTO {
        guard let url = URL(string: "\(baseURL)/\(page)/\(perPage)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(NewsResponseDTO.self, from: data)
    }
    
}
