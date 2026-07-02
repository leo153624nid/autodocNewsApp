//
//  NewsListViewController.swift
//  AutodocNewsApp
//
//  Created by A Ch on 02.07.2026.
//

import Combine
import UIKit

final class NewsListViewController: UIViewController {

    private let viewModel = NewsListViewModel()
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRootView()
        setupCollectionView()
        setupDataSource()
        setupBindings()
        viewModel.loadInitial()
    }

    // Rotate freely on iPad (and iPhone if desired)
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
        title = "Новости"
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
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
                return UICollectionViewCell() // TODO: maybe return fatal error?
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

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить",
                                      style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        alert.addAction(UIAlertAction(title: "Отмена",
                                      style: .cancel))
        present(alert, animated: true)
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
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
    }
}

// MARK: - UICollectionViewDelegate
extension NewsListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let urlString = item.fullUrl,
              let url = URL(string: urlString) else { return }
        
        let webVC = NewsWebViewController(url: url,
                                          title: item.title)
        navigationController?.pushViewController(webVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        // Trigger next page load when user is 200pt from the bottom
        if contentHeight > 0,
           offsetY > contentHeight - frameHeight - 200 {
            viewModel.loadNextPage()
        }
    }
}
