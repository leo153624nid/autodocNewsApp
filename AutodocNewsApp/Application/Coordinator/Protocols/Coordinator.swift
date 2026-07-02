//
//  Coordinator.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Foundation

/// Base coordinator protocol for feature/tab coordinators.
@MainActor
protocol Coordinator: AnyObject {

    /// Parent root coordinator.
    var parent: any RootCoordinator { get }

    /// Open previous screen.
    func pop()

    /// Open root screen.
    func popToRoot()
}

extension Coordinator {

    func showTab(_ tab: AppTab) {
        parent.showTab(tab)
    }
}
