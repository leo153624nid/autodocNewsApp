//
//  NewsAPIService.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Concrete NewsAPI implementation backed by NetworkService.
final class NewsAPIService: NewsAPI {
    
    private let networkService: NetworkService
    
    // MARK: - Public methods

    /// Initialization
    /// Creates the API service.
    /// - Parameter networkService: Network service used for HTTP requests.
    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    /// Fetches raw news data from the Autodoc API.
    /// - Parameter page: 1-based page number.
    /// - Returns: Raw response DTO, or a network error.
    func fetch(page: Int) async -> Result<NewsResponseDTO, NetworkError> {
        let url = "\(Constants.baseURL)/\(page)/\(Constants.pageSize)"
        let endpoint = BaseNetworkEndPoint(baseURL: url)
        
        do {
            let data = try await networkService.performRequest(endpoint: endpoint)
            
            if let response = try? JSONDecoder().decode(NewsResponseDTO.self, from: data) {
                return .success(response)
            } else {
                return .failure(.decodingFailed)
            }
        } catch {
            return .failure(error)
        }
    }
    
}

private extension NewsAPIService {
    
    struct Constants {
        static let baseURL = "https://webapi.autodoc.ru/api/news"
        static let pageSize = 15
    }
}
