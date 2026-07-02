//
//  NetworkEndPointRequestCachePolicy.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Cache policy of network request.
enum NetworkEndPointRequestCachePolicy {
    /// Use the caching logic defined in the protocol implementation.
    case `default`
    /// This policy specifies that no existing cache data should be used to satisfy a URL load request.
    case ignoreCache
}
