import Foundation

/// Concrete NetworkEndPoint suitable for most HTTP requests.
public class BaseNetworkEndPoint: NetworkEndPoint {
    public var baseURL: String
    public var headers: [String: String]?
    public var urlParams: [String: String?]?
    public var params: Data?
    public var requestType: NetworkEndPointRequestType
    public var timeout: TimeInterval
    public var cachePolicy: NetworkEndPointRequestCachePolicy

    public init(
        baseURL: String,
        headers: [String: String]? = nil,
        urlParams: [String: String?]? = nil,
        params: Data? = nil,
        requestType: NetworkEndPointRequestType = .GET,
        timeout: TimeInterval = 60,
        cachePolicy: NetworkEndPointRequestCachePolicy = .default
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.urlParams = urlParams
        self.params = params
        self.requestType = requestType
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }

    public init(
        baseURL: String,
        headers: [String: String]? = nil,
        urlParams: [String: String?]? = nil,
        params: (some Encodable)? = nil,
        requestType: NetworkEndPointRequestType = .GET,
        timeout: TimeInterval = 60,
        cachePolicy: NetworkEndPointRequestCachePolicy = .default
    ) throws {
        self.baseURL = baseURL
        self.headers = headers
        self.urlParams = urlParams
        self.params = params.flatMap { try? JSONEncoder().encode($0) }
        self.requestType = requestType
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }
}
