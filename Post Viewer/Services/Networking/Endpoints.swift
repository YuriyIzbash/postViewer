//
//  Endpoints.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

enum Endpoints {
    case feed
    case postDetail(id: Int)

    var path: String {
       switch self {
       case .feed: "main.json"
       case .postDetail(let id): "posts/\(id).json"
        }
    }
}
