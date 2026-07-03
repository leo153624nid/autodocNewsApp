//
//  NetworkError.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Network error.
enum NetworkError: Error {
    /// Invalid request.
    case badRequest
    /// Invalid response.
    case badResponse
    /// Failed decoding
    case decodingFailed
    /// Device is not connected to internet.
    case notConnectedToInternet
    /// Problem with connection.
    case connectionError(_ underlyingError: Error)
    /// Authorized error
    case unAuthorized
    /// Unknown error.
    case unknown
    
    /// localized description of error for user
    var localizedDescription: String {
        return switch self {
        case .badRequest, .badResponse, .decodingFailed, .unAuthorized:
            "error.something_went_wrong".localized
        case .notConnectedToInternet:
            "error.no_internet_connection".localized
        case .connectionError:
            "error.problem_with_connection".localized
        case .unknown:
            "error.unknown".localized
        }
    }
}
