import Foundation

/// Network error.
public enum NetworkError: Error, @unchecked Sendable {
    /// Invalid request.
    case badRequest
    /// Invalid response.
    case badResponse
    /// Failed decoding.
    case decodingFailed
    /// Device is not connected to internet.
    case notConnectedToInternet
    /// Problem with connection.
    case connectionError(_ underlyingError: any Error)
    /// Unauthorized error.
    case unAuthorized
    /// Unknown error.
    case unknown
}
