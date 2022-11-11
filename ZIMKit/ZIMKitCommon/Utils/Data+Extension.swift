//
//  Data+Extension.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/24.
//

import Foundation
import Kingfisher

extension Data {
    public func isGif() -> Bool {
        return kf.imageFormat == .GIF
    }

    public var type: ImageFormat {
        return kf.imageFormat
    }

    public var gifImage: UIImage? {
        let options = ImageCreatingOptions()
        return KingfisherWrapper.animatedImage(data: self, options: options)
    }
}
