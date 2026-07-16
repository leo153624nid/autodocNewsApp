//
//  NewsListViewController.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import UIKit

/// View controller that displays the paginated news grid.
final class NewsListViewController: UIViewController {

    private let viewModel: NewsListViewModel
    private var cancellables = Set<AnyCancellable>()

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsItem>!

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let refreshControl = UIRefreshControl()
    private weak var footerView: LoadingFooterView?

    @InjectedLazy private var imageLoader: ImageLoader
    private var prefetchTasks: [IndexPath: Task<Void, Never>] = [:]

    // MARK: - Initialization

    init(viewModel: NewsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRootView()
        setupCollectionView()
        setupDataSource()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.perform(action: .onAppear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.perform(action: .onDisappear)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Setup

    private func setupRootView() {
        title = "screen.news.title".localized
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(NewsCell.self,
                                forCellWithReuseIdentifier: NewsCell.reuseIdentifier)
        collectionView.register(LoadingFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoadingFooterView.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, environment in
            let cellPadding = Constants.cellPadding
            let sectionPadding = Constants.cellPadding * 2
            let availableWidth = environment.container.effectiveContentSize.width
            // 3 columns on wide screens (iPad), 2 on narrow (iPhone)
            let columns: Int = availableWidth > Constants.widthTarget ? 3 : 2
            let columnsF = CGFloat(columns)

            let totalInterItemSpacing = cellPadding * 2 * (columnsF - 1)
            let itemWidth = (availableWidth - totalInterItemSpacing - sectionPadding * 2) / columnsF

            let itemSize = if #available(iOS 17.0, *) {
                NSCollectionLayoutSize(
                    widthDimension: .absolute(itemWidth),
                    heightDimension: .uniformAcrossSiblings(estimate: Constants.cellEstimateHeight)
                )
            } else {
                NSCollectionLayoutSize(
                    widthDimension: .absolute(itemWidth),
                    heightDimension: .estimated(Constants.cellEstimateHeight)
                )
            }
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(Constants.cellEstimateHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])
            group.interItemSpacing = .fixed(2 * cellPadding)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionPadding,
                                                            leading: sectionPadding,
                                                            bottom: sectionPadding,
                                                            trailing: sectionPadding)
            section.interGroupSpacing = 2 * cellPadding

            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(50))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]

            return section
        }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NewsItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCell.reuseIdentifier,
                                                          for: indexPath) as? NewsCell

            guard let cell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }

            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                for: indexPath
            ) as? LoadingFooterView
            self?.footerView = footer

            return footer
        }
    }

    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - State Handling

    private func handleState(_ state: NewsListViewModel.State) {
        switch state {
        case .idle:
            break

        case .loading:
            activityIndicator.startAnimating()

        case .loaded(let items):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            footerView?.stopAnimating()
            applySnapshot(items)

        case .loadingMore(let items):
            footerView?.startAnimating()
            applySnapshot(items)

        case .error(let error):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            footerView?.stopAnimating()
            showError(error)
        }
    }

    private func applySnapshot(_ items: [NewsItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "error.alert.title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "alert.action.retry".localized,
                                      style: .default) { [weak self] _ in
            self?.viewModel.perform(action: .pullToRefresh)
        })
        alert.addAction(UIAlertAction(title: "alert.action.cancel".localized,
                                      style: .cancel))
        
        present(alert, animated: true)
    }

    @objc private func handleRefresh() {
        viewModel.perform(action: .pullToRefresh)
    }
}

// MARK: - UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.perform(action: .selectItem(item))
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems(inSection: .main)
        guard totalItems > 0,
              indexPath.item >= totalItems - Constants.prefetchThreshold else { return }
        viewModel.perform(action: .loadMore)
    }

}

// MARK: - UICollectionViewDataSourcePrefetching
extension NewsListViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        let items = dataSource.snapshot().itemIdentifiers(inSection: .main)

        for indexPath in indexPaths {
            guard indexPath.item < items.count,
                  let urlString = items[indexPath.item].titleImageUrl,
                  !urlString.isEmpty else { continue }

            prefetchTasks[indexPath] = Task { [weak self] in
                guard let self else { return }
                _ = await imageLoader.loadImage(from: urlString)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            prefetchTasks.removeValue(forKey: indexPath)?.cancel()
        }
    }
}

// MARK: - Child types
private extension NewsListViewController {

    enum Section {
        case main
    }

    struct Constants {
        static let cellEstimateHeight: CGFloat = 220
        static let cellPadding: CGFloat = 6
        static let widthTarget: CGFloat = 600
        static let prefetchThreshold = 3
    }
}
