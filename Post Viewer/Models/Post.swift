//
//  Post.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

struct Post: Decodable, Hashable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let previewText: String
    let likesCount: Int

    enum CodingKeys: String, CodingKey {
        case postId
        case timeshamp
        case title
        case previewText = "preview_text"
        case likesCount = "likes_count"
    }
}
