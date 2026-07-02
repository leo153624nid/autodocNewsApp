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
        case error(NetworkError)
    }

    @Published private(set) var state: State = .idle

    @Injected private var newsRepository: NewsRepository
    private var currentPage = 1
    private var totalCount = 0
    private var allItems: [NewsItem] = []

    private var canLoadMore: Bool {
        allItems.count < totalCount
    }

    init() { // TODO: add coordinator
        
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
            
            let result = await newsRepository.fetchNews(page: page)
            
            switch result {
            case .success(let feed):
                totalCount = feed.totalCount
                allItems += feed.items
                currentPage += 1
                state = .loaded(allItems)
            case .failure(let error):
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
