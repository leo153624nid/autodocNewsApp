//
//  ActionableViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// View model with handler for view actions.
@MainActor
protocol ActionableViewModel {
    associatedtype Action
    
    /// Performing actions from view
    ///
    /// - Parameter action: action from view.
    func perform(action: Action)
}
