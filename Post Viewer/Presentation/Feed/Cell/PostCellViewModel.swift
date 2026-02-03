//
//  PostCellViewModel.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import Foundation

struct PostCellViewModel: Sendable {
    let id: Int
    let title: String
    let previewText: String
    let likesText: String
    let dateText: String
    let isExpanded: Bool
}
