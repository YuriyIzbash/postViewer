//
//  PostDetailViewModel.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

@MainActor
final class PostDetailViewModel {
    private let postId: Int
    private let service: PostsServiceProtocol

    var onLoadingChanged: ((Bool) -> Void)?
    var onDetailLoaded: ((PostDetail) -> Void)?
    var onError: ((String) -> Void)?

    init(postId: Int, service: PostsServiceProtocol? = nil) {
        self.postId = postId
        self.service = service ?? PostsService.shared
    }

    func load() {
        onLoadingChanged?(true)
        service.fetchPostDetail(id: postId) { [weak self] result in
            guard let self = self else { return }
            self.onLoadingChanged?(false)
            switch result {
            case .success(let detail):
                self.onDetailLoaded?(detail)
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
