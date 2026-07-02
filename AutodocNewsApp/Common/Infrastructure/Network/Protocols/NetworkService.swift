//
//  NetworkService.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Combine
import Foundation

/// Description of network service.
protocol NetworkService {
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    /// - Parameter resultHandler: callback with loaded data or error.
    func performRequest<T: Decodable>(endpoint: NetworkEndPoint,
                                      resultHandler: @escaping (Result<T, NetworkError>) -> Void)
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    ///
    /// - Returns: loaded data.
    func performRequest<T: Decodable>(endpoint: NetworkEndPoint) async throws(NetworkError) -> T
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    ///
    /// - Returns: publisher for handling result of request.
    func performRequest<T: Decodable>(endpoint: NetworkEndPoint) throws(NetworkError) -> AnyPublisher<T, NetworkError>
    
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    /// - Parameter resultHandler: callback with loaded data or error.
    func performRequest(endpoint: NetworkEndPoint, resultHandler: @escaping (Result<Data, NetworkError>) -> Void)
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    ///
    /// - Returns: loaded data.
    func performRequest(endpoint: NetworkEndPoint) async throws(NetworkError) -> Data
    /// Perform network request.
    ///
    /// - Parameter endpoint: request description.
    ///
    /// - Returns: publisher for handling result of request.
    func performRequest(endpoint: NetworkEndPoint) throws(NetworkError) -> AnyPublisher<Data, NetworkError>
}
