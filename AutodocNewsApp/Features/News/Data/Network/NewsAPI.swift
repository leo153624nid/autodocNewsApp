//
//  NewsAPI.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

protocol NewsAPI {
    
    func fetch(page: Int) async -> Result<NewsResponseDTO, NetworkError>
}
