import Combine
import Foundation

/// Default implementation of network service.
public class DefaultNetworkService: NetworkService {

    /// Session for performing requests.
    private let urlSession: URLSession

    /// Build request by description.
    ///
    /// - Parameter endpoint: request description.
    ///
    /// - Returns: request.
    private func request(from endpoint: NetworkEndPoint) -> URLRequest? {
        guard let urlComponents = NSURLComponents(string: endpoint.baseURL) else {
            return nil
        }

        if let urlParams = endpoint.urlParams,
           !urlParams.isEmpty {
            var queryItems = urlComponents.queryItems ?? []
            urlParams.forEach { queryItems.append(.init(name: $0, value: $1)) }
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            return nil
        }

        let cachePolicy: URLRequest.CachePolicy
        switch endpoint.cachePolicy {
        case .default:
            cachePolicy = .useProtocolCachePolicy
        case .ignoreCache:
            cachePolicy = .reloadIgnoringCacheData
        }

        var request = URLRequest(url: url,
                                 cachePolicy: cachePolicy,
                                 timeoutInterval: endpoint.timeout)
        request.httpMethod = endpoint.requestType.rawValue
        if let headers = endpoint.headers,
           !headers.isEmpty {
            request.allHTTPHeaderFields = headers
        }
        request.httpBody = endpoint.params

        return request
    }

    public func performRequest<T: Decodable>(endpoint: NetworkEndPoint,
                                             resultHandler: @escaping (Result<T, NetworkError>) -> Void) {
        guard let request = request(from: endpoint) else {
            resultHandler(.failure(.badRequest))
            return
        }

        let dataTask = urlSession.dataTask(with: request) { data, _, error in
            guard error == nil else {
                let error = error!
                if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                    resultHandler(.failure(.notConnectedToInternet))
                } else {
                    resultHandler(.failure(.connectionError(error)))
                }

                return
            }

            guard let data,
                  let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                resultHandler(.failure(.badResponse))
                return
            }

            resultHandler(.success(decodedResponse))
        }
        dataTask.resume()
    }

    public func performRequest<T: Decodable>(endpoint: NetworkEndPoint) async throws(NetworkError) -> T {
        guard let request = request(from: endpoint) else {
            throw .badRequest
        }

        do {
            let data = (try await urlSession.data(for: request)).0
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                throw NetworkError.badResponse
            }

            return decodedResponse
        } catch {
            if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                throw .notConnectedToInternet
            } else {
                throw .connectionError(error)
            }
        }
    }

    public func performRequest<T: Decodable>(
        endpoint: NetworkEndPoint) throws(NetworkError
        ) -> AnyPublisher<T, NetworkError> {
        
        guard let request = request(from: endpoint) else {
            throw .badRequest
        }

        return urlSession.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, _ -> Data in
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .badResponse
                } else if let error = error as? NetworkError {
                    return error
                } else if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                    return .notConnectedToInternet
                } else {
                    return .connectionError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    public func performRequest(endpoint: NetworkEndPoint,
                               resultHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let request = request(from: endpoint) else {
            resultHandler(.failure(.badRequest))
            return
        }

        let dataTask = urlSession.dataTask(with: request) { data, _, error in
            guard error == nil else {
                let error = error!
                if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                    resultHandler(.failure(.notConnectedToInternet))
                } else {
                    resultHandler(.failure(.connectionError(error)))
                }

                return
            }

            guard let data else {
                resultHandler(.failure(.badResponse))
                return
            }

            resultHandler(.success(data))
        }
        dataTask.resume()
    }

    public func performRequest(endpoint: NetworkEndPoint) async throws(NetworkError) -> Data {
        guard let request = request(from: endpoint) else {
            throw .badRequest
        }

        do {
            let data = (try await urlSession.data(for: request)).0
            return data
        } catch {
            if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                throw .notConnectedToInternet
            } else {
                throw .connectionError(error)
            }
        }
    }

    public func performRequest(endpoint: NetworkEndPoint) throws(NetworkError) -> AnyPublisher<Data, NetworkError> {
        guard let request = request(from: endpoint) else {
            throw .badRequest
        }

        return urlSession.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, _ -> Data in
                return data
            }
            .mapError { error -> NetworkError in
                if let error = error as? NetworkError {
                    return error
                } else if error._domain == NSURLErrorDomain && error._code == NSURLErrorNotConnectedToInternet {
                    return .notConnectedToInternet
                } else {
                    return .connectionError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    /// Initialization.
    ///
    /// - Parameter urlSession: session for performing requests. Default is shared session.
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
}
