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
}

@MainActor
protocol PostListCoordinator: Coordinator {
    func showPostDetail(for viewModel: PostDetailViewModel)
}

@MainActor
final class MainCoordinator: PostListCoordinator {
    func showPostDetail(for viewModel: PostDetailViewModel) {
        
    }
    
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
}
