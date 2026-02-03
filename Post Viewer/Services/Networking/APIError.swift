//
//  APIError.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

enum APIError: Error {
    case invalidURL(String)
    case network(Error)
    case invalidResponse
    case decoding(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
