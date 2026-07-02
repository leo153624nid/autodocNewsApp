//
//  AppRootCoordinator.swift
//  AutodocNewsApp
//
//  Created by A Ch on 18.06.2026.
//

import Combine
import UIKit

/// Application root coordinator.
@MainActor
final class AppRootCoordinator: RootCoordinator {

    private(set) var tabBarController = AppRootTabBarController()
    private(set) var newsCoordinator: NewsTabCoordinator!
    private(set) var settingsCoordinator: SettingsTabCoordinator!

    init() {
        setupCoordinators()
    }

    // MARK: - RootCoordinator

    func showTab(_ tab: AppTab) {
        switch tab {
        case .news: tabBarController.selectedIndex = 0
        case .settings: tabBarController.selectedIndex = 1
        }
    }

    // MARK: - Private

    private func setupCoordinators() {
        newsCoordinator = NewsTabCoordinator(parent: self)
        settingsCoordinator = SettingsTabCoordinator(parent: self)

        let newsNav = newsCoordinator.navigationController
        newsNav.tabBarItem = UITabBarItem(
            title: "News", // TODO: localize
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )

        let settingsNav = settingsCoordinator.navigationController
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings", // TODO: localize
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear.fill")
        )

        tabBarController.viewControllers = [newsNav, settingsNav]
    }
}
