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

    unowned let parent: any RootCoordinator
    let navigationController: UINavigationController
    private var rootViewModel: NewsListViewModel!

    init(parent: any RootCoordinator) {
        self.parent = parent
        navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        rootViewModel = NewsListViewModel(coordinator: self)
        let rootVC = NewsListViewController(viewModel: rootViewModel)
        navigationController.setViewControllers([rootVC], animated: false)
    }

    func showNewsDetail(url: URL, title: String) {
        let webVC = NewsWebViewController(url: url,
                                          title: title)
        navigationController.pushViewController(webVC, animated: true)
    }

    func pop() {
        navigationController.popViewController(animated: true)
    }

    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
