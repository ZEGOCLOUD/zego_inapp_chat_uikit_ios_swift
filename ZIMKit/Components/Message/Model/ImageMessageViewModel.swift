//
//  ImageMessage.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/16.
//

import Foundation
import ZIM
import UIKit

class ImageMessageViewModel: MediaMessageViewModel {
    
    /// Is this image gif.
    var isGif: Bool {
        let url = URL(fileURLWithPath: message.fileName)
        return url.pathExtension.lowercased() == "gif"
    }
    
    override init(with msg: ZIMKitMessage) {
        super.init(with: msg)
        
        if msg.info.sentStatus != .sendSuccess &&
            msg.imageContent.fileLocalPath.count > 0 &&
            FileManager.default.fileExists(atPath: msg.imageContent.fileLocalPath) &&
            (msg.imageContent.originalSize == .zero || msg.imageContent.fileSize == 0) {
            
            let url = URL(fileURLWithPath: msg.imageContent.fileLocalPath)
            guard let data = try? Data(contentsOf: url) else { return }
            let image = UIImage(data: data)
            msg.imageContent.originalSize = image?.size ?? .zero
            msg.imageContent.fileSize = Int64(data.count)
        }
    }
    
    convenience init(with fileLocalPath: String) {
        let msg = ZIMKitMessage()
        msg.imageContent.fileLocalPath = fileLocalPath
        self.init(with: msg)
    }
    
    override var contentSize: CGSize {
        contentMediaSize = getScaleImageSize(message.imageContent.originalSize.width, message.imageContent.originalSize.height)
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
