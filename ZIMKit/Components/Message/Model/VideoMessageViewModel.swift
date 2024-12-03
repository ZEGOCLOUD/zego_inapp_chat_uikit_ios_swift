//
//  VideoMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/17.
//

import Foundation
import ZIM

class VideoMessageViewModel: MediaMessageViewModel {
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        
        let firstFrameLocalPath = msg.videoContent.firstFrameLocalPath
        if firstFrameLocalPath.count > 0 &&
            !FileManager.default.fileExists(atPath: firstFrameLocalPath) {
            
            let home = NSHomeDirectory()
            if home.endIndex <= firstFrameLocalPath.endIndex {
                msg.videoContent.firstFrameLocalPath = home + firstFrameLocalPath[home.endIndex..<firstFrameLocalPath.endIndex]
            }
        }
        
        if msg.info.sentStatus != .sendSuccess {
            
            let firstFrameLocalPath = msg.videoContent.firstFrameLocalPath
            if msg.videoContent.firstFrameSize != .zero && FileManager.default.fileExists(atPath: firstFrameLocalPath) {
                return
            }
            
            let url = URL(fileURLWithPath: msg.videoContent.fileLocalPath)
            let videoInfo = AVTool.getFirstFrameImageAndDuration(with: url)
            msg.videoContent.firstFrameSize = videoInfo.image?.size ?? .zero
            msg.videoContent.firstFrameLocalPath = url.deletingPathExtension().path + ".png"
            if !FileManager.default.fileExists(atPath: msg.videoContent.firstFrameLocalPath) {
                let data = videoInfo.image?.pngData()
                try? data?.write(to: URL(fileURLWithPath: msg.videoContent.firstFrameLocalPath))
            }
        }
    }
    
    convenience init(with fileLocalPath: String, duration: UInt32, firstFrameLocalPath: String) {
        let msg = ZIMKitMessage()
        msg.videoContent.fileLocalPath = fileLocalPath
        msg.videoContent.duration = duration
        msg.videoContent.firstFrameLocalPath = firstFrameLocalPath
        self.init(with: msg)
    }
    
    override var contentSize: CGSize {
        contentMediaSize = getScaleImageSize(message.videoContent.firstFrameSize.width, message.videoContent.firstFrameSize.height)
        _contentSize = contentMediaSize
        
        if message.reactions.count.isEmpty {
            
        } else {
            _contentSize.width += 24
            _contentSize.height += 20
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
