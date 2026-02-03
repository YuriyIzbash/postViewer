//
//  FeedResponse.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

struct FeedResponse: Decodable {
    let posts: [Post]
}
