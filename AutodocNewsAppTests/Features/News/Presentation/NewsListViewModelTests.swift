//
//  NewsListViewModelTests.swift
//  AutodocNewsAppTests
//
//  Created by A Ch on 03.07.2026.
//

@testable import AutodocNewsApp
import Combine
import Foundation
import Testing

// MARK: - Mocks

@MainActor
private final class MockRootCoordinator: RootCoordinator {
    
    private(set) var showTabCallsCount = 0
    
    func showTab(_ tab: AppTab) {
        showTabCallsCount += 1
    }
}

@MainActor
private final class MockNewsTabCoordinator: NewsTabCoordinatorProtocol {
    
    let parent: any RootCoordinator = MockRootCoordinator()
    
    private(set) var showNewsDetailCallCount = 0
    private(set) var lastUrl: URL?
    private(set) var lastTitle: String?
    
    private(set) var popCallCount = 0
    private(set) var popToRootCallCount = 0

    func showNewsDetail(url: URL, title: String) {
        showNewsDetailCallCount += 1
        lastUrl = url
        lastTitle = title
    }

    func pop() {
        popCallCount += 1
    }
    
    func popToRoot() {
        popToRootCallCount += 1
    }
}

private final class MockNewsRepository: NewsRepository {
    
    var stubbedResult: Result<NewsFeed, NetworkError> = .success(NewsFeed(items: [], totalCount: 0))
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedPage: Int?

    func fetchNews(page: Int) async -> Result<NewsFeed, NetworkError> {
        fetchCallCount += 1
        lastFetchedPage = page
        return stubbedResult
    }
}

// MARK: - Tests

@MainActor
@Suite(.serialized)
struct NewsListViewModelTests {
    
    private let sut: NewsListViewModel
    private let repository: MockNewsRepository
    private let coordinator: MockNewsTabCoordinator
    
    init() {
        let repository = MockNewsRepository()
        DIContainer.shared.register(type: NewsRepository.self, scope: .transient) { _ in repository }
        let coordinator = MockNewsTabCoordinator()
        self.sut = NewsListViewModel(coordinator: coordinator)
        self.repository = repository
        self.coordinator = coordinator
    }

    // MARK: - Helpers

    private func waitForTasks() async {
        for _ in 0..<5 { await Task.yield() }
    }

    private func makeItems(count: Int, startId: Int64 = 1) -> [NewsItem] {
        (0..<count).map {
            NewsItem(id: startId + Int64($0),
                     title: "Title \(startId + Int64($0))",
                     titleImageUrl: nil,
                     fullUrl: "https://example.com/news/\(startId + Int64($0))",
                     publishedDate: nil)
        }
    }

    private func makeFeed(items: [NewsItem], totalCount: Int) -> NewsFeed {
        NewsFeed(items: items,
                 totalCount: totalCount)
    }

    // MARK: - Initial state

    @Test func initialState_isIdle() {
        guard case .idle = sut.state else {
            Issue.record("Expected .idle, got \(sut.state)")
            return
        }
    }

    // MARK: - onAppear

    @Test func onAppear_whenIdle_setsLoadingImmediately() {
        sut.perform(action: .onAppear)
        guard case .loading = sut.state else {
            Issue.record("Expected .loading synchronously after onAppear, got \(sut.state)")
            return
        }
    }

    @Test func onAppear_whenIdle_transitionsToLoaded() async {
        let items = makeItems(count: 3)
        let stubbedResult = makeFeed(items: items, totalCount: 3)
        repository.stubbedResult = .success(stubbedResult)

        sut.perform(action: .onAppear)
        await waitForTasks()

        guard case .loaded(let loadedItems) = sut.state else {
            Issue.record("Expected .loaded after fetch completes, got \(sut.state)")
            return
        }
        #expect(loadedItems.count == 3)
        #expect(repository.fetchCallCount == 1)
        #expect(repository.lastFetchedPage == 1)
    }

    // MARK: - pullToRefresh

    @Test func pullToRefresh_reloadsFromPage1() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        let page2Items = makeItems(count: 2, startId: 3)
        repository.stubbedResult = .success(makeFeed(items: page2Items, totalCount: 10))
        sut.perform(action: .loadMore)
        await waitForTasks()

        sut.perform(action: .pullToRefresh)
        await waitForTasks()

        #expect(repository.lastFetchedPage == 1)
        #expect(repository.fetchCallCount == 3)
    }

    @Test func pullToRefresh_replacesExistingItems() async {
        let initialItems = makeItems(count: 3)
        repository.stubbedResult = .success(makeFeed(items: initialItems, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        let refreshItems = makeItems(count: 2, startId: 100)
        repository.stubbedResult = .success(makeFeed(items: refreshItems, totalCount: 10))

        sut.perform(action: .pullToRefresh)
        await waitForTasks()

        guard case .loaded(let items) = sut.state else {
            Issue.record("Expected .loaded after refresh, got \(sut.state)")
            return
        }
        #expect(items.count == 2)
        #expect(items.first?.id == 100)
    }

    // MARK: - loadMore

    @Test func loadMore_whenLoadedAndHasMore_showsLoadingMoreImmediately() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        sut.perform(action: .loadMore)

        guard case .loadingMore = sut.state else {
            Issue.record("Expected .loadingMore synchronously after loadMore, got \(sut.state)")
            return
        }
    }

    @Test func loadMore_whenLoadedAndHasMore_fetchesNextPage() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        let page2Items = makeItems(count: 2, startId: 3)
        repository.stubbedResult = .success(makeFeed(items: page2Items, totalCount: 10))

        sut.perform(action: .loadMore)
        await waitForTasks()

        #expect(repository.lastFetchedPage == 2)
    }

    @Test func loadMore_whenLoadedAndHasMore_appendsItems() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        let page2Items = makeItems(count: 3, startId: 3)
        repository.stubbedResult = .success(makeFeed(items: page2Items, totalCount: 10))

        sut.perform(action: .loadMore)
        await waitForTasks()

        guard case .loaded(let items) = sut.state else {
            Issue.record("Expected .loaded after loadMore, got \(sut.state)")
            return
        }
        #expect(items.count == 5)
        #expect(repository.fetchCallCount == 2)
    }

    @Test func loadMore_whenAllItemsLoaded_doesNotFetch() async {
        let items = makeItems(count: 3)
        repository.stubbedResult = .success(makeFeed(items: items, totalCount: 3))

        sut.perform(action: .onAppear)
        await waitForTasks()
        let callCountBefore = repository.fetchCallCount

        sut.perform(action: .loadMore)
        await waitForTasks()

        #expect(repository.fetchCallCount == callCountBefore)
    }

    @Test func loadMore_whenStateIsIdle_doesNotFetch() async {
        // State is .idle

        sut.perform(action: .loadMore)
        await waitForTasks()

        #expect(repository.fetchCallCount == 0)
    }

    @Test func loadMore_whenStateIsLoading_doesNotFetch() async {
        sut.perform(action: .onAppear)
        // State is now .loading — do NOT await, fetch hasn't finished

        sut.perform(action: .loadMore)
        // Yield enough for both tasks to settle
        await waitForTasks()

        // Only the initial fetch should have run
        #expect(repository.fetchCallCount == 1)
    }

    // MARK: - selectItem

    @Test func selectItem_withValidUrl_callsCoordinator() {
        let item = NewsItem(id: 1,
                            title: "Breaking News",
                            titleImageUrl: nil,
                            fullUrl: "https://example.com/news/1",
                            publishedDate: nil)

        sut.perform(action: .selectItem(item))

        #expect(coordinator.showNewsDetailCallCount == 1)
        #expect(coordinator.lastUrl == URL(string: "https://example.com/news/1"))
        #expect(coordinator.lastTitle == "Breaking News")
    }

    @Test func selectItem_withNilUrl_doesNotCallCoordinator() {
        let item = NewsItem(id: 2,
                            title: "Title",
                            titleImageUrl: nil,
                            fullUrl: nil,
                            publishedDate: nil)

        sut.perform(action: .selectItem(item))

        #expect(coordinator.showNewsDetailCallCount == 0)
    }

    @Test func selectItem_withInvalidUrl_doesNotCallCoordinator() {
        // A URL string containing spaces is not a valid URL
        let item = NewsItem(id: 3,
                            title: "Title",
                            titleImageUrl: nil,
                            fullUrl: "not a valid url",
                            publishedDate: nil)

        sut.perform(action: .selectItem(item))

        #expect(coordinator.showNewsDetailCallCount == 0)
    }

    // MARK: - Error handling

    @Test func fetchError_onInitialLoad_setsErrorState() async {
        repository.stubbedResult = .failure(.badRequest)

        sut.perform(action: .onAppear)
        await waitForTasks()

        guard case .error(let someError) = sut.state else {
            Issue.record("Expected .error after initial fetch failure, got \(sut.state)")
            return
        }
        #expect(someError.localizedDescription == NetworkError.badRequest.localizedDescription)
    }

    @Test func fetchError_duringLoadMore_keepsLoadedStateWithExistingItems() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        repository.stubbedResult = .failure(.notConnectedToInternet)
        sut.perform(action: .loadMore)
        await waitForTasks()

        guard case .loaded(let items) = sut.state else {
            Issue.record("Expected .loaded with original items after loadMore failure, got \(sut.state)")
            return
        }
        #expect(items.count == 2)
        #expect(repository.fetchCallCount == 2)
        #expect(repository.lastFetchedPage == 2)
    }

    // MARK: - onDisappear

    @Test func onDisappear_afterLoaded_keepsLoadedState() async {
        let items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: items, totalCount: 2))

        sut.perform(action: .onAppear)
        await waitForTasks()

        sut.perform(action: .onDisappear)

        guard case .loaded(let loadedItems) = sut.state else {
            Issue.record("Expected .loaded after onDisappear, got \(sut.state)")
            return
        }
        #expect(loadedItems.count == 2)
    }

    @Test func onDisappear_whileLoading_resetsStateToIdle() async {
        sut.perform(action: .onAppear)
        // Task is queued but not started yet — disappear before it runs
        sut.perform(action: .onDisappear)
        await waitForTasks()

        guard case .idle = sut.state else {
            Issue.record("Expected .idle after cancelling during .loading, got \(sut.state)")
            return
        }
    }

    @Test func onDisappear_whileLoadingMore_resetsStateToLoadedWithExistingItems() async {
        let page1Items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: page1Items, totalCount: 10))

        sut.perform(action: .onAppear)
        await waitForTasks()

        // Trigger loadMore so state becomes .loadingMore, then immediately disappear
        sut.perform(action: .loadMore)
        sut.perform(action: .onDisappear)
        await waitForTasks()

        guard case .loaded(let items) = sut.state else {
            Issue.record("Expected .loaded with existing items after cancelling during .loadingMore, got \(sut.state)")
            return
        }
        #expect(items.count == 2)
        #expect(repository.fetchCallCount == 2)
        #expect(repository.lastFetchedPage == 2)
    }

    @Test func onAppear_afterCancellationDuringInitialLoad_retriggersLoad() async {
        let items = makeItems(count: 2)
        repository.stubbedResult = .success(makeFeed(items: items, totalCount: 2))

        sut.perform(action: .onAppear)
        sut.perform(action: .onDisappear) // cancels, state -> .idle
        await waitForTasks()

        sut.perform(action: .onAppear)   // .idle again -> triggers loadInitial
        await waitForTasks()

        guard case .loaded(let loadedItems) = sut.state else {
            Issue.record("Expected .loaded after re-appear, got \(sut.state)")
            return
        }
        #expect(loadedItems.count == 2)
        #expect(repository.fetchCallCount == 2)
        #expect(repository.lastFetchedPage == 1)
    }
}
