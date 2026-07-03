//
//  NewsTabCoordinator.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import UIKit

/// Coordinator for the News tab.
final class NewsTabCoordinator: NewsTabCoordinatorProtocol {

    /// Parent root coordinator.
    unowned let parent: any RootCoordinator
    /// Navigation controller that hosts the News stack.
    let navigationController: UINavigationController
    private var rootViewModel: NewsListViewModel!

    /// Creates the coordinator and sets up the news navigation stack.
    /// - Parameter parent: Root coordinator that owns this tab.
    init(parent: any RootCoordinator) {
        self.parent = parent
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewModel = NewsListViewModel(coordinator: self)
        let rootVC = NewsListViewController(viewModel: rootViewModel)
        navigationController.setViewControllers([rootVC], animated: false)
    }

    /// Pushes the article web view onto the navigation stack.
    /// - Parameters:
    ///   - url: Article URL to load.
    ///   - title: Navigation bar title for the detail screen.
    func showNewsDetail(url: URL, title: String) {
        let webVC = NewsWebViewController(url: url,
                                          title: title)
        navigationController.pushViewController(webVC, animated: true)
    }

    /// Pops one screen from the navigation stack.
    func pop() {
        navigationController.popViewController(animated: true)
    }

    /// Pops all screens back to the news list.
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
