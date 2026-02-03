//
//  Coordinator.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

@MainActor
protocol PostListCoordinator: Coordinator {
    func showPostDetail(for viewModel: PostDetailViewModel)
}

@MainActor
final class MainCoordinator: PostListCoordinator {
    var navigationController: UINavigationController
    
    private let service: PostsServiceProtocol
    private let imageLoader: ImageLoaderProtocol
    
    init(
        navigationController: UINavigationController,
        service: PostsServiceProtocol? = nil,
        imageLoader: ImageLoaderProtocol? = nil
    ) {
        self.navigationController = navigationController
        self.service = service ?? PostsService.shared
        self.imageLoader = imageLoader ?? ImageLoader.shared
    }
    
    func start() {
        let feedViewModel = FeedViewModel(service: service)
        let vc = FeedViewController(viewModel: feedViewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showPostDetail(for viewModel: PostDetailViewModel) {
        let detailVC = PostDetailViewController(viewModel: viewModel, imageLoader: imageLoader)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
