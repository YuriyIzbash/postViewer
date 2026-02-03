//
//  FeedViewModel.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

@MainActor
final class FeedViewModel {

    enum State {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let service: PostsServiceProtocol
    private var posts: [Post] = []
    private var expandedStateById: [Int: Bool] = [:]

    private(set) var cellViewModels: [PostCellViewModel] = [] {
        didSet {
            onPostsChanged?(cellViewModels)
        }
    }

    var state: State = .idle {
        didSet {
            onStateChanged?(state)
        }
    }

    var onPostsChanged: (([PostCellViewModel]) -> Void)?
    var onStateChanged: ((State) -> Void)?

    init(service: PostsServiceProtocol? = nil) {
        self.service = service ?? PostsService.shared
    }

    func loadFeed() {
        state = .loading
        service.fetchFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let posts):
                self.posts = posts
                self.buildCellViewModels()
                self.state = .loaded
            case .failure(let error):
                self.state = .failed(error.localizedDescription)
            }
        }
    }

    func toggleExpanded(for postId: Int) {
        let current = expandedStateById[postId] ?? false
        expandedStateById[postId] = !current
        buildCellViewModels()
    }

    func detailViewModel(for indexPath: IndexPath) -> PostDetailViewModel? {
        guard indexPath.item < posts.count else { return nil }
        let post = posts[indexPath.item]
        return PostDetailViewModel(postId: post.postId, service: service)
    }

    // MARK: - Helpers

    private func buildCellViewModels() {
        cellViewModels = posts.map { post in
            let date = Date(timeIntervalSince1970: post.timeshamp)
            let dateText = relativeDateString(from: date)

            let likesText = "❤️ \(post.likesCount)"
            let isExpanded = expandedStateById[post.postId] ?? false
            return PostCellViewModel(
                id: post.postId,
                title: post.title,
                previewText: post.previewText,
                likesText: likesText,
                dateText: dateText,
                isExpanded: isExpanded
            )
        }
    }
}
