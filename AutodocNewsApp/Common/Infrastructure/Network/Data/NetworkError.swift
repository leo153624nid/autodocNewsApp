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
    var localizedDescription: String { // TODO: add localizable
        return switch self {
        case .badRequest, .badResponse, .decodingFailed, .unAuthorized:
            "Something went wrong"
        case .notConnectedToInternet:
            "No internet connection"
        case .connectionError:
            "Problem with connection"
        case .unknown:
            "Unknown error"
        }
    }
}
