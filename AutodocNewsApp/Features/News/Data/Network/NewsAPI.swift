//
//  NewsAPI.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Remote news data source contract.
protocol NewsAPI {
    
    /// Fetches a page of raw news DTOs from the API.
    /// - Parameter page: 1-based page number.
    /// - Returns: Raw response DTO, or a network error.
    func fetch(page: Int) async -> Result<NewsResponseDTO, NetworkError>
    
}
