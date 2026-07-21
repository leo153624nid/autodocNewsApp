import Foundation

/// Cache policy of network request.
public enum NetworkEndPointRequestCachePolicy: Sendable {
    /// Use the caching logic defined in the protocol implementation.
    case `default`
    /// No existing cache data should be used to satisfy the request.
    case ignoreCache
}
