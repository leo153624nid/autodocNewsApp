//
//  NewsItem.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Foundation

struct NewsItem: Hashable, Sendable {
    let id: Int
    let title: String
    let titleImageUrl: String?
    let fullUrl: String?
}
