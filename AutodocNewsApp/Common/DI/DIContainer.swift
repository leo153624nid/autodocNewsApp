//
//  DIContainer.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Simple dependency injection container.
///
/// Hint for next improvements:
/// https://www.avanderlee.com/swift/dependency-injection/
/// https://github.com/hmlongco/Factory
/// https://github.com/Swinject/Swinject
final class DIContainer {
    enum Scope {
        /// New instance at every resolve.
        case transient
        /// Shared instance (singleton) at resolve. It is default scope.
        case container
    }
    
    /// Shared container.
    static let shared = DIContainer()
    
    private typealias Registation = (_ container: DIContainer) -> (Any)
    
    private struct ServiceKey: Hashable {
        let type: String
        let name: String?
    }
    
    private var services = [ServiceKey: Any]()
    private var registrations = [ServiceKey: (scope: Scope, registration: Registation)]()
    private let lock = NSRecursiveLock()
    
    private init() {}
    
    /// Register service.
    ///
    /// - Parameter type: type of service.
    /// - Parameter name: name of service.
    /// - Parameter scope: scope for resolving.
    /// - Parameter registration: service registration.
    func register<Service>(type: Service.Type,
                           name: String? = nil,
                           scope: Scope = .container,
                           registration: @escaping (_ container: DIContainer) -> (Service)) {
        lock.lock()
        defer { lock.unlock() }
        
        let key = ServiceKey(type: "\(type)",
                             name: name)
        registrations[key] = (scope, registration as Registation)
    }
    
    /// Resolve service.
    ///
    /// - Parameter type: type of service.
    /// - Parameter name: name of service.
    ///
    /// - Returns: resolved service.
    func resolve<Service>(type: Service.Type, name: String? = nil) -> Service? {
        lock.lock()
        defer { lock.unlock() }
        
        let key = ServiceKey(type: "\(type)",
                             name: name)
        guard let resolveValue = registrations[key] else {
            return nil
        }
        
        switch resolveValue.scope {
        case .transient:
            return resolveValue.registration(self) as? Service
            
        case .container:
            if let service = services[key] as? Service {
                return service
            } else if let service = resolveValue.registration(self) as? Service {
                services[key] = service
                
                return service
            }
        }
        
        return nil
    }
}

@MainActor
extension DIContainer {
    /// Register all needed dependencies.
    func registerAll() {
        // order is important
        registerCommons()
        registerNewsFeature()
    }
    
    private func registerCommons() {
        register(type: NetworkService.self) { _ in
            DefaultNetworkService()
        }
        register(type: ImageLoader.self) { _ in
            DefaultImageLoader()
        }
    }
    
    private func registerNewsFeature() {
        register(type: NewsAPI.self) { container in
            let networkService = container.resolve(type: NetworkService.self)!
            return NewsAPIService(networkService: networkService)
        }
        register(type: NewsRepository.self) { container in
            let newsService = container.resolve(type: NewsAPI.self)!
            return NewsRepositoryImpl(service: newsService)
        }
    }
    
}
