//
//  NewsTabCoordinatorProtocol.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

/// Coordinator contract for the News tab.
@MainActor
protocol NewsTabCoordinatorProtocol: Coordinator {

    /// Pushes the web detail screen for the given article.
    /// - Parameters:
    ///   - url: Article URL to load.
    ///   - title: Navigation bar title.
    func showNewsDetail(url: URL, title: String)

}
