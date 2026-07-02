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

    unowned let parent: any RootCoordinator
    let navigationController: UINavigationController
    private var rootViewModel: SettingsViewModel!

    init(parent: any RootCoordinator) {
        self.parent = parent
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewModel = nil
        rootViewModel = SettingsViewModel(coordinator: self)
        let rootVC = SettingsViewController(viewModel: rootViewModel)
        navigationController.setViewControllers([rootVC], animated: false)
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }

    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
