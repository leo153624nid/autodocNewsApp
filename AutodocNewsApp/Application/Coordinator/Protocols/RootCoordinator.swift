//
//  RootCoordinator.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Root coordinator protocol.
@MainActor
protocol RootCoordinator: AnyObject, ObservableObject {
    
    /// Show tab.
    ///
    /// - Parameter tab: selected tab.
    func showTab(_ tab: AppTab)
    
}
