//
//  BaseNetworkEndPoint.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Simple implementation of EndPoint. It can be useful for most king of requests.
class BaseNetworkEndPoint: NetworkEndPoint {
    var baseURL: String
    var headers: [String: String]?
    var urlParams: [String: String?]?
    var params: Data?
    var requestType: NetworkEndPointRequestType
    var timeout: TimeInterval
    var cachePolicy: NetworkEndPointRequestCachePolicy
    
    /// Initiazliation.
    ///
    /// - Parameter baseURL: Base URL of request. For example, https://service.ray.app.
    /// - Parameter headers: Request headers.
    /// - Parameter urlParams: Additional parameters for query part of URL.
    /// - Parameter params: Request params.
    /// - Parameter requestType: Request type. Default is GET.
    /// - Parameter timeout: Request timeout. Default is 60 seconds.
    /// - Parameter cachePolicy: Request cache policy. Default is using protocol settings.
    init(baseURL: String,
         headers: [String: String]? = nil,
         urlParams: [String: String?]? = nil,
         params: Data? = nil,
         requestType: NetworkEndPointRequestType = .GET,
         timeout: TimeInterval = 60,
         cachePolicy: NetworkEndPointRequestCachePolicy = .default) {
        
        self.baseURL = baseURL
        self.headers = headers
        self.urlParams = urlParams
        self.params = params
        self.requestType = requestType
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }
    
    /// Initiazliation.
    ///
    /// - Parameter baseURL: Base URL of request. For example, https://service.ray.app.
    /// - Parameter headers: Request headers.
    /// - Parameter urlParams: Additional parameters for query part of URL.
    /// - Parameter params: Request params.
    /// - Parameter requestType: Request type. Default is GET.
    /// - Parameter timeout: Request timeout. Default is 60 seconds.
    /// - Parameter cachePolicy: Request cache policy. Default is using protocol settings.
    init(baseURL: String,
         headers: [String: String]? = nil,
         urlParams: [String: String?]? = nil,
         params: (some Encodable)? = nil,
         requestType: NetworkEndPointRequestType = .GET,
         timeout: TimeInterval = 60,
         cachePolicy: NetworkEndPointRequestCachePolicy = .default) throws {
        
        self.baseURL = baseURL
        self.headers = headers
        self.urlParams = urlParams
        self.params = (params == nil) ? nil : try JSONEncoder().encode(params!)
        self.requestType = requestType
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }
}
