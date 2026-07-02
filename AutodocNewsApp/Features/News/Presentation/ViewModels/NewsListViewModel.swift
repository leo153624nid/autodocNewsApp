//
//  NewsListViewModel.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import Foundation

/// Actions from NewsList view.
enum NewsListViewAction {
    case selectItem(NewsItem)
    case pullToRefresh
    case loadMore
    case onAppear
    case onDisappear
}

final class NewsListViewModel: ViewModel {

    unowned let coordinator: any NewsTabCoordinatorProtocol

    enum State {
        case idle
        case loading
        case loaded([NewsItem])
        case loadingMore([NewsItem])
        case error(NetworkError)
    }

    @Published private(set) var state: State = .idle
    private var isViewAppeared = false

    @Injected private var newsRepository: NewsRepository
    private var currentPage = 1
    private var totalCount = 0
    private var allItems: [NewsItem] = []

    private var canLoadMore: Bool {
        allItems.count < totalCount
    }

    // MARK: - Initialization

    init(coordinator: any NewsTabCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - ViewModel

    func perform(action: NewsListViewAction) {
        switch action {
        case .selectItem(let item):
            guard let urlString = item.fullUrl,
                  let url = URL(string: urlString) else { return }
            coordinator.showNewsDetail(url: url, title: item.title)

        case .pullToRefresh:
            refresh()

        case .loadMore:
            loadNextPage()

        case .onAppear:
            isViewAppeared = true
            if case .idle = state { loadInitial() }

        case .onDisappear:
            isViewAppeared = false
        }
    }

    // MARK: - Private

    private func loadInitial() {
        currentPage = 1
        allItems = []
        totalCount = 0
        state = .loading
        fetch(page: currentPage)
    }

    private func loadNextPage() {
        guard case .loaded = state, canLoadMore else { return }
        
        state = .loadingMore(allItems)
        fetch(page: currentPage)
    }

    private func refresh() {
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
