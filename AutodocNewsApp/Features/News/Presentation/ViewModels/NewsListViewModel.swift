//
//  NewsListViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import Foundation

@MainActor
final class NewsListViewModel {

    enum State {
        case idle
        case loading
        case loaded([NewsItem])
        case loadingMore([NewsItem])
        case error(Error)
    }

    @Published private(set) var state: State = .idle

    private let repository: NewsRepositoryProtocol
    private var currentPage = 1
    private let perPage = 15
    private var totalCount = 0
    private var allItems: [NewsItem] = []

    private var canLoadMore: Bool {
        allItems.count < totalCount
    }

    init(repository: NewsRepositoryProtocol = NewsRepository()) {
        self.repository = repository
    }

    func loadInitial() {
        currentPage = 1
        allItems = []
        totalCount = 0
        state = .loading
        fetch(page: currentPage)
    }

    func loadNextPage() {
        guard case .loaded = state, canLoadMore else { return }
        
        state = .loadingMore(allItems)
        fetch(page: currentPage)
    }

    func refresh() {
        loadInitial()
    }

    private func fetch(page: Int) {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let feed = try await repository.fetchNews(page: page,
                                                          perPage: perPage)
                totalCount = feed.totalCount
                allItems += feed.items
                currentPage += 1
                state = .loaded(allItems)
            } catch {
                switch state {
                case .loadingMore(let existing):
                    state = .loaded(existing)
                default:
                    state = .error(error)
                }
            }
        }
    }
    
}
