//
//  SettingsTabCoordinator.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import UIKit

/// Coordinator for the Settings tab.
final class SettingsTabCoordinator: SettingsTabCoordinatorProtocol {

    /// Parent root coordinator.
    unowned let parent: any RootCoordinator
    /// Navigation controller that hosts the Settings stack.
    let navigationController: UINavigationController
    private var rootViewModel: SettingsViewModel!

    /// Creates the coordinator and sets up the settings navigation stack.
    /// - Parameter parent: Root coordinator that owns this tab.
    init(parent: any RootCoordinator) {
        self.parent = parent
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewModel = nil
        rootViewModel = SettingsViewModel(coordinator: self)
        let rootVC = SettingsViewController(viewModel: rootViewModel)
        navigationController.setViewControllers([rootVC], animated: false)
    }

    /// Pops one screen from the navigation stack.
    func pop() {
        navigationController.popViewController(animated: true)
    }

    /// Pops all screens back to the settings root.
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
