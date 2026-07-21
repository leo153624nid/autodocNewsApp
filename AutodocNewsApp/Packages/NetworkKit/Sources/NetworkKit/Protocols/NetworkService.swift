import Combine
import Foundation

/// Contract for performing network requests.
public protocol NetworkService {

    // MARK: Decodable response

    func performRequest<T: Decodable & Sendable>(
        endpoint: NetworkEndPoint,
        resultHandler: @escaping @Sendable (Result<T, NetworkError>) -> Void
    )

    func performRequest<T: Decodable & Sendable>(
        endpoint: NetworkEndPoint
    ) async throws(NetworkError) -> T

    func performRequest<T: Decodable & Sendable>(
        endpoint: NetworkEndPoint
    ) throws(NetworkError) -> AnyPublisher<T, NetworkError>

    // MARK: Raw Data response

    func performRequest(
        endpoint: NetworkEndPoint,
        resultHandler: @escaping @Sendable (Result<Data, NetworkError>) -> Void
    )

    func performRequest(endpoint: NetworkEndPoint) async throws(NetworkError) -> Data

    func performRequest(endpoint: NetworkEndPoint) throws(NetworkError) -> AnyPublisher<Data, NetworkError>
}
