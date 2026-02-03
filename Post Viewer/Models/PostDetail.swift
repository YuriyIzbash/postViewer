//
//  PostDetail.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

struct PostDetail: Decodable {
    let postId: Int
    let timeshamp: TimeInterval
    let title: String
    let text: String
    let postImage: URL?
    let likesCount: Int

    enum CodingKeys: String, CodingKey {
        case postId
        case timeshamp
        case title
        case text
        case postImage
        case likesCount = "likes_count"
    }
}
