import Foundation

/// Description of a network request.
public protocol NetworkEndPoint {
    /// Base URL of the request.
    var baseURL: String { get }
    /// Request headers.
    var headers: [String: String]? { get }
    /// Additional parameters for the query part of the URL.
    var urlParams: [String: String?]? { get }
    /// Request body data.
    var params: Data? { get }
    /// HTTP method. Default is GET.
    var requestType: NetworkEndPointRequestType { get }
    /// Request timeout. Default is 60 seconds.
    var timeout: TimeInterval { get }
    /// Cache policy. Default is protocol-defined.
    var cachePolicy: NetworkEndPointRequestCachePolicy { get }
}

public extension NetworkEndPoint {
    var headers: [String: String]? { nil }
    var params: Data? { nil }
    var urlParams: [String: String?]? { nil }
    var requestType: NetworkEndPointRequestType { .GET }
    var timeout: TimeInterval { 60 }
    var cachePolicy: NetworkEndPointRequestCachePolicy { .default }
}
