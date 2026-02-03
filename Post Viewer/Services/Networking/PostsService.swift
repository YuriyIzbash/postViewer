//
//  PostsService.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation
import os

final class PostsService: PostsServiceProtocol {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PostsApp", category: "PostsService")
    static let shared = PostsService()

    private let session: URLSession
    private let baseURL = URL(string: "https://raw.githubusercontent.com/anton-natife/jsons/master/api/")!
    
    private func makeURL(for endpoint: Endpoints) -> URL {
        baseURL.appendingPathComponent(endpoint.path)
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchFeed(completion: @escaping (Result<[Post], APIError>) -> Void) {
        let logger = self.logger
        
        let url = makeURL(for: .feed)
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                logger.error("Network error while fetching feed: \(error.localizedDescription)")
                
                Task { @MainActor in
                    completion(.failure(.network(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid HTTP response while fetching feed")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                logger.error("HTTP error while fetching feed. Status code: \(httpResponse.statusCode)")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data = data else {
                logger.error("No data received while fetching feed")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }

            Task { @MainActor in
                do {
                    let decoder = JSONDecoder()
                    let feed = try decoder.decode(FeedResponse.self, from: data)
                    logger.info("Successfully decoded feed with \(feed.posts.count) posts")
                    completion(.success(feed.posts))
                } catch {
                    logger.error("Decoding error while parsing feed: \(String(describing: error))")
                    completion(.failure(.decoding(error)))
                }
            }
        }
        .resume()
    }

    func fetchPostDetail(id: Int, completion: @escaping (Result<PostDetail, APIError>) -> Void) {
        let logger = self.logger
        let endpoint = Endpoints.postDetail(id: id)
        
        let url = makeURL(for: endpoint)

        session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                logger.error("Network error while fetching post detail: \(error.localizedDescription)")
                
                Task { @MainActor in
                    completion(.failure(.network(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid HTTP response while fetching post detail")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                logger.error("HTTP error while fetching post detail. Status code: \(httpResponse.statusCode)")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                logger.error("No data received while fetching post detail")
                
                Task { @MainActor in
                    completion(.failure(.invalidResponse))
                }
                return
            }

            Task { @MainActor in
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PostDetailResponse.self, from: data)
                    let detail = response.post
                    logger.info("Successfully decoded PostDetail for post ID: \(detail.postId)")
                    completion(.success(detail))
                } catch {
                    logger.error("Decoding error while parsing post detail: \(String(describing: error))")
                    completion(.failure(.decoding(error)))
                }
            }
        }
        .resume()
    }
}

