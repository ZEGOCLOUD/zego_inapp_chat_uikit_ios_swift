//
//  ImageMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/16.
//

import Foundation
import ZIM
import UIKit

class ImageMessage: MediaMessage {

    /// The thumbnail download url of the image message.
    var thumbnailDownloadUrl: String = ""

    /// The thumbnail local path of the image message.
    var thumbnailLocalPath: String = ""

    /// The large download url of the image message.
    var largeImageDownloadUrl: String = ""

    /// The large local path of the image message.
    var largeImageLocalPath: String = ""

    /// The original image size.
    var originalImageSize: CGSize = CGSize(width: 0, height: 0)

    /// The large image size.
    var largeImageSize: CGSize = CGSize(width: 0, height: 0)

    /// The thumbnail image size.
    var thumbnailSize: CGSize = CGSize(width: 0, height: 0)

    /// Is this image gif.
    var isGif: Bool {
        let url = URL(fileURLWithPath: fileName)
        return url.pathExtension.lowercased() == "gif"
    }

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        guard let msg = msg as? ZIMImageMessage else { return }
        thumbnailDownloadUrl = msg.thumbnailDownloadUrl
        thumbnailLocalPath = msg.thumbnailLocalPath
        largeImageDownloadUrl = msg.largeImageDownloadUrl
        largeImageLocalPath = msg.largeImageLocalPath
        originalImageSize = msg.originalImageSize
        largeImageSize =  msg.largeImageSize
        thumbnailSize = msg.thumbnailSize

        if msg.sentStatus == .sendFailed && msg.fileLocalPath.count > 0 {
            ImageCache.cachedImage(for: msg.fileLocalPath, isSync: true) { [weak self] image in
                self?.originalImageSize = image?.size ?? .zero
            }
        }
    }

    convenience init(with fileLocalPath: String) {
        let msg = ZIMImageMessage()
        msg.fileLocalPath = fileLocalPath
        self.init(with: msg)
    }

    override var contentSize: CGSize {
        if _contentSize == .zero {
            _contentSize = getScaleImageSize(originalImageSize.width, originalImageSize.height)
        }
        return _contentSize
    }

    func getScaleImageSize(_ w: CGFloat, _ h: CGFloat) -> CGSize {

        var w = w
        var h = h

        let maxWH = UIScreen.main.bounds.width / 2.0
        let minWH = UIScreen.main.bounds.width / 4.0

        if w == 0 && h == 0 {
            return CGSize(width: maxWH, height: maxWH)
        }

        if w > h {
            h = h / w * maxWH
            h = max(h, minWH)
            w = maxWH
        } else {
            w = w / h * maxWH
            w = max(w, minWH)
            h = maxWH
        }

        return CGSize(width: w, height: h)
    }
}
