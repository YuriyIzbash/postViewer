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
    private let basicURL = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchFeed(completion: @escaping (Result<[Post], APIError>) -> Void) {
        let logger = self.logger
        logger.debug("Starting fetchFeed request")
        let urlString = basicURL + Endpoints.feed.path
        logger.debug("Feed URL string: \(urlString)")
        guard let url = URL(string: urlString) else {
            logger.error("Failed to create URL from string: \(urlString)")
            Task { @MainActor in
                completion(.failure(.invalidURL(urlString)))
            }
            return
        }
        logger.info("Created feed URL successfully: \(url.absoluteString)")

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

            logger.debug("HTTP status code: \(httpResponse.statusCode)")
            logger.debug("Response URL: \(httpResponse.url?.absoluteString ?? "nil")")

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

            logger.info("Received \(data.count) bytes for feed")

            Task { @MainActor in
                do {
                    logger.debug("Decoding feed response")
                    let decoder = JSONDecoder()
                    let feed = try decoder.decode(FeedResponse.self, from: data)
                    logger.info("Successfully decoded feed with \(feed.posts.count) posts")
                    completion(.success(feed.posts))
                } catch {
                    logger.error("Decoding error while parsing feed: \(String(describing: error))")
                    completion(.failure(.decoding(error)))
                }
            }
        }.resume()
    }

    func fetchPostDetail(id: Int, completion: @escaping (Result<PostDetail, APIError>) -> Void) {
        let logger = self.logger
        logger.debug("Fetching post detail. id=\(id)")
        let urlString = basicURL + Endpoints.postDetail(id: id).path
        logger.debug("Post detail URL string: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("Failed to create URL from string: \(urlString)")
            Task { @MainActor in
                completion(.failure(.invalidURL(urlString)))
            }
            return
        }
        
        logger.info("Created post detail URL successfully: \(url.absoluteString)")

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
            
            logger.debug("HTTP status code: \(httpResponse.statusCode)")
            logger.debug("Response URL: \(httpResponse.url?.absoluteString ?? "nil")")
            
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
            
            logger.info("Received \(data.count) bytes for post detail")

            Task { @MainActor in
                do {
                    logger.debug("Decoding post detail response")
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
        }.resume()
    }
}
