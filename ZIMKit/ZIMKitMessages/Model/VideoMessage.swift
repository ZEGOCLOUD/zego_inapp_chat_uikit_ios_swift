//
//  VideoMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class VideoMessage: MediaMessage {

    /// The duration of the video.
    var duration: UInt32 = 0

    /// The first frame download url of the video.
    var firstFrameDownloadUrl: String = ""

    /// The first frame local path of the video.
    var firstFrameLocalPath: String = ""

    /// The first frame size of the video.
    var firstFrameSize: CGSize = CGSize(width: 0, height: 0)

    override init(with msg: ZIMMessage) {
        super.init(with: msg)
        guard let msg = msg as? ZIMVideoMessage else { return }
        duration = msg.videoDuration
        firstFrameDownloadUrl = msg.videoFirstFrameDownloadUrl
        firstFrameLocalPath = msg.videoFirstFrameLocalPath
        firstFrameSize = msg.videoFirstFrameSize

        if msg.sentStatus == .sendFailed {
            let url = URL(fileURLWithPath: fileLocalPath)
            let videoInfo = VideoTool.getFirstFrameImageAndDuration(with: url)
            firstFrameSize = videoInfo.0?.size ?? .zero
            firstFrameLocalPath = url.deletingPathExtension().path + ".png"
            if !ImageCache.containsCachedImage(for: firstFrameLocalPath) {
                ImageCache.storeImage(image: videoInfo.0, for: firstFrameLocalPath)
            }
        }
    }

    convenience init(with fileLocalPath: String, duration: UInt32, firstFrameLocalPath: String) {
        let msg = ZIMVideoMessage(fileLocalPath: fileLocalPath, videoDuration: duration)
        self.init(with: msg)
        self.firstFrameLocalPath = firstFrameLocalPath
    }

    override var contentSize: CGSize {
        if _contentSize == .zero {
            _contentSize = getScaleImageSize(firstFrameSize.width, firstFrameSize.height)
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
