//
//  FeedViewController.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

final class FeedViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    private var viewModelsById: [Int: PostCellViewModel] = [:]
    private var lastToggledPostId: Int?
    
    private weak var coordinator: PostListCoordinator?
    
    private let viewModel: FeedViewModel
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(viewModel: FeedViewModel, coordinator: PostListCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground

        configureCollectionView()
        configureActivityIndicator()
        configureDataSource()
        bindViewModel()

        viewModel.loadFeed()
    }

    private func configureCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.reuseIdentifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(
            collectionView: collectionView
        ) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) in
            guard let self = self,
                  let cell = collectionView.dequeueReusableCell(
                      withReuseIdentifier: PostCollectionViewCell.reuseIdentifier,
                      for: indexPath
                  ) as? PostCollectionViewCell,
                  let viewModel = self.viewModelsById[itemIdentifier] else {
                return UICollectionViewCell()
            }

            cell.configure(with: viewModel)
            cell.onToggleExpansion = { [weak self] in
                guard let self = self else { return }
                self.lastToggledPostId = itemIdentifier
                self.viewModel.toggleExpanded(for: itemIdentifier)
            }
            return cell
        }
    }

    private func applySnapshot(with items: [PostCellViewModel], animatingDifferences: Bool = true) {
        viewModelsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        var snapshot = dataSource.snapshot()
        
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
            let ids = items.map { $0.id }
            snapshot.appendItems(ids, toSection: 0)
        } else {
            if let toggledId = lastToggledPostId, snapshot.itemIdentifiers.contains(toggledId) {
                snapshot.reconfigureItems([toggledId])
                lastToggledPostId = nil // Reset after use
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            switch state {
            case .idle:
                self?.activityIndicator.stopAnimating()
            case .loading:
                self?.activityIndicator.startAnimating()
            case .loaded:
                self?.activityIndicator.stopAnimating()
            case .failed(let message):
                self?.activityIndicator.stopAnimating()
                self?.showError(message: message)
            }
        }

        viewModel.onPostsChanged = { [weak self] items in
            self?.applySnapshot(with: items)
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let detailViewModel = viewModel.detailViewModel(for: indexPath) else { return }
        coordinator?.showPostDetail(for: detailViewModel)
    }
}
