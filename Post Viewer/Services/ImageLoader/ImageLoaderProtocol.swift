//
//  ImageLoaderProtocol.swift
//  Post Viewer
//
//  Created by yuriy on 3. 2. 26.
//

import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}
