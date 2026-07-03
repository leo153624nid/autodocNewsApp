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
    /// User tapped a news item.
    case selectItem(NewsItem)
    /// User pulled to refresh.
    case pullToRefresh
    /// Collection view scrolled near the bottom.
    case loadMore
    /// View appeared on screen.
    case onAppear
    /// View disappeared from screen.
    case onDisappear
}

/// ViewModel for the news list screen.
final class NewsListViewModel: ViewModel {

    /// Coordinator that handles News navigation.
    unowned let coordinator: any NewsTabCoordinatorProtocol

    /// Loading states of the news list.
    enum State {
        /// No data, no active request.
        case idle
        /// Initial page load in progress.
        case loading
        /// Items available; no active request.
        case loaded([NewsItem])
        /// Next page loading while existing items are shown.
        case loadingMore([NewsItem])
        /// Request failed.
        case error(NetworkError)
    }

    /// Current loading state, published to drive the UI.
    @Published private(set) var state: State = .idle
    private var isViewAppeared = false

    @Injected private var newsRepository: NewsRepository
    private var currentPage = 1
    private var totalCount = 0
    private var allItems: [NewsItem] = []
    private var fetchTask: Task<Void, Never>?

    private var canLoadMore: Bool {
        allItems.count < totalCount
    }

    // MARK: - Initialization

    /// Creates the view model.
    /// - Parameter coordinator: News tab coordinator.
    init(coordinator: any NewsTabCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    // MARK: - ViewModel

    /// Handles a news list view action.
    /// - Parameter action: Action triggered by the view.
    func perform(action: NewsListViewAction) {
        switch action {
        case .selectItem(let item):
            guard let urlString = item.fullUrl,
                  let url = URL(string: urlString) else { return }
            coordinator.showNewsDetail(url: url,
                                       title: item.title)

        case .pullToRefresh:
            loadInitial()

        case .loadMore:
            loadNextPage()

        case .onAppear:
            isViewAppeared = true
            if case .idle = state { loadInitial() }

        case .onDisappear:
            isViewAppeared = false
            cancelFetch()
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

    private func cancelFetch() {
        fetchTask?.cancel()
        fetchTask = nil
        switch state {
        case .loading:
            state = .idle
        case .loadingMore(let existing):
            state = .loaded(existing)
        default:
            break
        }
    }

    private func fetch(page: Int) {
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }

            let result = await newsRepository.fetchNews(page: page)

            guard !Task.isCancelled else { return }

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
