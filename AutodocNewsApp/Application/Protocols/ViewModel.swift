//
//  ViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Base protocol of view model.
@MainActor
protocol ViewModel: ObservableObject, ActionableViewModel {
    associatedtype Coordinator
    
    /// Own coordinator.
    var coordinator: Coordinator { get }
    
    /// Base initializator.
    ///
    /// - Parameter coordinator: coordinator.
    init(coordinator: Coordinator)
}
