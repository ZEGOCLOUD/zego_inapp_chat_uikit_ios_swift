//
//  AnimatedImageView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/21.
//

import Foundation
import Kingfisher

class AnimatedImageView: Kingfisher.AnimatedImageView {
    func animated(withPath path: String) {
        let provider = LocalFileImageDataProvider(fileURL: URL(fileURLWithPath: path))
        kf.setImage(with: provider)
    }
}
