//
//  InjectedLazy.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Property wrapper for fast lazy injection.
///
///     @InjectedLazy var networkService: NetworkService
@propertyWrapper
struct InjectedLazy<Service> {
    lazy var wrappedValue: Service = {
        let value = initializer!()
        initializer = nil
        return value
    }()
    private var initializer: (() -> Service)?
    
    /// Property initialization.
    ///
    /// - Parameter name: name of service.
    /// - Parameter container: dependency injection container.
    init(name: String? = nil, container: DIContainer = .shared) {
        initializer = {
            container.resolve(type: Service.self,
                              name: name)!
        }
    }
}
