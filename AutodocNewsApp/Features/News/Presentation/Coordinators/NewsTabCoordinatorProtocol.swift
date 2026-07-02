//
//  NewsTabCoordinatorProtocol.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

@MainActor
protocol NewsTabCoordinatorProtocol: Coordinator {
    
    func showNewsDetail(url: URL, title: String)
    
}
