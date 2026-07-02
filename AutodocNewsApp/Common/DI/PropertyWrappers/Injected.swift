//
//  Injected.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Property wrapper for fast injection.
///
///     @Injected var networkService: NetworkService
///
/// Hint: don't use this type of injection.
@propertyWrapper
struct Injected<Service> {
    var wrappedValue: Service
    
    /// Property initialization.
    ///
    /// - Parameter name: name of service.
    /// - Parameter container: dependency injection container.
    init(name: String? = nil, container: DIContainer = .shared) {
        wrappedValue = container.resolve(type: Service.self,
                                         name: name)!
    }
}
