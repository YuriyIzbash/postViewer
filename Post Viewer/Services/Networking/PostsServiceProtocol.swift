//
//  PostsServiceProtocol.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

protocol PostsServiceProtocol {
    func fetchFeed(completion: @escaping (Result<[Post], APIError>) -> Void)
    func fetchPostDetail(id: Int, completion: @escaping (Result<PostDetail, APIError>) -> Void)
}
