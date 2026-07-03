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

    /// Root tab bar controller hosting all tabs.
    private(set) var tabBarController = AppRootTabBarController()
    /// Coordinator for the News tab.
    private(set) var newsCoordinator: NewsTabCoordinator!
    /// Coordinator for the Settings tab.
    private(set) var settingsCoordinator: SettingsTabCoordinator!

    init() {
        setupCoordinators()
    }

    // MARK: - RootCoordinator

    /// Switches the tab bar to the specified tab.
    /// - Parameter tab: Tab to select.
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
            title: "tab.news".localized,
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )

        let settingsNav = settingsCoordinator.navigationController
        settingsNav.tabBarItem = UITabBarItem(
            title: "tab.settings".localized,
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear.fill")
        )

        tabBarController.viewControllers = [newsNav, settingsNav]
    }
}
