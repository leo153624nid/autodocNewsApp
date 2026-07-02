//
//  NewsListViewController.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import UIKit
import Combine

final class NewsListViewController: UIViewController {

    private enum Section { case main }

    private let viewModel = NewsListViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsItem>!

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новости"
        view.backgroundColor = .systemGroupedBackground
        setupCollectionView()
        setupDataSource()
        setupBindings()
        viewModel.loadInitial()
    }

    // Rotate freely on iPad (and iPhone if desired)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseIdentifier)

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
            let availableWidth = environment.container.effectiveContentSize.width
            // 3 columns on wide screens (iPad), 2 on narrow (iPhone)
            let columns: Int = availableWidth > 600 ? 3 : 2

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .estimated(220)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(220)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            return section
        }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NewsItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsCell.reuseIdentifier,
                for: indexPath
            ) as! NewsCell
            cell.configure(with: item)
            return cell
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
            applySnapshot(items)

        case .loadingMore(let items):
            // Items already shown; snapshot stays; spinner on bottom cell handled by scroll
            applySnapshot(items)

        case .error(let error):
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            showError(error)
        }
    }

    private func applySnapshot(_ items: [NewsItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.refresh()
    }
}

// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let urlString = item.fullUrl,
              let url = URL(string: urlString) else { return }
        let webVC = NewsWebViewController(url: url, title: item.title)
        navigationController?.pushViewController(webVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        // Trigger next page load when user is 200pt from the bottom
        if contentHeight > 0, offsetY > contentHeight - frameHeight - 200 {
            viewModel.loadNextPage()
        }
    }
}
