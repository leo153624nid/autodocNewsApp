//
//  NetworkEndPoint.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Description of network request.
protocol NetworkEndPoint {
    /// Base URL of request.
    var baseURL: String { get }
    /// Request headers.
    var headers: [String: String]? { get }
    /// Additional parameters for query part of URL.
    var urlParams: [String: String?]? { get }
    /// Request parameters. It is body for HTTP.
    var params: Data? { get }
    /// Request type. Default is GET.
    var requestType: NetworkEndPointRequestType { get }
    /// Request timeout. Default is 60 seconds.
    var timeout: TimeInterval { get }
    /// Request cache policy. Default is using protocol settings.
    var cachePolicy: NetworkEndPointRequestCachePolicy { get }
}

extension NetworkEndPoint {
    var headers: [String: String]? { nil }
    var params: Data? { nil }
    var urlParams: [String: String?]? { nil }
    var requestType: NetworkEndPointRequestType { .GET }
    var timeout: TimeInterval { 60 }
    var cachePolicy: NetworkEndPointRequestCachePolicy { .default }
}
